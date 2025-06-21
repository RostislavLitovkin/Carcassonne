module Evergreen.V10.Types.Game exposing (..)

import Array
import Dict
import Evergreen.V10.Types.Coordinate
import Evergreen.V10.Types.GameState
import Evergreen.V10.Types.Meeple
import Evergreen.V10.Types.PlayerIndex
import Evergreen.V10.Types.PlayerName
import Evergreen.V10.Types.Score
import Evergreen.V10.Types.Tile


type alias PlayerScores =
    Dict.Dict Evergreen.V10.Types.PlayerName.PlayerName Evergreen.V10.Types.Score.Score


type alias TileGrid =
    Dict.Dict Evergreen.V10.Types.Coordinate.Coordinate Evergreen.V10.Types.Tile.Tile


type alias Meeples =
    Dict.Dict Evergreen.V10.Types.Tile.SideId (List Evergreen.V10.Types.Meeple.Meeple)


type alias Game =
    { playerScores : PlayerScores
    , playerMeeples : Dict.Dict Evergreen.V10.Types.PlayerName.PlayerName Int
    , players : Array.Array Evergreen.V10.Types.PlayerName.PlayerName
    , currentPlayer : Evergreen.V10.Types.PlayerIndex.PlayerIndex
    , tileToPlace : Evergreen.V10.Types.Tile.Tile
    , gameState : Evergreen.V10.Types.GameState.GameState
    , lastPlacedTile : Evergreen.V10.Types.Coordinate.Coordinate
    , nextSideId : Evergreen.V10.Types.Tile.SideId
    , tileDrawStack : List Evergreen.V10.Types.Tile.TileId
    , tileGrid : TileGrid
    , meeples : Meeples
    }
