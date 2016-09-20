-- |
-- Module      : Cartesian.Space.Lenses
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




--------------------------------------------------------------------------------------------------------------------------------------------
-- API
--------------------------------------------------------------------------------------------------------------------------------------------
module Cartesian.Space.Lenses (HasX(..), HasY(..), HasZ(..),
                               left, right,
                               bottom, top,
                               front, back,
                               width, height, depth) where



--------------------------------------------------------------------------------------------------------------------------------------------
-- We'll need these
--------------------------------------------------------------------------------------------------------------------------------------------
import Cartesian.Internal.Types
import Cartesian.Space.Types
import Cartesian.Internal.Lenses



--------------------------------------------------------------------------------------------------------------------------------------------
-- Lenses
--------------------------------------------------------------------------------------------------------------------------------------------
