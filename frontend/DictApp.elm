module DictApp (initialModel, update, view) where

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
import Utils exposing (noFx)


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
    Query "" ->
      {model | query="", entries=[]} |> noFx
    Query query ->
      ({model | query=query}, getEntries model.selectedDict model.selectedQueryMode query)
    ChangeDict dict ->
      ({model | selectedDict=dict}, getEntries dict model.selectedQueryMode model.query)
    ChangeQueryMode mode ->
      ({model | selectedQueryMode=mode}, getEntries model.selectedDict mode model.query)
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

getEntries : Dictionary -> QueryMode -> String -> Effects Action
getEntries dict mode query =
  case query of
    "" ->
      Effects.none
    _ ->
      Http.get entriesDecoder (apiUrl dict mode query)
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
