{-# LANGUAGE EmptyDataDecls #-}
{-# LANGUAGE PackageImports #-}
{-# LANGUAGE NoImplicitPrelude #-}

module HaskellReact.Event where

import "fay-base" Data.Text (Text, unpack)
import "fay-base" FFI (ffi)
import "fay-base" Prelude

data DOMEventTarget

data SyntheticEvent
data SyntheticMouseEvent

class AnyEvent a
instance AnyEvent SyntheticMouseEvent
instance AnyEvent SyntheticEvent

eventValue :: SyntheticEvent -> Fay Text
eventValue = ffi " %1['target']['value'] "

preventDefault :: (AnyEvent a) => a -> Fay ()
preventDefault = ffi " %1['preventDefault']() "

stopPropagation :: (AnyEvent a) => a -> Fay ()
stopPropagation = ffi " %1['stopPropagation']() "

target :: (AnyEvent a) => a -> Fay DOMEventTarget
target = ffi " %1['target'] "

getType :: SyntheticMouseEvent -> Fay Text
getType = ffi " %1['type'] "

eventString :: SyntheticEvent -> Fay String
eventString event = do
  text <- eventValue event
  return $ unpack text
