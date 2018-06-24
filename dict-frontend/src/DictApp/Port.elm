port module DictApp.Port exposing (..)


port nextDict : ({} -> msg) -> Sub msg


port prevDict : ({} -> msg) -> Sub msg
