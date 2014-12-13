{-# LANGUAGE PackageImports #-}
{-# LANGUAGE NoImplicitPrelude #-}

module HaskellReact.Component (
  ReactData (componentWillMount, componentDidMount, componentWillUnmount, displayName)
  , ReactClass
  , ReactThis
  , ReactInstance
  , reactData
  , declareReactClass
  , statelessReactData
  , declareStateless
  , declareAndRun
  , setState
  , classInstance, classInstance'
  , placeElementToBody
  , CommonJSModule
  , foreignReact
  , simpleReact, simpleReactBody
) where

import FFI (ffi, Automatic)
import HaskellReact.Tag.Construct
import HaskellReact.ReadFay (ReadFay, runReadFay)
import HaskellReact.ComponentData (ReactThis, ReactClass, ReactInstance)
import "fay-base" Prelude
import "fay-base" Data.Text (Text)
import DOM (Element, getBody)
import "fay-base" Data.Function (fmap)

data ReactData a b = ReactData {
  render                 :: ReactThis a b -> Fay DOMElement -- ^ only enable applying read functions to the state instance, forbid setting the state and such
  , componentWillMount   :: ReactThis a b -> Fay ()
  , componentDidMount    :: ReactThis a b -> Fay ()
  , componentWillUnmount :: ReactThis a b -> Fay ()
  , displayName          :: Text
  , getInitialState      :: () -> a
}

-- | Constructor for creating ReactData
reactData :: Text -- ^ name of the component displayed in debugging
          -> a -- ^ initial state of the component
          -> (ReactThis a b -> ReadFay DOMElement) -- render function
          -> ReactData a b
reactData debugName initialState safeRender = ReactData {
  render = runReadFay . safeRender
  , componentWillMount = const $ return ()
  , componentDidMount = const $ return ()
  , componentWillUnmount = const $ return ()
  , displayName = debugName
  , getInitialState = const $ initialState
}

statelessReactData :: Text
                   -> (ReactThis () b -> ReadFay DOMElement) -- | Render function
                   -> ReactData () b -- | React class
statelessReactData debugName render' = reactData debugName () render'

declareStateless :: Text
                 -> (ReactThis () b -> ReadFay DOMElement) -- | Render function
                 -> Fay (ReactClass b)
declareStateless debugName = declareReactClass . statelessReactData debugName

declareReactClass :: ReactData a b -> Fay (ReactClass b)
declareReactClass = ffi "\
\ (function(data) {\
  \ var React = require('react');\
  \ return React.createClass({\
    \ render: function() {\
      \ return data.render(this);\
    \ }\
    \ , componentWillMount: function () { return data.componentWillMount(this); }\
    \ , componentDidMount: function () { return data.componentDidMount(this); }\
    \ , componentWillUnmount: function () {\
      \ return data.componentWillUnmount(this); \
    \ }\
    \ , displayName: data.displayName\
    \ , getInitialState: data.getInitialState\
  \ });\
\ })(%1)\
\ "

declareAndRun :: ReactData a b -> Fay ReactInstance
declareAndRun data' = fmap classInstance (declareReactClass data')

setState :: ReactThis a b -> Automatic a -> Fay ()
setState = ffi " %1['setState'](%2) "

-- | Create propless react instance
classInstance :: ReactClass a -> ReactInstance
classInstance = ffi " (function () { return require('react')['createElement'](%1); })() "

-- | Pass the props to the React Class
classInstance' :: ReactClass a -- | React class to instantiate
               -> Automatic a -- | Props
               -> ReactInstance
classInstance' = ffi " (function () { return require('react')['createElement'](%1, %2); })() "

-- | Place react element into the real DOM
placeElement :: ReactInstance -- ^ element to render
             -> Element -- ^ point, where the element should be rendered
             -> Fay ()
placeElement = ffi "\
\ (function(component) {\
  \ var React = require('react');\
  \ React.render (\
    \ component, %2\
  \ );\
\ })(%1)\
\ "

-- | Renders the React component into document body
placeElementToBody :: ReactInstance -- ^ element to render
                   -> Fay ()
placeElementToBody reactInstance = do
  body <- getBody
  placeElement reactInstance body

class CommonJSModule a

foreignReact :: (CommonJSModule b, Renderable c)
             => Automatic b -- ^ module imported with CommonJS's @require()@
             -> Text -- ^ name of the property in the module
             -> Automatic a -- ^ props passed to the React class
             -> Automatic c -- ^ children passed to the React class
             -> ReactInstance
foreignReact = ffi "\
  \ (function () {\
    \ var attributes = %3;\
    \ var escapedAttributes = {};\
    \ for (key in attributes) {\
      \ var newKey = (key.charAt(key.length - 1) == '_' ? key.substring(0, key.length - 1) : key);\
      \ escapedAttributes[newKey] = attributes[key];\
    \ }\
    \ return (require('react')['createElement'])(%1[%2], escapedAttributes, %4);\
  \ })()\
\ "

simpleReactBody' :: DOMElement
                 -> Fay ()
                 -> Fay ()
simpleReactBody' elementToRender callbacks = do
  body <- getBody
  simpleReact elementToRender body callbacks

simpleReactBody :: DOMElement
                -> Fay ()
simpleReactBody element = simpleReactBody' element (return ())

simpleReact :: DOMElement -- ^ element to render
            -> Element -- ^ point in document where to place the element
            -> Fay () -- ^ callback to call after the virtual dom is rendered in the browser
            -> Fay ()
simpleReact = ffi " require('react').render(%1, %2, %3) "
