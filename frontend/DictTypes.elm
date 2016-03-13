module DictTypes where

import Dictionary exposing (..)
import QueryMode exposing (..)

type Action
  = NoOp
  | NextDict
  | PrevDict
  | Query String
  | ChangeQueryMode QueryMode
  | ChangeDict Dictionary
  | NewEntries (Maybe (List Entry))

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

toChangeDictAction : String -> Action
toChangeDictAction str = ChangeDict (toDict str)

toChangeQueryModeAction : String -> Action
toChangeQueryModeAction str = ChangeQueryMode (toQueryMode str)
