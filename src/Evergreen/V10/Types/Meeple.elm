module Evergreen.V10.Types.Meeple exposing (..)

import Evergreen.V10.Types.Coordinate
import Evergreen.V10.Types.PlayerIndex


type MeeplePosition
    = Center
    | North
    | East
    | South
    | West
    | Skip


type alias Meeple =
    { owner : Evergreen.V10.Types.PlayerIndex.PlayerIndex
    , coordinates : Evergreen.V10.Types.Coordinate.Coordinate
    , position : MeeplePosition
    }
