module Fluid where

dotProduct :: InputBuffer CFloat -> InputBuffer CFloat -> OpenCL CFloat
dotProduct vec1 vec2 = 
    multipliedOutMem 
