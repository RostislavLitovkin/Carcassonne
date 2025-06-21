module Types.GameState exposing (..)


type GameState
    = PlaceTileState
    | PlaceMeepleState
    | FinishedState


toString : GameState -> String
toString state =
    case state of
        PlaceTileState ->
            "Place tile"

        PlaceMeepleState ->
            "Place meeple"

        FinishedState ->
            "Finished"
