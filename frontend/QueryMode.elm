module QueryMode where

type QueryMode
  = Prefix
  | Suffix
  | Regex

queryModeLabel : QueryMode -> String
queryModeLabel mode =
  case mode of
    Prefix -> "Prefix"
    Suffix -> "Suffix"
    Regex -> "Regex"

queryModeValue : QueryMode -> String
queryModeValue mode =
  case mode of
    Prefix -> "prefix"
    Suffix -> "suffix"
    Regex -> "regex"

toQueryMode : String -> QueryMode
toQueryMode str =
  case str of
   "prefix" -> Prefix
   "suffix" -> Suffix
   "regex" -> Regex
   _ -> defaultQueryMode

defaultQueryMode : QueryMode
defaultQueryMode = Prefix

allQueryModes : List QueryMode
allQueryModes = [Prefix, Suffix, Regex]

queryModeQuery : QueryMode -> String -> String
queryModeQuery mode query =
  case mode of
    Prefix -> "^" ++ query
    Suffix -> query ++ "$"
    Regex -> query
