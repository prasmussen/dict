module DictApp.Program exposing (programWithFlags)

import Html exposing (Html)
import Json.Decode as JD
import Navigation exposing (Location)


programWithFlags :
    (Location -> msg)
    ->
        { init : options -> Location -> ( model, Cmd msg )
        , update : msg -> model -> ( model, Cmd msg )
        , subscriptions : model -> Sub msg
        , view : model -> Html msg
        }
    -> JD.Decoder options
    -> Program JD.Value (Result String model) msg
programWithFlags onNavigation { init, update, subscriptions, view } decodeFlags =
    let
        initWrapper : JD.Value -> Location -> ( Result String model, Cmd msg )
        initWrapper flags location =
            case JD.decodeValue decodeFlags flags of
                Ok options ->
                    let
                        ( model, cmd ) =
                            init options location
                    in
                    ( Ok model, cmd )

                Err err ->
                    ( Err err, Cmd.none )

        subscriptionsWrapper : Result String model -> Sub msg
        subscriptionsWrapper resultModel =
            case resultModel of
                Ok model ->
                    subscriptions model

                Err _ ->
                    Sub.none

        updateWrapper : msg -> Result String model -> ( Result String model, Cmd msg )
        updateWrapper msg resultModel =
            case resultModel of
                Ok model ->
                    let
                        ( newModel, cmd ) =
                            update msg model
                    in
                    ( Ok newModel, cmd )

                Err err ->
                    ( Err err, Cmd.none )

        viewWrapper : Result String model -> Html msg
        viewWrapper resultModel =
            case resultModel of
                Ok model ->
                    view model

                Err err ->
                    Html.div [] [ Html.text err ]
    in
    Navigation.programWithFlags
        onNavigation
        { init = initWrapper
        , subscriptions = subscriptionsWrapper
        , update = updateWrapper
        , view = viewWrapper
        }
