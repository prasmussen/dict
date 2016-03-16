module DictApp (initialModel, update, view) where

import Html exposing (Html, div)
import String
import Signal exposing (Address)
import Task exposing (Task)
import Json.Decode as Json exposing ((:=))
import Effects exposing (Effects)
import Http
import History

-- Local imports
import DictTypes exposing (..)
import Dictionary exposing (..)
import QueryMode exposing (..)
import QueryParams exposing (toQueryString)
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
  let
    (newModel, effects) = updateModel action model
    effect = prepareEffects newModel effects
  in
    (newModel, effect)

updateModel : Action -> Model -> (Model, List Effect)
updateModel action model =
  case action of
    NoOp ->
      (model, [])
    Init (dict, mode, query) ->
      ({model | selectedDict=dict, selectedQueryMode=mode, query=query}, [GetEntries, SetQueryString])
    NextDict ->
      let
        dict = nextElement model.selectedDict allDicts
      in
        ({model | selectedDict=dict}, [GetEntries, SetQueryString])
    PrevDict ->
      let
        dict = prevElement model.selectedDict allDicts
      in
        ({model | selectedDict=dict}, [GetEntries, SetQueryString])
    ChangeDict dict ->
      ({model | selectedDict=dict}, [GetEntries, SetQueryString])
    ChangeQueryMode mode ->
      ({model | selectedQueryMode=mode}, [GetEntries, SetQueryString])
    Query "" ->
      ({model | query="", entries=[]}, [SetQueryString])
    Query query ->
      ({model | query=query}, [GetEntries, SetQueryString])
    NewEntries (Just entries) ->
      ({model | entries=entries}, [])
    NewEntries Nothing ->
      ({model | entries=[]}, [])

prepareEffects : Model -> List Effect -> Effects Action
prepareEffects model effects =
  case effects of
    [] ->
      Effects.none
    _ ->
      effects
        |> List.map (prepareEffect model)
        |> Effects.batch

prepareEffect : Model -> Effect -> Effects Action
prepareEffect model effect =
  let
    dict = model.selectedDict
    mode = model.selectedQueryMode
    query = model.query
  in
    case effect of
      GetEntries ->
        getEntries dict mode query
      SetQueryString ->
        setQueryString dict mode query

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

setQueryString : Dictionary -> QueryMode -> String -> Effects Action
setQueryString dict mode query =
  let
    params =
      [
        ("dict", dictValue dict),
        ("mode", queryModeValue mode),
        ("query", query)
      ]
  in
    History.replacePath (toQueryString params)
      |> taskToNoop
      |> Effects.task

taskToNoop : Task x a -> Task y Action
taskToNoop task =
  Task.map (\_ -> NoOp) task `Task.onError` (\_ -> Task.succeed NoOp)

entriesDecoder : Json.Decoder (List Entry)
entriesDecoder =
  Json.list <| Json.object2 Entry
      ("word" := Json.string)
      ("translations" := Json.list Json.string)

apiUrl : Dictionary -> QueryMode -> String -> String
apiUrl dict mode query =
  ["", "api", "dictionaries", dictValue dict, queryModeQuery mode query]
    |> List.map Http.uriEncode
    |> String.join "/"
