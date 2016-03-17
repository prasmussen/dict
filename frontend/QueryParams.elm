module QueryParams (
    parseQueryString,
    toQueryString
  ) where

import String
import Http exposing (uriEncode, uriDecode)


parseQueryString : String -> List (String, String)
parseQueryString str =
  let
    empty = ("", "")
    toTuple list =
      case list of
        [k, v] -> (k, v)
        _ -> empty
  in
    str
      |> String.dropLeft 1
      |> String.split "&"
      |> List.map (String.split "=")
      |> List.map toTuple
      |> List.filter ((/=) empty)
      |> List.map (\(k, v) -> (uriDecode k, uriDecode v))

toQueryString : List (String, String) -> String
toQueryString params =
  let
    qs =
      params
        |> List.map (\(k, v) -> (uriEncode k, uriEncode v))
        |> List.map (\(k, v) -> k ++ "=" ++ v)
        |> String.join "&"
  in
    if qs == "" then
      "/"
    else
      "/?" ++ qs
