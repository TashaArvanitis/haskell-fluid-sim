{-# LANGUAGE FlexibleInstances, ViewPatterns, DoAndIfThenElse #-}
module MarchingCubes where


import Data.List( foldl', unzip3, groupBy, zipWith4, zip3, nub, sort )
import Data.List.Split
import Data.Function( on )
import Control.Monad( forM_, forM, when )
import Control.Applicative ((<$>))
import Data.Array.MArray( newListArray, getBounds, readArray, writeArray, freeze )
import Data.Array.IO( IOArray )
import Data.Array( listArray, Array, array, elems )
import Foreign.C.Types( CInt, CFloat )
import Control.Monad.IO.Class
import System.Exit

import ObjectParser
import OpenCL

-- Index of the cube in the global array.
type CubeId = CInt

-- Cube index (8-bit hash based on field values).
type CubeIndex = CInt

-- Vertex number, either within its cube or in the global vertex array.
type RelVertexId = CInt
type AbsVertexId = CInt

toMArray :: [a] -> IO (IOArray Int a)
toMArray things = newListArray (1, length things) things

toArray :: [a] -> Array Int a
toArray things = listArray (1, length things) things
  
gridIndex :: Integral a => a -> (a, a, a) -> a
gridIndex n (x, y, z) = z + n * y + n^2 * x

gridPosition :: Integral a => a -> a -> (a, a, a)
gridPosition n num = (x, y, z) where
  z = num `mod` n
  y = ((num - z) `div` n) `mod` n
  x = (num - z - n * y) `div` n^2

-- Functions to generate field values:
sphereValue n radius (x, y, z) = if distance > radius^2 then 0 else 1
  where distance = (x - n `div` 2)^2
                 + (y - n `div` 2)^2
                 + (z - n `div` 2)^2

planeValue zCutoff (_, _, z) 
  | fromIntegral z < zCutoff = 1
  | otherwise   = 0


-- Kernels used: "numVertices", "genVerts", "vertexPositions"
demoCube :: OpenCL Mesh
demoCube = do
  -- Initialize the field values for a sphere.
  let n = 10
      nC = fromIntegral n :: CInt
      radius = 4
      indices = map (gridPosition $ n + 1) [0..(n+1)^3-1]
      value = sphereValue n radius
      --value = planeValue 0.9
      values = map value indices :: [CFloat]

  -- Generate the mesh!
  inputBuffer values >>= makeMesh n

makeMesh :: Integral a => a -> InputBuffer CFloat -> OpenCL Mesh
makeMesh n grid = do
  let nC = fromIntegral n :: CInt
      nCubes = fromIntegral n^3 
  nvertsIn <- outputBuffer nCubes :: OpenCL (OutputBuffer CInt)
  cubeIndicesIn <- outputBuffer nCubes :: OpenCL (OutputBuffer CInt)
  setKernelArgs "numVertices" nC grid nvertsIn cubeIndicesIn
  nvertsOut <- runKernel "numVertices" [nCubes] [1]

  -- Outputs of first kernel: number of vertices in each cube and cube
  -- index of each cube.
  nverts <- readKernelOutput nvertsOut nvertsIn
  cubeIndices <- readKernelOutput nvertsOut cubeIndicesIn
  
  -- Postprocess the output of the first kernel.  In order to continue, we
  -- need to have several arrays indexed by vertex number (with size equal
  -- to the total number of vertices). We need the cube ids, cube indices,
  -- vertex ids (within their respective cubes).  We also need the starting
  -- vertex number (absolute, not relative to their cube) of the first
  -- vertex in each cube (indexed by cube id).
  let 
      -- Given a list of (item, count), generate a list where
      -- for each such tuple, we output `count` number of tuples,
      -- (thing, 0), (thing, 1), ..., (thing, count - 1)
      scan :: [(a, CInt)] -> [(a, CInt)]
      scan things = case things of
        [] -> []
        ((_, 0):xs) -> scan xs
        ((thing, n):xs) -> zip (replicate (fromIntegral n) thing) [0..n-1] ++ scan xs

      -- What we know for each cube.
      perCubeData :: [(CubeId, CubeIndex)]
      perCubeData = zip [0..] cubeIndices

      -- Convert per cube data into per vertex data.
      (unzip -> (cubeIds, cubeInds), vertIds) = unzip . scan $ zip perCubeData nverts

      -- Compute the starting vertex index for each cube.
      startingIndices = countStarts cubeIds 0 0 :: [AbsVertexId]

      -- Compute the starting vertex indices for all the cubes, indexed by
      -- cube id. 
      countStarts :: [CubeId]      -- Cube ids
                  -> CubeId        -- Expected cube id
                  -> AbsVertexId   -- The vertex index we're currently looking at
                  -> [AbsVertexId]
      countStarts remainingIds exp ind =
        case remainingIds of
          [] -> []
          id:more -> 
            case compare id exp of
              -- If the next cube id is greater than the expected cube id,
              -- then the expected cube has no vertices, so output the
              -- current vertex index and continue looking for the
              -- subsequent cube id.
              GT -> ind:countStarts (id:more) (exp + 1) ind

              -- If the next cube id is equal to the expected cube id,
              -- then we consume this vertex (advance to next vertex index)
              -- and output the current vertex index.
              EQ -> ind:countStarts more (exp + 1) (ind + 1)

              -- If the next cube id is less than the expected cube id,
              -- then this is not the first vertex we've seen in this cube,
              -- so advance the vertex index and continue searching for the
              -- expected cube id.
              LT -> countStarts more exp (ind + 1)

  -- Generate the vertices. The output of this step is, for each vertex,
  -- the index into the global vertex array corresponding to the first
  -- occurence of this vertex.
  when (all (== 0) nverts) $ liftIO $ do
    putStrLn "No vertices generated"
    exitWith (ExitFailure 1)

  let numVerts = length vertIds
  cubeIdInput <- inputBuffer cubeIds
  cubeIndInput <- inputBuffer cubeIndices
  vertIdInput <- inputBuffer vertIds
  startingVertInput <- inputBuffer startingIndices

  globalVertInds <- outputBuffer numVerts :: OpenCL (OutputBuffer CInt)

  setKernelArgs "genVerts" nC cubeIdInput cubeIndInput vertIdInput startingVertInput globalVertInds
  genVertsOut <- runKernel "genVerts" [numVerts] [1]
  vertArray <- readKernelOutput genVertsOut globalVertInds >>= (liftIO . toMArray)

  -- Rename vertices to one through k (k = length of unique vertices).
  -- This changes the vertex array in place!
  (_, len) <- liftIO $ getBounds vertArray
  let loop :: Int -- Current index in the mutable array.
           -> CInt -- Current next label for the unique vertices.
           -> [AbsVertexId] -- An accumulator for the global vertex indices corresponding to each label.
           -> IO [AbsVertexId] -- Global vertex indices, indexed by the unique labels.
      loop ind counter backwardsAccum =
        -- If we're looking beyond the length, we're done.
        -- Return the accumulated global vertex indices.
        if ind > len
        then return $ reverse backwardsAccum

        else do
          -- If the value at our current index is equal (with shift due to
          -- weird indexing) to its own index, then this is the first time
          -- we're seeing this unique vertex.
          value <- readArray vertArray ind
          if value + 1 == fromIntegral ind
          then do
            -- Since this is the first time we're seeing this, 
            -- rename it to the next available label (counter).
            writeArray vertArray ind counter
            loop (ind + 1) (counter + 1) (value:backwardsAccum)
          else do
            -- If we've seen this vertex before, find out what its 
            -- new unique label is, and rename it to that.
            readArray vertArray (fromIntegral value + 1) >>= writeArray vertArray ind
            loop (ind + 1) counter backwardsAccum

  -- Rename vertices and then freeze the array to be immutable.
  previousGlobalIndices <- liftIO $ loop 1 1 [] :: OpenCL [CInt]
  renamedVerts <- liftIO $ freeze vertArray

  -- Generate actual vertex positions in 3-space.
  let numUniqueVerts = fromIntegral $ maximum $ elems renamedVerts
  globalVertIds <- inputBuffer previousGlobalIndices

  -- Allocate 4x the number of vertices because float3s take 4 floats.
  vertPosOut <- outputBuffer (numUniqueVerts * 4) :: OpenCL (OutputBuffer CFloat)
  setKernelArgs "vertexPositions" nC grid globalVertIds cubeIdInput cubeIndInput vertIdInput vertPosOut
  vertexPositionsOut <- runKernel "vertexPositions" [numUniqueVerts] [1]

  -- Generate vertices and faces for our mesh from the float3s.
  positions <- readKernelOutput vertexPositionsOut vertPosOut
  let toVert [x, y, z, _] = Vertex (realToFrac x) (realToFrac y) (realToFrac z)
      toTri [v1, v2, v3] = Triangle (fromIntegral v1) (fromIntegral v2) (fromIntegral v3)

      vertices = map toVert $ chunksOf 4 positions
      faces = map toTri $ chunksOf 3 $ elems renamedVerts

  -- Compute vertex and face normals.
  let (vertexNormals, faceNormals) = computeNormals faces vertices

  -- Create the mesh from these results
  let scale = 0.1
  let mesh = Mesh{ vertices = toArray vertices
                 , faces = toArray faces
                 , faceNormals = toArray faceNormals
                 , vertexNormals = toArray vertexNormals
                 , name = "Sketchiest Mesh Ever"
                 , dx = 0 , dy = 0 , dz = 1
                 , sx = scale , sy = scale , sz = scale
                 , rx = 0 , ry = 0 , rz = 0
                 }
  return mesh
