module Styles exposing (..)

import Html exposing (Attribute)
import Html.Attributes exposing (style)


container : List (Html.Attribute msg)
container =
    [ style "max-width" "400px"
    , style "margin" "3em auto"
    , style "padding" "2em"
    , style "background" "#fff"
    , style "border-radius" "12px"
    , style "box-shadow" "0 4px 24px rgba(74,144,226,0.08)"
    , style "font-family" "Roboto, Arial, sans-serif"
    ]


inputBox : List (Html.Attribute msg)
inputBox =
    [ style "padding" "0.6em 1em"
    , style "border" "1px solid #bfc9d1"
    , style "border-radius" "6px"
    , style "font-size" "1em"
    , style "margin-right" "0.5em"
    , style "outline" "none"
    , style "background" "#fff"
    ]


buttonMain : List (Html.Attribute msg)
buttonMain =
    [ style "padding" "0.6em 1.2em"
    , style "background" "#4a90e2"
    , style "color" "#fff"
    , style "border" "none"
    , style "border-radius" "6px"
    , style "font-size" "1em"
    , style "font-weight" "700"
    , style "cursor" "pointer"
    , style "transition" "background 0.2s"
    , style "margin" "5px"
    ]


playerList : List (Html.Attribute msg)
playerList =
    [ style "list-style" "none"
    , style "padding" "0"
    , style "margin" "1em 0 0 0"
    ]


playerItem : List (Html.Attribute msg)
playerItem =
    [ style "background" "#fff"
    , style "margin-bottom" "0.5em"
    , style "padding" "0.7em 1em"
    , style "border-radius" "5px"
    , style "box-shadow" "0 1px 3px rgba(0,0,0,0.04)"
    ]


errorBox : List (Html.Attribute msg)
errorBox =
    [ style "color" "#d8000c"
    , style "background" "#ffd2d2"
    , style "border" "1px solid #d8000c"
    , style "border-radius" "5px"
    , style "padding" "0.7em 1em"
    , style "margin" "1em 0"
    , style "font-weight" "700"
    ]
