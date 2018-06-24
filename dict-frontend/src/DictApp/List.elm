module DictApp.List exposing (..)

import List.Extra as ListE
import Maybe.Extra as MaybeE


nextElement : a -> List a -> a
nextElement current list =
    let
        maybeIndex =
            ListE.elemIndex current list

        maybeNext =
            Maybe.andThen (\i -> ListE.getAt (i + 1) list) maybeIndex

        maybeFirst =
            List.head list
    in
    MaybeE.or maybeNext maybeFirst
        |> Maybe.withDefault current


prevElement : a -> List a -> a
prevElement current list =
    let
        maybeIndex =
            ListE.elemIndex current list

        maybePrev =
            Maybe.andThen (\i -> ListE.getAt (i - 1) list) maybeIndex

        maybeLast =
            ListE.last list
    in
    MaybeE.or maybePrev maybeLast
        |> Maybe.withDefault current
