module Evergreen.V3.Types.Game exposing (..)

import Dict
import Evergreen.V3.Types.GameState
import Evergreen.V3.Types.PlayerName
import Evergreen.V3.Types.Tile


type alias PlayerScores =
    Dict.Dict Evergreen.V3.Types.PlayerName.PlayerName Int


type alias Coordinate =
    ( Int, Int )


type alias TileGrid =
    Dict.Dict Coordinate Evergreen.V3.Types.Tile.Tile


type alias Meeple =
    { owner : Evergreen.V3.Types.PlayerName.PlayerName
    }


type alias MeepleGrid =
    Dict.Dict Coordinate Meeple


type alias Game =
    { playerScores : PlayerScores
    , players : List Evergreen.V3.Types.PlayerName.PlayerName
    , currentPlayer : Evergreen.V3.Types.PlayerName.PlayerName
    , tileToPlace : Evergreen.V3.Types.Tile.Tile
    , gameState : Evergreen.V3.Types.GameState.GameState
    , lastPlayedTile : Maybe Coordinate
    , nextSideId : Evergreen.V3.Types.Tile.SideId
    , tileDrawStack : List Evergreen.V3.Types.Tile.TileId
    , tileGrid : TileGrid
    , meepleGrid : MeepleGrid
    }
