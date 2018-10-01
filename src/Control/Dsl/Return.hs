{-# LANGUAGE MultiParamTypeClasses #-}
{-# LANGUAGE FlexibleInstances #-}
{-# LANGUAGE FlexibleContexts #-}
{-# LANGUAGE UndecidableInstances #-}
{-# LANGUAGE ExistentialQuantification #-}
{-# LANGUAGE RebindableSyntax #-}
{-# LANGUAGE GADTs #-}

module Control.Dsl.Return where

import Prelude (Applicative, pure, ($))
import Control.Dsl.Internal.Dsl
import Control.Dsl.Cont
import Data.Void

data Return a b where
  Return :: a -> Return a Void

instance Dsl (Return a) Void a where
  cpsApply (Return a) _ = a

return :: Dsl (Return a) Void d => a -> d
return x = cpsApply (Return x) absurd
