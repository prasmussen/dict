module DictHtml (
    pageHeader,
    pageBody
  ) where

import Html exposing (..)
import Html.Attributes exposing (..)
import Html.Events exposing (..)
import String exposing (concat)
import Signal exposing (Address)

import Utils exposing (..)
import Dictionary exposing (..)
import QueryMode exposing (..)
import DictTypes exposing (..)

pageHeader : Address Action -> Model -> List Dictionary -> Html
pageHeader address model dicts =
  let tabs =
    List.map (headerTab address model.selectedDict) dicts
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

headerTab : Address Action -> Dictionary -> Dictionary -> Html
headerTab address selectedDict dict =
  a [
    classList [
      ("header-tab", True),
      ("is-active", dict == selectedDict)
    ],
    onClick address (ChangeDict dict)
  ] [text (dictLabel dict)]

queryElement : Address Action -> Model -> Html
queryElement address model =
  div [class "query"] [
    p [class "control is-grouped"] [
      span [class "select"] [dictDropdown address model.selectedDict allDicts],
      queryInputElement address,
      span [class "select"] [queryModeDropdown address model.selectedQueryMode allQueryModes]
    ]
  ]

queryInputElement : Address Action -> Html
queryInputElement address =
  input [
    class "input is-large",
    type' "text",
    placeholder "Query",
    autofocus True,
    onInput address Query
  ] []

dictDropdown : Address Action -> Dictionary -> List Dictionary -> Html
dictDropdown address selectedDict dicts =
  select [
    class "query-dropdown",
    onChange address toChangeDictAction
  ] (List.map (dictDropdownOption selectedDict) dicts)

queryModeDropdown : Address Action -> QueryMode -> List QueryMode -> Html
queryModeDropdown address selectedMode modes =
  select [
    class "query-dropdown",
    onChange address toChangeQueryModeAction
  ] (List.map (queryModeDropdownOption selectedMode) modes)

dictDropdownOption : Dictionary -> Dictionary -> Html
dictDropdownOption selectedDict dict =
  option [
    value (dictValue dict),
    selected (dict == selectedDict)
  ] [text (dictLabel dict)]

queryModeDropdownOption : QueryMode -> QueryMode -> Html
queryModeDropdownOption selectedMode mode =
  option [
    value (queryModeValue mode),
    selected (mode == selectedMode)
  ] [text (queryModeLabel mode)]

entriesElement : List Entry -> Html
entriesElement entries =
  div [class "entries"] (List.map entryRow entries)

entryRow : Entry -> Html
entryRow entry =
  let
    translation t = p [class "translation"] [text t]
  in
    div [class "entry"] [
      p [class "title is-4"] [text entry.word],
      p [class "subtitle is-6"] (List.map translation entry.translations)
    ]
