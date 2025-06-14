module Types.Game exposing (..)

import Dict exposing (Dict)
import Helpers.TileMapper exposing (getTile)
import List
import Types.GameState exposing (..)
import Types.PlayerName exposing (..)
import Types.Tile exposing (..)


type alias Score =
    Int


type alias PlayerScores =
    Dict PlayerName Score


type alias Coordinate =
    ( Int, Int )


type alias TileGrid =
    Dict Coordinate Tile


type alias Meeple =
    { owner : PlayerName

    -- More meeple properties might be useful when adding Carcassonne expansions (Type: Large meeple / pig...)
    }


type alias MeepleGrid =
    Dict Coordinate Meeple


type alias Game =
    { playerScores : PlayerScores
    , players : List PlayerName
    , currentPlayer : PlayerName
    , tileToPlace : Tile
    , gameState : GameState
    , lastPlayedTile : Maybe Coordinate
    , nextSideId : SideId
    , tileDrawStack : List TileId
    , tileGrid : TileGrid
    , meepleGrid : MeepleGrid
    }


{-| Initialize a new game instance with players.

Players list must not be empty

-}
initializeGame : List PlayerName -> Game
initializeGame players =
    let
        currentPlayer =
            case List.head players of
                Just p ->
                    p

                Nothing ->
                    -- Should never happen
                    ""

        ( firstTile, drawStack ) =
            case initializeDrawStack of
                first :: rest ->
                    ( first, rest )

                [] ->
                    -- Should never happen;
                    ( 0, [] )

        tileGrid =
            initializeTileGrid
    in
    { playerScores = Dict.fromList (List.map (\playerName -> ( playerName, 0 )) players)
    , players = players
    , currentPlayer = currentPlayer
    , tileToPlace = getTile firstTile
    , gameState = PlaceTile
    , lastPlayedTile = Nothing
    , nextSideId = getNextSideId tileGrid
    , tileDrawStack = drawStack
    , tileGrid = tileGrid
    , meepleGrid = Dict.empty
    }


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
        |> (+) 1


{-| Initialize a random tile draw stack
-}
initializeDrawStack : List TileId
initializeDrawStack =
    -- TODO: make random
    [ 1, 0, 1, 1, 0 ]
