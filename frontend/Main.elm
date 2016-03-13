module Main where

import DictApp exposing (initialModel, view, update, inputs)
import DictTypes exposing (..)
import Signal exposing (Signal)
import Html exposing (Html)
import Task exposing (Task)
import Effects exposing (Never)
import StartApp


app =
  StartApp.start {
    init=initialModel,
    view=view,
    update=update,
    inputs=inputs ++ [portInputs]
  }

main : Signal Html
main = app.html


port tasks : Signal (Task Never ())
port tasks = app.tasks

port hotkeys : Signal (List String)

portInputs : Signal Action
portInputs = Signal.map hotkeyToAction hotkeys

hotkeyToAction : List String -> Action
hotkeyToAction keys =
  case keys of
      ["tab"] -> NextDict
      ["shift", "tab"] -> PrevDict
      _ -> NoOp
