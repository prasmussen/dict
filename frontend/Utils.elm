module Utils (
    noFx,
    onInput,
    onChange
  ) where

import Html exposing (Attribute)
import Html.Events exposing (on, targetValue)
import Signal exposing (Address)
import Effects exposing (Effects)


noFx : a -> (a, Effects b)
noFx model = (model, Effects.none)

onInput : Address a -> (String -> a) -> Attribute
onInput address f =
  on "input" targetValue (\v -> Signal.message address (f v))

onChange : Address a -> (String -> a) -> Attribute
onChange address f =
  on "change" targetValue (\v -> Signal.message address (f v))
