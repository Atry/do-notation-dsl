{-# LANGUAGE MultiParamTypeClasses #-}
{-# LANGUAGE FlexibleInstances #-}
{-# LANGUAGE RebindableSyntax #-}
{-# LANGUAGE GADTs #-}
{-# LANGUAGE RankNTypes #-}

{- |
Description : Mutable variables

This module provides the ability to 'Put' and 'Get' the value of multiple mutable variables in a @do@ block.

>>> :set -XTypeApplications
>>> :set -XRebindableSyntax
>>> import Prelude hiding ((>>), (>>=), return)
>>> import Control.Dsl
>>> import Data.Sequence

>>> :set -fprint-potential-instances
>>> :{
formatter :: Double -> Integer -> Seq String -> String
formatter = do
  --
  -- Equivalent of `!Put(!Get[Vector[Any]] :+ "x=")` in Dsl.scala
  tmpBuffer0 <- Get @(Seq String)
  Put $ tmpBuffer0 |> "x="
  --
  -- Equivalent of `!Put(!Get[Vector[Any]] :+ !Get[Double])` in Dsl.scala
  tmpBuffer1 <- Get @(Seq String)
  d <- Get @Double
  Put $ tmpBuffer1 |> show d
  --
  -- Equivalent of `!Put(!Get[Vector[Any]] :+ ",y=")` in Dsl.scala
  tmpBuffer2 <- Get @(Seq String)
  Put $ tmpBuffer2 |> ",y="
  --
  -- Equivalent of `!Put(!Get[Vector[Any]] :+ !Get[Int])` in Dsl.scala
  tmpBuffer3 <- Get @(Seq String)
  i <- Get @Integer
  Put $ tmpBuffer3 |>  show i
  --
  -- Equivalent of `!Return((!Get[Vector[Any]]).mkString)` in Dsl.scala
  tmpBuffer4 <- Get @(Seq String)
  return $ foldl1 (++) tmpBuffer4
:}

>>> formatter 0.5 42 Empty
"x=0.5,y=42"
-}
module Control.Dsl.State where

import Prelude hiding ((>>), (>>=), return)
import Control.Dsl.Dsl

type State a b = a -> b

data Put a r u where
  Put :: a -> Put a r ()

instance Dsl (Put a) (State a b) () where
  cpsApply (Put a) f _ = f () a

data Get r a where
  Get :: forall a r. Get r a

instance Dsl Get (State a b) a where
  cpsApply Get f a = f a a
