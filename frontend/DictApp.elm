module DictApp (initialModel, update, view, inputs) where

import Html exposing (Html, div)
import String exposing (concat, join)
import Signal exposing (Address)
import Task exposing (Task)
import Json.Decode as Json exposing ((:=))
import Effects exposing (Effects)
import Http

-- Local imports
import DictTypes exposing (..)
import Dictionary exposing (..)
import QueryMode exposing (..)
import DictHtml exposing (pageHeader, pageBody)
import Utils exposing (noFx, nextElement, prevElement)


initialModel : (Model, Effects Action)
initialModel = {
    query="",
    selectedDict=defaultDict,
    selectedQueryMode=defaultQueryMode,
    entries=[]
  } |> noFx


update : Action -> Model -> (Model, Effects Action)
update action model =
  case action of
    NoOp ->
      model |> noFx
    NextDict ->
      let
        newModel = {model | selectedDict=nextElement model.selectedDict allDicts}
      in
        (newModel, getEntries newModel)
    PrevDict ->
      let
        newModel = {model | selectedDict=prevElement model.selectedDict allDicts}
      in
        (newModel, getEntries newModel)
    Query "" ->
      {model | query="", entries=[]} |> noFx
    Query query ->
      let
        newModel = {model | query=query}
      in
        (newModel, getEntries newModel)
    ChangeDict dict ->
      let
        newModel = {model | selectedDict=dict}
      in
        (newModel, getEntries newModel)
    ChangeQueryMode mode ->
      let
        newModel = {model | selectedQueryMode=mode}
      in
        (newModel, getEntries newModel)
    NewEntries (Just entries) ->
      {model | entries=entries} |> noFx
    NewEntries Nothing ->
      {model | entries=[]} |> noFx

view : Address Action -> Model -> Html
view address model =
  let
    dicts = List.take 4 allDicts
  in
    div [] [
      pageHeader address model dicts,
      pageBody address model
    ]

inputs = []

getEntries : Model -> Effects Action
getEntries model =
  case model.query of
    "" ->
      Effects.none
    query ->
      Http.get entriesDecoder (apiUrl model.selectedDict model.selectedQueryMode query)
        |> Task.toMaybe
        |> Task.map NewEntries
        |> Effects.task

entriesDecoder : Json.Decoder (List Entry)
entriesDecoder =
  Json.list <| Json.object2 Entry
      ("word" := Json.string)
      ("translations" := Json.list Json.string)

apiUrl : Dictionary -> QueryMode -> String -> String
apiUrl dict mode query =
  ["", "api", "dictionaries", dictValue dict, queryModeQuery mode query]
    |> List.map Http.uriEncode
    |> join "/"
