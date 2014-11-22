{-# LANGUAGE RebindableSyntax #-}
{-# LANGUAGE RankNTypes #-}

module HaskellReact.ReadFay (
  ReadFay ()
  , RF (RF)
  , rf
  , readFayReturn
  , readFayBind
  , readFayThen
  , runReadFay
  , isMounted
  , state
) where

import qualified Prelude as P
import Prelude hiding((>>=), (>>), return)
import FFI (ffi)
import HaskellReact.ComponentData (ReactThis)

newtype ReadFay a = ReadFay { runReadFay :: Fay a }

data RF = RF { 
  return :: forall a. a -> ReadFay a
  , bind :: forall a b. ReadFay a -> (a -> ReadFay b) -> ReadFay b
  , then' :: forall a b. ReadFay a -> ReadFay b -> ReadFay b
}

readFayReturn :: a -> ReadFay a
readFayReturn a = ReadFay $ P.return a

readFayBind :: ReadFay a -> (a -> ReadFay b) -> ReadFay b
readFayBind a b = ReadFay $ runReadFay a P.>>= (runReadFay . b)

readFayThen :: ReadFay a -> ReadFay b -> ReadFay b
readFayThen a b = ReadFay $ runReadFay a P.>> runReadFay b

rf :: RF
rf = RF {
  return = readFayReturn
  , bind = readFayBind
  , then' = readFayThen
}

isMounted' :: ReactThis a b -> Fay Bool
isMounted' = ffi " %1['isMounted']() "

isMounted :: ReactThis a b -> ReadFay Bool
isMounted = ReadFay . isMounted'

state' :: ReactThis a b -> Fay a
state' = ffi " %1['state'] "

state :: ReactThis a b -> ReadFay a
state = ReadFay . state'

props' :: ReactThis a b -> Fay b
props' = ffi " %1['props'] "

props :: ReactThis a b -> ReadFay b
props = ReadFay . props'

{-
Example usage of the ReadFay in the do notation

doNotation :: ReadFay ()
doNotation = let RF return (>>=) (>>) = rf in do
  b <- return ()
  x <- return ()
  return ()
  return ()
-}
