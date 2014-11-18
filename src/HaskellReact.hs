{-# LANGUAGE EmptyDataDecls #-}
{-# LANGUAGE FlexibleInstances #-}
{-# LANGUAGE PackageImports #-}

module HaskellReact where

import FFI
import "fay-base" Data.Text (Text, pack)
import Prelude hiding (id, span)

type URL = Text
type Rel = Text
type Target = Text

data AAttributes = AAttributes {
  href :: Defined URL
  , rel :: Defined Rel
  , target :: Defined Target
}

class CommonJSModule a

foreignReact :: (CommonJSModule b, Renderable c)
             => Automatic b -> String -> Automatic a -> Automatic c -> ReactInstance
foreignReact = ffi " %1[%2](%3, %4) "

foreignReact' :: (CommonJSModule b, Renderable c)
              => Automatic b -> String -> Automatic a -> [Automatic c] -> ReactInstance
foreignReact' = ffi " %1[%2](%3, %4) "


aAttributesDefaults :: AAttributes
aAttributesDefaults = AAttributes Undefined Undefined Undefined

a :: (Renderable x) => Attributes -> AAttributes -> x -> DOMElement
a = ffi " require('../files/ReactWrapper').constructDOMElement(\"a\", %1, Fay$$_(%3), %2) "

span' :: (Renderable a) => Attributes -> Automatic a -> DOMElement
span' = ffi " require('../files/ReactWrapper').constructDOMElement(\"span\", %1, %2) "

span :: (Renderable x) => x -> DOMElement
span = span' defaultAttributes

div' :: (Renderable a) => Attributes -> [Automatic a] -> DOMElement
div' = ffi " require('../files/ReactWrapper').constructDOMElement(\"div\", %1, %2) "

div :: (Renderable a) => [Automatic a] -> DOMElement
div = div' defaultAttributes

li' :: (Renderable x) => Attributes -> Automatic x -> DOMElement
li' = ffi " require('../files/ReactWrapper').constructDOMElement(\"li\", %1, %2) "

li :: (Renderable x) => Automatic x -> DOMElement
li = li' defaultAttributes

ul' :: (Renderable x) => Attributes -> [Automatic x] -> DOMElement
ul' = ffi " require('../files/ReactWrapper').constructDOMElement(\"ul\", %1, %2) "

ul :: (Renderable x) => [Automatic x] -> DOMElement
ul = ul' defaultAttributes

data SyntheticEvent

eventValue :: SyntheticEvent -> Fay String
eventValue = ffi " %1['target']['value'] "

phantom :: a -> b
phantom = ffi " %1 "

textElement :: String -> DOMElement
textElement = phantom . pack

data ReactClass
data ReactThis a
data SyntheticMouseEvent
data DOMElement
data ReactInstance

class Renderable a

instance (Renderable a) => Renderable [a]
instance Renderable Text
instance Renderable DOMElement

-- | Unsafely create a html tag
constructDOMElement :: (Renderable a) 
                    => String -- name of tag
                    -> Attributes -- html attributes common for all elements
                    -> Automatic b -- tag specific attributes
                    -> Automatic a -- child
                    -> DOMElement
constructDOMElement = ffi " require('../files/ReactWrapper').constructDOMElement(%1, %2, %4, %3) "

data ReactData a = ReactData {
  render :: ReactThis a -> Fay DOMElement
  , componentWillMount :: ReactThis a -> Fay()
  , componentDidMount :: ReactThis a -> Fay()
  , componentWillUnmount :: ReactThis a -> Fay()
  , displayName :: String
  , getInitialState :: a
}

defaultReactData :: a -> ReactData a
defaultReactData initialState = ReactData {
  render = const $ return $ constructDOMElement "div" defaultAttributes (NoAttributes {}) (pack "")
  , componentWillMount = const $ return ()
  , componentDidMount = const $ return ()
  , componentWillUnmount = const $ return ()
  , displayName = "<HaskellReactClass>"
  , getInitialState = initialState
}

data NoAttributes = NoAttributes {}

data Attributes = Attributes {
  className :: Defined String
  , onClick :: Defined ( SyntheticMouseEvent -> Fay() )
  , id :: Defined String
}

defaultAttributes :: Attributes
defaultAttributes = Attributes {
  className = Undefined
  , onClick = Undefined
  , id = Undefined
}

declareReactClass :: ReactData a -> ReactClass
declareReactClass = ffi " require('../files/ReactWrapper').declareReactClass(%1) "

declareAndRun :: ReactData a -> ReactInstance
declareAndRun = classInstance . declareReactClass

setState :: ReactThis a -> a -> Fay ()
setState = ffi " %1['setState'](Fay$$_(%2)) "

state :: ReactThis a -> Fay a
state = ffi " %1['state'] "

isMounted :: ReactThis a -> Fay Bool
isMounted = ffi " %1['isMounted']() "

classInstance :: ReactClass -> ReactInstance
classInstance = ffi " %1(null) "

placeElement :: ReactInstance -> Fay ()
placeElement = ffi " require('../files/ReactWrapper').renderReact(%1) "

getType :: SyntheticMouseEvent -> String
getType = ffi " %1['type'] "
