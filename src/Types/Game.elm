module Types.Game exposing (..)

import Array exposing (Array)
import Dict exposing (Dict)
import Helpers.TileMapper exposing (getTile)
import List
import Types.Coordinate exposing (Coordinate)
import Types.GameState exposing (..)
import Types.Meeple exposing (..)
import Types.PlayerIndex exposing (..)
import Types.PlayerName exposing (..)
import Types.Score exposing (Score)
import Types.Tile exposing (..)


type alias PlayerScores =
    Dict PlayerName Score


type alias TileGrid =
    Dict Coordinate Tile


type alias Meeples =
    Dict SideId (List Meeple)


type alias Game =
    { playerScores : PlayerScores
    , playerMeeples : Dict PlayerName Int
    , players : Array PlayerName
    , currentPlayer : PlayerIndex
    , tileToPlace : Tile
    , gameState : GameState
    , lastPlacedTile : Coordinate
    , nextSideId : SideId
    , tileDrawStack : List TileId
    , tileGrid : TileGrid
    , meeples : Meeples
    }


playerLimit : PlayerIndex
playerLimit =
    5


{-| Initialize a new game instance with players.

Players list must not be empty

-}
initializeGame : List PlayerName -> Game
initializeGame players =
    let
        tileGrid =
            initializeTileGrid
    in
    { playerScores = Dict.fromList (List.map (\playerName -> ( playerName, 0 )) players)
    , playerMeeples = Dict.fromList (List.map (\playerName -> ( playerName, 7 )) players)
    , players = Array.fromList players
    , currentPlayer = 0

    -- Will get replaced by random tile anyways
    , tileToPlace = getTile 0
    , gameState = PlaceTileState
    , lastPlacedTile = ( 0, 0 )
    , nextSideId = getNextSideId tileGrid
    , tileDrawStack = initializeDrawStack
    , tileGrid = tileGrid
    , meeples = Dict.empty
    }


{-| Returns next player index
-}
getNextPlayer : Game -> PlayerIndex
getNextPlayer game =
    if game.currentPlayer + 1 == Array.length game.players then
        0

    else
        game.currentPlayer + 1


{-| Returns the last placed tile
-}
getLastPlacedTile : Game -> Tile
getLastPlacedTile game =
    game.tileGrid
        |> Dict.get game.lastPlacedTile
        -- Should never happen
        |> Maybe.withDefault (getTile 0)


{-| Initializes the tile grid

  - Expansions can change this

-}
initializeTileGrid : TileGrid
initializeTileGrid =
    Dict.fromList [ ( ( 0, 0 ), getTile 0 ) ]


{-| Helper function useful when implementing other expansions that use a different starting piece
-}
getNextSideId : TileGrid -> SideId
getNextSideId tileGrid =
    tileGrid
        |> Dict.values
        |> List.map getTileMaximumSideId
        |> List.maximum
        |> Maybe.withDefault 0


{-| Initialize tile draw stack
-}
initializeDrawStack : List TileId
initializeDrawStack =
    List.concat
        [ List.repeat 3 0
        , List.repeat 9 1
        , List.repeat 8 2
        , List.repeat 4 3
        , List.repeat 2 4
        , List.repeat 1 5
        , List.repeat 3 6
        , List.repeat 1 7
        , List.repeat 1 8
        , List.repeat 2 9
        , List.repeat 3 10
        , List.repeat 5 11
        , List.repeat 3 12
        , List.repeat 2 13
        , List.repeat 2 14
        , List.repeat 1 15
        , List.repeat 2 16
        , List.repeat 3 17
        , List.repeat 2 18
        , List.repeat 3 19
        , List.repeat 3 20
        , List.repeat 3 21
        , List.repeat 4 22
        , List.repeat 1 23
        ]
