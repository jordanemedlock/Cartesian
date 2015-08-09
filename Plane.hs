-- |
-- Module      : Southpaw.Cartesian.Plane
-- Description : 
-- Copyright   : (c) Jonatan H Sundqvist, year
-- License     : MIT
-- Maintainer  : Jonatan H Sundqvist
-- Stability   : experimental|stable
-- Portability : POSIX (not sure)
-- 

-- Created date year

-- TODO | - Which constraints are appropriate (Num is probably too generic, should be Real, maybe RealFrac)
--        - Strictness, performance

-- SPEC | -
--        -



module Southpaw.Cartesian.Plane where



---------------------------------------------------------------------------------------------------
-- We'll need these
---------------------------------------------------------------------------------------------------
import Data.List (sort, minimumBy)
import Data.Ord  (comparing)

import Southpaw.Utilities.Utilities (pairwise)



---------------------------------------------------------------------------------------------------
-- Types
---------------------------------------------------------------------------------------------------
-- |
-- TODO: Rename (?)
data Vector num = Vector num num deriving (Eq, Show) -- TODO: Constraints on argument types (cf. GADT) (?)


-- |
data Line num = Line (Vector num) (Vector num) 


-- |
-- TODO: Rename (eg. 'Shape') (?)
type Polygon num = [Vector num]


-- |
data Linear num = Linear { intercept :: num, slope :: num }


-- |
-- type Domain


-- | Determines if a point lies within a polygon using the odd-even method.
--   
-- TODO: Use epsilon (?)
-- TODO: How to treat points that lie on an edge
inside :: Num n => Polygon n -> Vector n -> Bool
inside (p:olygon) (Vector x y) = undefined
	where
		lines   = (p:olygon)++[p] -- Close the loop
		-- between (Line (Vector ax ay) (Vector bx by)) = _



---------------------------------------------------------------------------------------------------
-- Instances
---------------------------------------------------------------------------------------------------
-- | abs v * signum v == v
instance (Floating a, Eq a) => Num (Vector a) where
	-- TODO: Helper method to reduce boilerplate for component-wise operations
	(+) = dotWise (+)
	(-) = dotWise (-)
	(*) = dotWise (*) -- TODO: Is this really correct?
	fromInteger n = Vector (fromInteger n) 0
	signum (Vector 0 0) = Vector 0 0
	signum v@(Vector x y) = Vector (x/mag v) (y/mag v)
	abs a  = Vector (euclidean a a) 0



---------------------------------------------------------------------------------------------------
-- Functions
---------------------------------------------------------------------------------------------------
-- Vector math ------------------------------------------------------------------------------------
-- | Performs component-wise operations
dotWise :: (a -> b -> c) -> Vector a -> Vector b -> Vector c
dotWise f (Vector x y) (Vector x' y') = Vector (f x x') (f y y')


-- | Dot product of two vectors
dot :: Floating a => Vector a -> Vector a -> a
dot (Vector x y) (Vector x' y') = (x * x') + (y * y') -- TODO: Refactor with Num instance (?)


-- | Euclidean distance between two points
euclidean :: Floating a => Vector a -> Vector a -> a
euclidean a b = sqrt $ dot a b


-- |
magnitude :: (Floating a, Eq a) => Vector a -> a
magnitude v = euclidean v v

mag :: (Floating a, Eq a) => Vector a -> a
mag = magnitude 


-- | Angle (in radians) between the positive X-axis and the vector 
argument :: (Floating a, Eq a) => Vector a -> a
argument (Vector 0 0) = 0
argument (Vector x y) = atan $ y/x


arg :: (Floating a, Eq a) => Vector a -> a
arg = argument


-- | Vector -> (magnitude, argument)
polar :: (Floating a, Eq a) => Vector a -> (a, a)
polar v@(Vector x y) = (magnitude v, argument v)


-- Geometry ---------------------------------------------------------------------------------------
-- | Yields the point at which two finite lines intersect. The lines are defined inclusively by
--   their endpoints. The result is wrapped in a Maybe value to account for non-intersecting
--   lines.
--
-- TODO: Move equation solving to separate function (two linear functions)
-- TODO: Simplify logic by considering f(x) = y for vertical lines (?)
-- TODO: Return Either instead of Maybe (eg. Left "parallel") (?)
--
-- TODO: Math notes, MathJax or LaTex
-- TODO: Intersect for curves (functions) and single points (?)
-- TODO: Polymorphic, typeclass (lines, shapes, ranges, etc.) (?)
--
intersect :: RealFrac n => Line n -> Line n -> Maybe (Vector n)
intersect a b
  | (fst $ deltas a) == 0 = Just $ error "Not implemented"
  | (fst $ deltas b) == 0 = Just $ error "Not implemented"
  | slope a == slope b = Nothing
  | otherwise          = Nothing
  where deltas (Line (Vector ax ay) (Vector bx by)) = (bx - ax, by - ay) -- TODO: Rename (eg. deltas) (?)
        vertical (Line (Vector ax _) (Vector bx _)) =  ax == bx
        slope line     = let (dx, dy) = deltas line in dy/dx
        intercept line@(Line (Vector x y) _)
          | vertical line = Nothing
          | otherwise     = Just $ y - slope line * x


-- Geometry ---------------------------------------------------------------------------------------
-- |
-- inside :: (Num n, Ord n) => Triangle n -> Point n -> Bool
-- inside _ _ = False


-- |
intersects :: RealFrac r => Line r -> Line r -> Bool 
intersects a b = case intersect a b of
	Just _  -> True
	Nothing -> False


-- | Yields the overlap of two closed intervals (n ∈ R)
-- TODO: Normalise intervals (eg. (12, 5) -> (5, 12))
overlap :: Real a => (a, a) -> (a, a) -> Maybe (a, a)
overlap a b
	| leftmost /= (α, β) = Just (β, γ) -- 
	| otherwise          = Nothing     -- 
	where [α, β, γ, _] = sort [fst a, snd a, fst b, snd b] -- That's right.
	      leftmost     = minimumBy (comparing fst) [a, b]  --


-- |
-- TODO: Intersect Rectangles



-- | Coefficients for the linear function of a Line (slope, intercept).
-- Fails for vertical and horizontal lines.
--
-- TODO: Use Maybe (?)
-- TODO: Rename (eg. toLinear, function) (?)
--
coefficients :: (Fractional a, Eq a) => Line a -> Maybe (a, a)
coefficients (Line (Vector ax ay) (Vector bx by))
	| ax == bx  = Nothing
	| ay == ay  = Nothing
	| otherwise = let slope' = (by - ay)/(bx - ax) in Just (slope', ay - slope'*ax)


-- Linear functions -------------------------------------------------------------------------------
-- | Solves a linear equation for x (f(x) = g(x))
-- TODO: Use Epsilon (?)
solve :: (Fractional n, Eq n) => Linear n -> Linear n -> Maybe n
solve f g
	| slope f == slope g = Nothing
	| otherwise          = Just $ (intercept f - intercept g)/(slope f - slope g)