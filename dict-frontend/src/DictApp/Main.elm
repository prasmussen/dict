module DictApp.Main exposing (main)

import Dict
import DictApp.Dictionary as Dictionary
import DictApp.Entry as Entry
import DictApp.Program as Program
import DictApp.QueryMode as QueryMode
import Dom
import Erl.Query as Query
import Html exposing (..)
import Html.Attributes exposing (..)
import Html.Events exposing (..)
import Http
import Json.Decode as JD
import Maybe.Extra as MaybeE
import Navigation
import Task


type alias Model =
    { dictionary : Dictionary.Dictionary
    , queryMode : QueryMode.QueryMode
    , searchQuery : String
    , entries : List Entry.Entry
    }


type alias AppFlags =
    { dictionary : Dictionary.Dictionary
    , queryMode : QueryMode.QueryMode
    , searchQuery : String
    }



-- TODO: move to AppFlags


decodeAppFlags : JD.Decoder AppFlags
decodeAppFlags =
    JD.map3 AppFlags
        (JD.field "dictionary" Dictionary.decodeDictionary)
        (JD.field "queryMode" QueryMode.decodeQueryMode)
        (JD.field "queryString" JD.string)


type Msg
    = LocationChange Navigation.Location
    | SetDictionary Dictionary.Dictionary
    | SetQueryMode QueryMode.QueryMode
    | SetSearchQuery String
    | LoadEntries (Result Http.Error (List Entry.Entry))


main =
    Program.programWithFlags
        LocationChange
        { init = init
        , subscriptions = subscriptions
        , update = update
        , view = view
        }
        decodeAppFlags


init : AppFlags -> Navigation.Location -> ( Result String Model, Cmd Msg )
init appFlags location =
    let
        initialModel =
            { dictionary = dictionary
            , queryMode = queryMode
            , searchQuery = searchQuery
            , entries = []
            }

        queryDict =
            case Query.parse location.search of
                Ok query ->
                    Dict.fromList query

                Err err ->
                    Dict.empty
                        |> Debug.log (toString err)

        dictionary =
            Dict.get "dict" queryDict
                |> Maybe.map Dictionary.fromString
                |> MaybeE.join
                |> Maybe.withDefault appFlags.dictionary

        queryMode =
            Dict.get "queryMode" queryDict
                |> Maybe.map QueryMode.fromString
                |> MaybeE.join
                |> Maybe.withDefault appFlags.queryMode

        searchQuery =
            Dict.get "query" queryDict
                |> Maybe.withDefault appFlags.searchQuery
    in
    ( Ok initialModel, Cmd.none )


subscriptions : Model -> Sub Msg
subscriptions model =
    Sub.none


onChangeQueryMode : (QueryMode.QueryMode -> msg) -> Attribute msg
onChangeQueryMode tagger =
    let
        decoder =
            JD.at [ "target", "value" ] QueryMode.decodeQueryMode
    in
    on "change" (JD.map tagger decoder)


onChangeDictionary : (Dictionary.Dictionary -> msg) -> Attribute msg
onChangeDictionary tagger =
    let
        decoder =
            JD.at [ "target", "value" ] Dictionary.decodeDictionary
    in
    on "change" (JD.map tagger decoder)


update : Msg -> Model -> ( Model, Cmd Msg )
update msg model =
    case msg of
        LocationChange location ->
            ( model, Cmd.none )

        SetDictionary dict ->
            { model | dictionary = dict }
                |> loadEntries

        SetQueryMode queryMode ->
            { model | queryMode = queryMode }
                |> loadEntries

        SetSearchQuery searchQuery ->
            if String.isEmpty searchQuery then
                ( { model | searchQuery = "", entries = [] }, Cmd.none )
            else
                { model | searchQuery = searchQuery }
                    |> loadEntries

        LoadEntries result ->
            case result of
                Ok entries ->
                    ( { model | entries = entries }, Cmd.none )

                Err err ->
                    ( model, Cmd.none )


loadEntries : Model -> ( Model, Cmd Msg )
loadEntries model =
    let
        req =
            Entry.getEntries model.dictionary model.queryMode model.searchQuery
    in
    ( model, Http.send LoadEntries req )


view : Model -> Html Msg
view model =
    let
        prioritizedDicts =
            List.take 4 Dictionary.allDicts
    in
    div [ id "dict-app" ]
        [ pageHeader model prioritizedDicts
        , pageBody model
        ]


pageHeader : Model -> List Dictionary.Dictionary -> Html Msg
pageHeader model dicts =
    let
        tabs =
            List.map (headerTab model.dictionary) dicts
    in
    header [ class "header" ]
        [ div [ class "container" ]
            [ div [ class "header-left" ] tabs
            ]
        ]


pageBody : Model -> Html Msg
pageBody model =
    div [ class "container content" ]
        [ queryElement model
        , entriesElement model.entries
        ]


headerTab : Dictionary.Dictionary -> Dictionary.Dictionary -> Html Msg
headerTab selectedDict dict =
    a
        [ classList
            [ ( "header-tab", True )
            , ( "is-active", dict == selectedDict )
            ]
        , onClick (SetDictionary dict)
        ]
        [ text (Dictionary.toStringLabel dict) ]


queryElement : Model -> Html Msg
queryElement model =
    div [ class "query" ]
        [ p [ class "control is-grouped" ]
            [ span [ class "select" ] [ dictDropdown model.dictionary Dictionary.allDicts ]
            , queryInputElement model
            , span [ class "select" ] [ queryModeDropdown model.queryMode QueryMode.allQueryModes ]
            ]
        ]


queryInputElement : Model -> Html Msg
queryInputElement model =
    input
        [ class "input is-large"
        , type_ "text"
        , placeholder "Query"
        , autofocus True
        , value model.searchQuery
        , onInput SetSearchQuery
        ]
        []


dictDropdown : Dictionary.Dictionary -> List Dictionary.Dictionary -> Html Msg
dictDropdown selectedDict dicts =
    select
        [ class "query-dropdown"
        , onChangeDictionary SetDictionary
        ]
        (List.map (dictDropdownOption selectedDict) dicts)


queryModeDropdown : QueryMode.QueryMode -> List QueryMode.QueryMode -> Html Msg
queryModeDropdown selectedMode modes =
    select
        [ class "query-dropdown"
        , onChangeQueryMode SetQueryMode
        ]
        (List.map (queryModeDropdownOption selectedMode) modes)


dictDropdownOption : Dictionary.Dictionary -> Dictionary.Dictionary -> Html Msg
dictDropdownOption selectedDict dict =
    option
        [ value (Dictionary.toStringValue dict)
        , selected (dict == selectedDict)
        ]
        [ text (Dictionary.toStringLabel dict) ]


queryModeDropdownOption : QueryMode.QueryMode -> QueryMode.QueryMode -> Html Msg
queryModeDropdownOption selectedMode mode =
    option
        [ value (QueryMode.toStringValue mode)
        , selected (mode == selectedMode)
        ]
        [ text (QueryMode.toStringLabel mode) ]


entriesElement : List Entry.Entry -> Html Msg
entriesElement entries =
    div [ class "entries" ] (List.map entryRow entries)


entryRow : Entry.Entry -> Html Msg
entryRow entry =
    let
        translation t =
            p [ class "translation" ] [ text t ]
    in
    div [ class "entry" ]
        [ p [ class "title is-4" ] [ text entry.word ]
        , p [ class "subtitle is-6" ] (List.map translation entry.translations)
        ]
