module DictApp where

import Html exposing (..)
import Html.Attributes exposing (..)
import Html.Events exposing (..)
import String exposing (concat, join)
import Signal exposing (Address)
import StartApp
import Utils exposing (noFx, onInput, onChange)

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


type Dictionary
  = NO_UK
  | UK_NO
  | NO_NO
  | UK_UK
  | NO_DE
  | DE_NO
  | UK_FR
  | FR_UK
  | UK_ES
  | ES_UK
  | UK_SE
  | SE_UK
  | NO_ME

dictLabel : Dictionary -> String
dictLabel dict =
  case dict of
    NO_UK -> "NO-UK"
    UK_NO -> "UK-NO"
    NO_NO -> "NO-NO"
    UK_UK -> "UK-UK"
    NO_DE -> "NO-DE"
    DE_NO -> "DE-NO"
    UK_FR -> "UK-FR"
    FR_UK -> "FR-UK"
    UK_ES -> "UK-ES"
    ES_UK -> "ES-UK"
    UK_SE -> "UK-SE"
    SE_UK -> "SE-UK"
    NO_ME -> "NO-ME"

dictValue : Dictionary -> String
dictValue dict =
  case dict of
    NO_UK -> "no_uk"
    UK_NO -> "uk_no"
    NO_NO -> "no_no"
    UK_UK -> "uk_uk"
    NO_DE -> "no_de"
    DE_NO -> "de_no"
    UK_FR -> "uk_fr"
    FR_UK -> "fr_uk"
    UK_ES -> "uk_es"
    ES_UK -> "es_uk"
    UK_SE -> "uk_se"
    SE_UK -> "se_uk"
    NO_ME -> "no_me"

toDict : String -> Dictionary
toDict str =
  case str of
   "no_uk" -> NO_UK
   "uk_no" -> UK_NO
   "no_no" -> NO_NO
   "uk_uk" -> UK_UK
   "no_de" -> NO_DE
   "de_no" -> DE_NO
   "uk_fr" -> UK_FR
   "fr_uk" -> FR_UK
   "uk_es" -> UK_ES
   "es_uk" -> ES_UK
   "uk_se" -> UK_SE
   "se_uk" -> SE_UK
   "no_me" -> NO_ME
   _ -> defaultDict

toChangeDictAction : String -> Action
toChangeDictAction str = ChangeDict (toDict str)

type QueryMode
  = Prefix
  | Suffix
  | Regex

queryModeLabel : QueryMode -> String
queryModeLabel mode =
  case mode of
    Prefix -> "Prefix"
    Suffix -> "Suffix"
    Regex -> "Regex"

queryModeValue : QueryMode -> String
queryModeValue mode =
  case mode of
    Prefix -> "prefix"
    Suffix -> "suffix"
    Regex -> "regex"

toQueryMode : String -> QueryMode
toQueryMode str =
  case str of
   "prefix" -> Prefix
   "suffix" -> Suffix
   "regex" -> Regex
   _ -> defaultQueryMode

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

defaultDict : Dictionary
defaultDict = NO_UK

defaultQueryMode : QueryMode
defaultQueryMode = Prefix

tabBarDicts : List Dictionary
tabBarDicts = List.take 4 allDicts

allDicts : List Dictionary
allDicts = [
    NO_UK,
    UK_NO,
    NO_NO,
    UK_UK,
    NO_DE,
    DE_NO,
    UK_FR,
    FR_UK,
    UK_ES,
    ES_UK,
    UK_SE,
    SE_UK,
    NO_ME
  ]

allQueryModes : List QueryMode
allQueryModes = [Prefix, Suffix, Regex]

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


app =
  StartApp.start {
    init=initialModel,
    view=view,
    update=update,
    inputs=[]
  }

main : Signal Html
main = app.html

port tasks : Signal (Task.Task Effects.Never ())
port tasks = app.tasks
