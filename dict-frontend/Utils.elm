module Utils (
    nextElement,
    prevElement,
    noFx,
    onInput,
    onChange
  ) where

import Html exposing (Attribute)
import Html.Events exposing (on, targetValue)
import Signal exposing (Address)
import Effects exposing (Effects)
import List.Extra exposing (elemIndex, getAt, last)
import Maybe exposing (andThen, oneOf, withDefault)


noFx : a -> (a, Effects b)
noFx model = (model, Effects.none)

onInput : Address a -> (String -> a) -> Attribute
onInput address f =
  on "input" targetValue (\v -> Signal.message address (f v))

onChange : Address a -> (String -> a) -> Attribute
onChange address f =
  on "change" targetValue (\v -> Signal.message address (f v))

nextElement : a -> List a -> a
nextElement current list =
  let
    mIndex = elemIndex current list
    mNext = andThen mIndex (\i -> getAt list (i + 1))
    mFirst = List.head list
  in
    withDefault current <| oneOf [mNext, mFirst]

prevElement : a -> List a -> a
prevElement current list =
  let
    mIndex = elemIndex current list
    mPrev = andThen mIndex (\i -> getAt' list (i - 1))
    mLast = last list
  in
    withDefault current <| oneOf [mPrev, mLast]

getAt' : List a -> Int -> Maybe a
getAt' list index =
  if index < 0 then Nothing else getAt list index
