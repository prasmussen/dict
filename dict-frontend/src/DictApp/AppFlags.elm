module DictApp.AppFlags exposing (..)

import DictApp.Dictionary as Dictionary
import DictApp.QueryMode as QueryMode
import Json.Decode as JD


type alias AppFlags =
    { dictionary : Dictionary.Dictionary
    , queryMode : QueryMode.QueryMode
    , searchQuery : String
    }


decodeAppFlags : JD.Decoder AppFlags
decodeAppFlags =
    JD.map3 AppFlags
        (JD.field "dictionary" Dictionary.decodeDictionary)
        (JD.field "queryMode" QueryMode.decodeQueryMode)
        (JD.field "queryString" JD.string)
