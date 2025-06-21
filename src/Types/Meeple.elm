module Types.Meeple exposing (..)

import Dict exposing (..)
import Types.Coordinate exposing (Coordinate)
import Types.PlayerIndex exposing (PlayerIndex)


type MeeplePosition
    = Center
    | North
    | East
    | South
    | West
    | Skip


type alias Meeple =
    { owner : PlayerIndex
    , coordinates : Coordinate
    , position : MeeplePosition

    -- More meeple properties might be useful when adding Carcassonne expansions (Type: Large meeple / pig...)
    }


meepleColorDictionary : Dict Int String
meepleColorDictionary =
    Dict.fromList
        [ ( 0, "red" )
        , ( 1, "blue" )
        , ( 2, "green" )
        , ( 3, "yellow" )
        , ( 4, "black" )
        ]


getMeepleImageSource : Int -> String
getMeepleImageSource playerIndex =
    meepleColorDictionary
        |> Dict.get playerIndex
        |> Maybe.map (\color -> "/" ++ color ++ ".png")
        |> Maybe.withDefault "/black.png"
