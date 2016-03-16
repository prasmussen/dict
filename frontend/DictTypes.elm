module DictTypes where

import Dictionary exposing (..)
import QueryMode exposing (..)

type Action
  = NoOp
  | Init (Dictionary, QueryMode, String)
  | NextDict
  | PrevDict
  | Query String
  | ChangeQueryMode QueryMode
  | ChangeDict Dictionary
  | NewEntries (Maybe (List Entry))


type Effect = GetEntries | SetQueryString

type alias Entry = {
    word: String,
    translations: List String
  }

type alias Model = {
    initialized: Bool,
    query: String,
    selectedDict: Dictionary,
    selectedQueryMode: QueryMode,
    entries: List Entry
  }

toChangeDictAction : String -> Action
toChangeDictAction str = ChangeDict (toDict str)

toChangeQueryModeAction : String -> Action
toChangeQueryModeAction str = ChangeQueryMode (toQueryMode str)
