module DictApp.Entry exposing (..)

import DictApp.Dictionary as Dictionary
import DictApp.QueryMode as QueryMode
import Http
import Json.Decode as JD


type alias Entry =
    { word : String
    , translations : List String
    }


getEntries : Dictionary.Dictionary -> QueryMode.QueryMode -> String -> Http.Request (List Entry)
getEntries dict queryMode searchQuery =
    Http.request
        { method =
            "GET"
        , headers =
            []
        , url =
            String.join "/"
                [ ""
                , "api"
                , "dictionaries"
                , Dictionary.toStringValue dict
                , QueryMode.formatQuery queryMode searchQuery
                ]
        , body =
            Http.emptyBody
        , expect =
            Http.expectJson (JD.list decodeEntry)
        , timeout =
            Nothing
        , withCredentials =
            False
        }


decodeEntry : JD.Decoder Entry
decodeEntry =
    JD.map2 Entry
        (JD.field "word" JD.string)
        (JD.field "translations" (JD.list JD.string))
