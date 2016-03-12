module Main where

import DictApp exposing (initialModel, view, update)
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
    inputs=[]
  }

main : Signal Html
main = app.html

port tasks : Signal (Task Never ())
port tasks = app.tasks
