{-# LANGUAGE PackageImports #-}
{-# LANGUAGE RebindableSyntax #-}
{-# LANGUAGE OverloadedStrings #-}
{-# LANGUAGE NoImplicitPrelude #-}

module HaskellReact.Tag.Input (
  InputAttributes(..) ,
  defaultInputAttributes ,
  mkInputAttrs ,
  input ,
  textarea ,
  InputType ,
  button ,
  checkbox ,
  color ,
  date ,
  datetime ,
  datetimeLocal ,
  email ,
  file ,
  hidden ,
  image ,
  month ,
  number ,
  password ,
  radio ,
  range ,
  reset ,
  search ,
  submit ,
  tel ,
  text ,
  time ,
  url ,
  week ) where

import "fay-base" FFI
import "fay-base" Prelude
import "fay-base" Data.Text (Text, fromString)

import HaskellReact.Tag.Construct
import HaskellReact.Event

newtype InputType = InputType Text
  deriving Eq

button :: InputType
button = InputType "button"

checkbox :: InputType
checkbox = InputType "checkbox"

color :: InputType
color = InputType "color"

date :: InputType
date = InputType "date"

datetime :: InputType
datetime = InputType "datetime"

datetimeLocal :: InputType
datetimeLocal = InputType "datetime-local"

email :: InputType
email = InputType "email"

file :: InputType
file = InputType "file"

hidden :: InputType
hidden = InputType "hidden"

image :: InputType
image = InputType "image"

month :: InputType
month = InputType "month"

number :: InputType
number = InputType "number"

password :: InputType
password = InputType "password"

radio :: InputType
radio = InputType "radio"

range :: InputType
range = InputType "range"

reset :: InputType
reset = InputType "reset"

search :: InputType
search = InputType "search"

submit :: InputType
submit = InputType "submit"

tel :: InputType
tel = InputType "tel"

text :: InputType
text = InputType "text"

time :: InputType
time = InputType "time"

url :: InputType
url = InputType "url"

week :: InputType
week = InputType "week"


data InputAttributes = InputAttributes {
  type_ :: InputType , 
  value_ :: Defined Text , 
  defaultValue :: Defined Text , 
  checked :: Defined Text , 
  onChange :: Defined (SyntheticEvent -> Fay ()) ,
  disabled_ :: Defined Text ,
  name :: Defined Text }

mkInputAttrs :: InputAttributes
mkInputAttrs = defaultInputAttributes

defaultInputAttributes :: InputAttributes
defaultInputAttributes = InputAttributes {
  type_ = text ,
  value_ = Undefined ,
  checked = Undefined ,
  onChange = Undefined ,
  defaultValue = Undefined ,
  disabled_ = Undefined ,
  name = Undefined }

input' :: (Renderable a) => Attributes -> InputAttributes -> a -> DOMElement
input' = constructDOMElement "input"

input :: Attributes -> InputAttributes -> DOMElement
input a i = input' a i ([]::[DOMElement])

textarea :: Attributes -> InputAttributes -> Text -> DOMElement
textarea aAttrs iAttrs text' = constructDOMElement "textarea" aAttrs iAttrs text'
