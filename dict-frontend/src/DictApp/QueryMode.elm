module DictApp.QueryMode exposing (..)

import Json.Decode as JD


type QueryMode
    = Prefix
    | Suffix
    | Regex


toStringLabel : QueryMode -> String
toStringLabel mode =
    case mode of
        Prefix ->
            "Prefix"

        Suffix ->
            "Suffix"

        Regex ->
            "Regex"


toStringValue : QueryMode -> String
toStringValue mode =
    case mode of
        Prefix ->
            "prefix"

        Suffix ->
            "suffix"

        Regex ->
            "regex"


fromString : String -> Maybe QueryMode
fromString str =
    case str of
        "prefix" ->
            Just Prefix

        "suffix" ->
            Just Suffix

        "regex" ->
            Just Regex

        _ ->
            Nothing


allQueryModes : List QueryMode
allQueryModes =
    [ Prefix, Suffix, Regex ]


formatQuery : QueryMode -> String -> String
formatQuery mode query =
    case mode of
        Prefix ->
            "^" ++ query

        Suffix ->
            query ++ "$"

        Regex ->
            query


decodeQueryMode : JD.Decoder QueryMode
decodeQueryMode =
    let
        decode str =
            case fromString str of
                Just queryMode ->
                    JD.succeed queryMode

                Nothing ->
                    JD.fail <| "Unknown queryMode: " ++ str
    in
    JD.andThen decode JD.string
