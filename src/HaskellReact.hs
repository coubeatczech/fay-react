{-# LANGUAGE EmptyDataDecls #-}
{-# LANGUAGE FlexibleInstances #-}
{-# LANGUAGE PackageImports #-}

module HaskellReact where

import FFI
import "fay-base" Data.Text (Text, append, showInt, pack)
import "fay-base" Data.Maybe (fromMaybe)

data DOMElement
data ReactClass

data InnerData = InnerData {
  companyName :: Text
  , anything :: Int
}
data SetState a

data ReactData a = ReactData {
  render :: (a, SetState a) -> DOMElement
  , componentDidMount :: Fay()
  , displayName :: String
  , getInitialState :: a
}

data Attributes = Attributes {
  className :: String
  , onClick :: SyntheticMouseEvent -> Fay()
}

data SyntheticMouseEvent

declareReactClass :: ReactData a -> ReactClass
declareReactClass = ffi " declareReactClass(%1) "

setState :: SetState a -> a -> Fay()
setState = ffi " %1(Fay$$_(%2)) "

class Renderable a

instance Renderable Text
instance Renderable DOMElement

constructDOMElement :: (Renderable a) => String -> Attributes -> a -> DOMElement
constructDOMElement = ffi " constructDOMElement(%1, %2, Fay$$_(%3)) "

constructDOMElementArray :: String -> Attributes -> [DOMElement] -> DOMElement
constructDOMElementArray = ffi "constructDOMElement(%*)"

classInstance :: ReactClass -> DOMElement
classInstance = ffi " %1(null) "

placeElement :: DOMElement -> Fay ()
placeElement = ffi " renderReact(%1) "

data DifferentInnerData = DifferentInnerData {
  header :: Maybe Text
}

getType :: SyntheticMouseEvent -> String
getType = ffi " %1['type'] "

differentClass :: DOMElement
differentClass = let
  dd = DifferentInnerData $ Just $ pack "Big header"
  attr ss = Attributes "" (\event -> do
    let type' = getType event
    putStrLn type'
    setState ss (DifferentInnerData $ Just $ pack type')
    )
  data' = ReactData {
    render = \(state, ss) -> constructDOMElement "h1" (attr ss) (fromMaybe (pack "default") (header state))
    , componentDidMount = return ()
    , displayName = "SpanClass2"
    , getInitialState = dd
  }
  element = classInstance (declareReactClass data')
  in element

main :: Fay ()
main = placeElement (constructDOMElement "div" (Attributes "blue" (const $ return ())) differentClass)
