module Dictionary where

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

dictLabel : Dictionary -> String
dictLabel dict =
  case dict of
    NO_UK -> "NO-UK"
    UK_NO -> "UK-NO"
    NO_NO -> "NO-NO"
    UK_UK -> "UK-UK"
    NO_DE -> "NO-DE"
    DE_NO -> "DE-NO"
    UK_FR -> "UK-FR"
    FR_UK -> "FR-UK"
    UK_ES -> "UK-ES"
    ES_UK -> "ES-UK"
    UK_SE -> "UK-SE"
    SE_UK -> "SE-UK"
    NO_ME -> "NO-ME"

dictValue : Dictionary -> String
dictValue dict =
  case dict of
    NO_UK -> "no_uk"
    UK_NO -> "uk_no"
    NO_NO -> "no_no"
    UK_UK -> "uk_uk"
    NO_DE -> "no_de"
    DE_NO -> "de_no"
    UK_FR -> "uk_fr"
    FR_UK -> "fr_uk"
    UK_ES -> "uk_es"
    ES_UK -> "es_uk"
    UK_SE -> "uk_se"
    SE_UK -> "se_uk"
    NO_ME -> "no_me"

toDict : String -> Dictionary
toDict str =
  case str of
   "no_uk" -> NO_UK
   "uk_no" -> UK_NO
   "no_no" -> NO_NO
   "uk_uk" -> UK_UK
   "no_de" -> NO_DE
   "de_no" -> DE_NO
   "uk_fr" -> UK_FR
   "fr_uk" -> FR_UK
   "uk_es" -> UK_ES
   "es_uk" -> ES_UK
   "uk_se" -> UK_SE
   "se_uk" -> SE_UK
   "no_me" -> NO_ME
   _ -> defaultDict

defaultDict : Dictionary
defaultDict = NO_UK

allDicts : List Dictionary
allDicts = [
    NO_UK,
    UK_NO,
    NO_NO,
    UK_UK,
    NO_DE,
    DE_NO,
    UK_FR,
    FR_UK,
    UK_ES,
    ES_UK,
    UK_SE,
    SE_UK,
    NO_ME
  ]
