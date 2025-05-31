module Evergreen.V5.Types.Game exposing (..)

import Dict
import Evergreen.V5.Types.GameState
import Evergreen.V5.Types.PlayerName
import Evergreen.V5.Types.Tile


type alias PlayerScores =
    Dict.Dict Evergreen.V5.Types.PlayerName.PlayerName Int


type alias Coordinate =
    ( Int, Int )


type alias TileGrid =
    Dict.Dict Coordinate Evergreen.V5.Types.Tile.Tile


type alias Meeple =
    { owner : Evergreen.V5.Types.PlayerName.PlayerName
    }


type alias MeepleGrid =
    Dict.Dict Coordinate Meeple


type alias Game =
    { playerScores : PlayerScores
    , players : List Evergreen.V5.Types.PlayerName.PlayerName
    , currentPlayer : Evergreen.V5.Types.PlayerName.PlayerName
    , tileToPlace : Evergreen.V5.Types.Tile.Tile
    , gameState : Evergreen.V5.Types.GameState.GameState
    , lastPlayedTile : Maybe Coordinate
    , nextSideId : Evergreen.V5.Types.Tile.SideId
    , tileDrawStack : List Evergreen.V5.Types.Tile.TileId
    , tileGrid : TileGrid
    , meepleGrid : MeepleGrid
    }
