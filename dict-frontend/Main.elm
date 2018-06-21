module Main where

import DictApp exposing (initialModel, view, update)
import Dictionary exposing (..)
import QueryParams exposing (parseQueryString)
import QueryMode exposing (..)
import DictTypes exposing (..)
import Signal exposing (Signal)
import Html exposing (Html)
import Task exposing (Task)
import Effects exposing (Never)
import StartApp
import String


app =
  StartApp.start {
    init=initialModel,
    view=view,
    update=update,
    inputs=portInputs
  }

main : Signal Html
main = app.html

portInputs : List (Signal Action)
portInputs = [hotkeysInput, queryStringInput]

port tasks : Signal (Task Never ())
port tasks = app.tasks

port queryString : Signal String

port hotkeys : Signal (List String)

queryParametersToAction : List (String, String) -> Action
queryParametersToAction params =
  let
    filterMap : String -> (String -> a) -> a -> a
    filterMap key f default =
      params
        |> List.filter (\(k, _) -> k == key)
        |> List.head
        |> Maybe.map snd
        |> Maybe.map f
        |> Maybe.withDefault default
    dict = filterMap "dict" toDict defaultDict
    mode = filterMap "mode" toQueryMode defaultQueryMode
    query = filterMap "query" identity ""
  in
    Init (dict, mode, query)

queryStringInput : Signal Action
queryStringInput =
  queryString
    |> Signal.map parseQueryString
    |> Signal.map queryParametersToAction

hotkeysInput : Signal Action
hotkeysInput = Signal.map hotkeyToAction hotkeys

hotkeyToAction : List String -> Action
hotkeyToAction keys =
  case keys of
      ["tab"] -> NextDict
      ["shift", "tab"] -> PrevDict
      _ -> NoOp
