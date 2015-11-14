-- |
-- Module      : Cartesian.Internal.Lenses
-- Description :
-- Copyright   : (c) Jonatan H Sundqvist, 2015
-- License     : MIT
-- Maintainer  : Jonatan H Sundqvist
-- Stability   : experimental|stable
-- Portability : POSIX (not sure)
--

-- Created October 31 2015

-- TODO | -
--        -

-- SPEC | -
--        -



--------------------------------------------------------------------------------------------------------------------------------------------
-- GHC Pragmas
--------------------------------------------------------------------------------------------------------------------------------------------
{-# LANGUAGE MultiParamTypeClasses #-}
{-# LANGUAGE TemplateHaskell       #-}
{-# LANGUAGE RankNTypes            #-}



--------------------------------------------------------------------------------------------------------------------------------------------
-- API
--------------------------------------------------------------------------------------------------------------------------------------------
module Cartesian.Internal.Lenses where



--------------------------------------------------------------------------------------------------------------------------------------------
-- We'll need these
--------------------------------------------------------------------------------------------------------------------------------------------
import Data.List     (isSuffixOf)
import Control.Monad (mfilter)
import Control.Lens

import Language.Haskell.TH

import Cartesian.Internal.Types
import Cartesian.Internal.Core
import Cartesian.Internal.Utils



--------------------------------------------------------------------------------------------------------------------------------------------
-- Lenses
--------------------------------------------------------------------------------------------------------------------------------------------

-- Vector ----------------------------------------------------------------------------------------------------------------------------------

-- | Focus on the X component
x :: HasX v f => Lens v v f f
x = lens getX setX


-- | Focus on the Y component
y :: HasY v f => Lens v v f f
y = lens getY setY


-- | Focus on the Z component
z :: HasZ v f => Lens v v f f
z = lens getZ setZ

-- BoundingBox -----------------------------------------------------------------------------------------------------------------------------

-- TODO: Relative lenses (eg. padding)
-- TODO: Validate (eg. make sure that left < right)
-- TODO: Type-changing lenses (?)


-- | Ugh...
makeLensesWith (lensRules & lensField .~ (\_ _ name -> [TopName (mkName $ dropSuffix "Of" (nameBase name))])) (''BoundingBox) -- TODO: 'Of'


-- |
-- TODO: Rename (?)
offset :: (Fractional f) => (Getter v f) -> (f -> f -> f) -> BoundingBox v -> f
offset axis towards box = towards (box^.centre.axis) (0.5 * box^.size.axis)

--------------------------------------------------------------------------------------------------------------------------------------------

-- |
-- pad :: f -> (Getter v f) -> f -> BoundingBox v
-- pad by axis direction = _


-- | Moves one side of a BoundingBox along the given 'axis' so that its new position is at 'to'. The 'towards' parameter is expected to be
--   either (-) and (+), indicating which side along the axis we're dealing with.
-- TODO: Turn this into a lens function (?)
-- TODO: Polish description
-- TODO: Loosen constraint on f
side :: (Fractional f) => Lens v v f f -> (f -> f -> f) -> Lens (BoundingBox v) (BoundingBox v) f f
side axis towards = lens get set
  where
    get = offset axis towards
    set box to = let newsize = abs (to - towards centre' (-(box^.size.axis)*0.5))
                     centre' = box^.centre.axis --
                 in BoundingBox { sizeOf=(box^.size) & axis .~ newsize, centreOf=(box^.centre) & axis .~ (to `towards` negate (newsize*0.5)) } -- TODO: Refactor. And then refactor some more.

--------------------------------------------------------------------------------------------------------------------------------------------

width :: (HasX v f) => Lens (BoundingBox v) (BoundingBox v) f f
width = size.x


height :: (HasY v f) => Lens (BoundingBox v) (BoundingBox v) f f
height = size.y


depth :: (HasZ v f) => Lens (BoundingBox v) (BoundingBox v) f f
depth = size.z

-- So much boilerplate it makes me cry -----------------------------------------------------------------------------------------------------

-- type SideLens = (Fractional f, HasX v f) => Lens (BoundingBox v) (BoundingBox v) f f
type SideLens v f = Lens (BoundingBox v) (BoundingBox v) f f


left :: (HasX v f, Fractional f) => SideLens v f
left = side x (-)


right :: (HasX v f, Fractional f) => SideLens v f
right = side x (+)


bottom :: (HasY v f, Fractional f) => SideLens v f
bottom = side y (-)


top :: (HasY v f, Fractional f) => SideLens v f
top = side y (+)


front :: (HasZ v f, Fractional f) => SideLens v f
front = side z (-)


back :: (HasZ v f, Fractional f) => SideLens v f
back = side z (+)
