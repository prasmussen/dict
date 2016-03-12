module DictApp (initialModel, update, view) where

import Html exposing (..)
import Html.Attributes exposing (..)
import Html.Events exposing (..)
import String exposing (concat, join)
import Signal exposing (Address)
import Utils exposing (noFx, onInput, onChange)
import Dictionary exposing (..)
import QueryMode exposing (..)

import Task exposing (Task)
import Json.Decode as Json exposing ((:=))
import Effects exposing (Effects)
import Http


type alias Entry = {
    word: String,
    translations: List String
  }

type alias Model = {
    query: String,
    selectedDict: Dictionary,
    selectedQueryMode: QueryMode,
    entries: List Entry
  }

initialModel : (Model, Effects Action)
initialModel = {
    query="",
    selectedDict=defaultDict,
    selectedQueryMode=defaultQueryMode,
    entries=[]
  } |> noFx


toChangeDictAction : String -> Action
toChangeDictAction str = ChangeDict (toDict str)

toChangeQueryModeAction : String -> Action
toChangeQueryModeAction str = ChangeQueryMode (toQueryMode str)

type Action
  = Query String
  | ChangeQueryMode QueryMode
  | ChangeDict Dictionary
  | NewEntries (Maybe (List Entry))

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


headerTab address selectedDict dict =
  a [
    classList [
      ("header-tab", True),
      ("is-active", dict == selectedDict)
    ],
    onClick address (ChangeDict dict)
  ] [text (dictLabel dict)]

queryElement address model =
  div [class "query"] [
    p [class "control is-grouped"] [
      span [class "select"] [dictDropdown address model.selectedDict allDicts],
      searchInput address,
      span [class "select"] [queryModeDropdown address model.selectedQueryMode allQueryModes]
    ]
  ]

searchInput address =
  input [
    class "input is-large",
    type' "text",
    placeholder "Query",
    autofocus True,
    Utils.onInput address Query
  ] []

dictDropdownOptionElement : Dictionary -> Dictionary -> Html
dictDropdownOptionElement selectedDict dict =
  option [
    value (dictValue dict),
    selected (dict == selectedDict)
  ] [text (dictLabel dict)]

queryModeDropdownOptionElement : QueryMode -> QueryMode -> Html
queryModeDropdownOptionElement selectedMode mode =
  option [
    value (queryModeValue mode),
    selected (mode == selectedMode)
  ] [text (queryModeLabel mode)]

dictDropdown : Address Action -> Dictionary -> List Dictionary -> Html
dictDropdown address selectedDict dicts =
  select [
    class "query-dropdown",
    Utils.onChange address toChangeDictAction
  ] (List.map (dictDropdownOptionElement selectedDict) dicts)

queryModeDropdown : Address Action -> QueryMode -> List QueryMode -> Html
queryModeDropdown address selectedMode modes =
  select [
    class "query-dropdown",
    Utils.onChange address toChangeQueryModeAction
  ] (List.map (queryModeDropdownOptionElement selectedMode) modes)

entriesElement : List Entry -> Html
entriesElement entries =
  div [class "entries"] (List.map entryElement entries)

entryElement : Entry -> Html
entryElement t =
  div [class "entry"] [
    p [class "title is-4"] [
      a [] [text t.word]
    ],
    p [class "subtitle is-6"] [concat t.translations |> text]
  ]

tabBarDicts : List Dictionary
tabBarDicts = List.take 4 allDicts

pageHeader : Address Action -> Model -> Html
pageHeader address model =
  let tabs =
    List.map (headerTab address model.selectedDict) tabBarDicts
  in
    header [class "header"] [
      div [class "container"] [
        div [class "header-left"] tabs
      ]
    ]

pageBody : Address Action -> Model -> Html
pageBody address model =
  div [class "container content"] [
    queryElement address model,
    entriesElement model.entries
  ]

view : Address Action -> Model -> Html
view address model =
  div [] [
    pageHeader address model,
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
  let
    q =
      case mode of
        Prefix -> "^" ++ query
        Suffix -> query ++ "$"
        Regex -> query
  in
    List.map Http.uriEncode ["", "api", "dictionaries", dictValue dict, q]
      |> join "/"
