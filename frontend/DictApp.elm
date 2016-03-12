module DictApp (initialModel, update, view) where

import Html exposing (Html, div)
import String exposing (concat, join)
import Signal exposing (Address)
import Task exposing (Task)
import Json.Decode as Json exposing ((:=))
import Effects exposing (Effects)
import Http

-- Local imports
import Dictionary exposing (..)
import QueryMode exposing (..)
import DictTypes exposing (..)
import DictHtml exposing (..)
import Utils exposing (..)


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
  div [] [
    pageHeader address model headerDicts,
    pageBody address model
  ]

headerDicts : List Dictionary
headerDicts = List.take 4 allDicts

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
  let
    q =
      case mode of
        Prefix -> "^" ++ query
        Suffix -> query ++ "$"
        Regex -> query
  in
    List.map Http.uriEncode ["", "api", "dictionaries", dictValue dict, q]
      |> join "/"
