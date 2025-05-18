module Types.Game exposing (..)

import Dict exposing (Dict)
import List exposing (head, map)
-- You need to define Tile, TileId, GameState, and getTile elsewhere

type alias PlayerName =
  String

type alias PlayerScores =
  Dict PlayerName Int

type alias Coordinate =
  { x : Int
  , y : Int
  }

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
  , tileToPlace : TileId
  , gameState : GameState
  , lastPlayedTile : Maybe Coordinate
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
        Just p -> p
        Nothing -> "" -- Should never happen

    (firstTile, drawStack) =
      case initializeDrawStack of
        first :: rest -> ( first, rest )
        [] -> ( 0, [] ) -- Should never happen
  in
  { playerScores =  Dict.fromList (List.map (\playerName -> ( playerName, 0 )) players)
  , players = players
  , currentPlayer = currentPlayer
  , tileToPlace = firstTile
  , gameState = PlaceTile
  , lastPlayedTile = Nothing
  , tileDrawStack = drawStack
  , tileGrid = Dict.fromList [ ( { x = 0, y = 0 }, getTile 0 ) ]
  , meepleGrid = Dict.empty
  }

{-| Initialize a random tile draw stack -}
initializeDrawStack : List TileId
initializeDrawStack =
  [ 1, 1, 1 ] -- TODO: make random
