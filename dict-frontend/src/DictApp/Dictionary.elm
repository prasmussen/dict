module DictApp.Dictionary exposing (..)

import Json.Decode as JD


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


toStringLabel : Dictionary -> String
toStringLabel dict =
    case dict of
        NO_UK ->
            "NO-UK"

        UK_NO ->
            "UK-NO"

        NO_NO ->
            "NO-NO"

        UK_UK ->
            "UK-UK"

        NO_DE ->
            "NO-DE"

        DE_NO ->
            "DE-NO"

        UK_FR ->
            "UK-FR"

        FR_UK ->
            "FR-UK"

        UK_ES ->
            "UK-ES"

        ES_UK ->
            "ES-UK"

        UK_SE ->
            "UK-SE"

        SE_UK ->
            "SE-UK"

        NO_ME ->
            "NO-ME"


toStringValue : Dictionary -> String
toStringValue dict =
    case dict of
        NO_UK ->
            "no_uk"

        UK_NO ->
            "uk_no"

        NO_NO ->
            "no_no"

        UK_UK ->
            "uk_uk"

        NO_DE ->
            "no_de"

        DE_NO ->
            "de_no"

        UK_FR ->
            "uk_fr"

        FR_UK ->
            "fr_uk"

        UK_ES ->
            "uk_es"

        ES_UK ->
            "es_uk"

        UK_SE ->
            "uk_se"

        SE_UK ->
            "se_uk"

        NO_ME ->
            "no_me"


fromString : String -> Maybe Dictionary
fromString str =
    case str of
        "no_uk" ->
            Just NO_UK

        "uk_no" ->
            Just UK_NO

        "no_no" ->
            Just NO_NO

        "uk_uk" ->
            Just UK_UK

        "no_de" ->
            Just NO_DE

        "de_no" ->
            Just DE_NO

        "uk_fr" ->
            Just UK_FR

        "fr_uk" ->
            Just FR_UK

        "uk_es" ->
            Just UK_ES

        "es_uk" ->
            Just ES_UK

        "uk_se" ->
            Just UK_SE

        "se_uk" ->
            Just SE_UK

        "no_me" ->
            Just NO_ME

        _ ->
            Nothing


allDicts : List Dictionary
allDicts =
    [ NO_UK
    , UK_NO
    , NO_NO
    , UK_UK
    , NO_DE
    , DE_NO
    , UK_FR
    , FR_UK
    , UK_ES
    , ES_UK
    , UK_SE
    , SE_UK
    , NO_ME
    ]


decodeDictionary : JD.Decoder Dictionary
decodeDictionary =
    let
        decode str =
            case fromString str of
                Just dictionary ->
                    JD.succeed dictionary

                Nothing ->
                    JD.fail <| "Unknown dictionary: " ++ str
    in
    JD.andThen decode JD.string
