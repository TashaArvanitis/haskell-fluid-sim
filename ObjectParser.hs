module ObjectParser (
  Mesh(..),
  Vertex(..),
  Face(..),
  MeshName,
  parseMesh
) where 

import Control.Monad(liftM)
import Data.Array(listArray, Array)
import Data.Maybe(catMaybes)
import Text.Parsec.Char(noneOf, oneOf, newline, char)
import Text.Parsec.Combinator(count, many1, optionMaybe)
import Text.Parsec.Prim(parse, many)
import Text.Parsec.String(Parser)

data Mesh = Mesh {
    vertices :: Array Int Vertex,
    faces :: Array Int Face,
    faceNormals :: Array Int Vertex,
    vertexNormals :: Array Int Vertex,
    name :: MeshName,
    dx, dy, dz :: Float,
    sx, sy, sz :: Float,
    rx, ry, rz :: Float
} deriving Show
type MeshName = String
data Vertex = Vertex {
    x :: !Float,
    y :: !Float,
    z :: !Float
} deriving Show
data Face = Triangle Int Int Int | Quad Int Int Int Int deriving Show

vertexParser :: Parser [Vertex]
vertexParser = linesStartingWith 'v' $ do
  [x, y, z] <- count 3 $ do
    floatString <- many $ noneOf " \n"
    many $ oneOf " \n\r"
    return (read floatString)
  return $ Vertex x y z

faceParser :: Parser [Face]
faceParser = linesStartingWith 'f' $ do
  vertexList <- many1 $ do
    intString <- many1 $ noneOf " \n"
    many $ char ' '
    return (read intString)
  many $ oneOf " \n\r"
  return $ case vertexList of
    [v1, v2, v3] -> Triangle v1 v2 v3
    [v1, v2, v3, v4] -> Quad v1 v2 v3 v4
    verts -> error (show verts)
    
nameParser :: Parser [String]
nameParser = linesStartingWith 'o' $ do
  nameString <- many $ noneOf "\n"
  newline
  return nameString

linesStartingWith :: Char -> Parser a -> Parser [a]
linesStartingWith character lineParser = 
  liftM catMaybes $ maybeLine character lineParser

maybeLine :: Char -> Parser a -> Parser [Maybe a]
maybeLine character lineParser = 
  many $ do
    line <- optionMaybe (char character >> char ' ' >> lineParser)
    case line of
      Just value -> return $ Just value
      Nothing -> many (noneOf "\n") >> char '\n' >> return Nothing

parseMesh :: FilePath -> IO Mesh
parseMesh filePath = do
  fileContents <- readFile filePath
  let vertices = case parse vertexParser filePath fileContents of
        Left e -> error $ show e
        Right verts -> verts
  let faces = case parse faceParser filePath fileContents of
        Left e -> error $ show e
        Right faceList -> faceList
  let name = case parse nameParser filePath fileContents of
        Left e -> error $ show e
        Right [nameStr] -> nameStr

  let (vertNormals, faceNormals) = computeNormals faces vertices

  return Mesh {
    dx = 0, dy = 0, dz = 0,
    rx = 0, ry = 0, rz = 0,
    sx = 1, sy = 1, sz = 1,
    vertices = listArray (1, length vertices) vertices,
    faces = listArray (1, length faces) faces,
    vertexNormals = listArray (1, length vertNormals) vertNormals,
    faceNormals = listArray (1, length faceNormals) faceNormals,
    name = name
  }

computeNormals :: [Face] -> [Vertex] -> ([Vertex], [Vertex])
computeNormals faces vertices = (vertexNormals, faceNormals)
  where
    faceNormals = map (makeFaceNormal vertices) faces
    vertexNormals = map (makeVertexNormal faceNormals) $ zip [1..] vertices 

    makeFaceNormal vertices (Triangle a b c) = faceNormalFor (vertices !! a) (vertices !! b) (vertices !! c)
    makeFaceNormal vertices (Quad a b c _) = faceNormalFor (vertices !! a) (vertices !! b) (vertices !! c)
    faceNormalFor v1 v2 v3 =
      let x1 = x v1 - x v2
          y1 = y v1 - y v2
          z1 = z v1 - z v2

          x2 = x v1 - x v3
          y2 = y v1 - y v3
          z2 = z v1 - z v3 in

				// Compute Normal = CrossProduct(edge 1, edge 2)
				faceNormals[faceInd] = first.CrossProduct(second).Normalized()

