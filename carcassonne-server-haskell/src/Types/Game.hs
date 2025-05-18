{-# LANGUAGE DeriveGeneric #-}
{-# LANGUAGE DeriveAnyClass #-}
{-# LANGUAGE StandaloneDeriving #-}
{-# OPTIONS_GHC -Wno-unrecognised-pragmas #-}

module Types.Game where

import qualified Data.Map as Map
import qualified Data.List as List

import Types.Tile
import Types.GameState
import GHC.Generics (Generic)
import Data.Aeson (ToJSON, FromJSON, ToJSONKey, FromJSONKey)
import Data.Maybe (Maybe(Nothing))
import Types.TileMapper

type PlayerName = String

type PlayerScores = Map.Map PlayerName Int

data Coordinate = Coordinate
  { x :: Int
  , y :: Int
  } deriving (Show, Eq, Ord, Generic, ToJSON, FromJSON)
  
deriving instance ToJSONKey Coordinate
deriving instance FromJSONKey Coordinate

type TileGrid = Map.Map Coordinate Tile

newtype Meeple = Meeple
  { owner :: PlayerName
  -- Add more meeple properties as needed
  } deriving (Show, Eq, Generic, ToJSON, FromJSON)

type MeepleGrid = Map.Map Coordinate Meeple

data Game = Game
  { playerScores     :: PlayerScores
  , players          :: [PlayerName]
  , currentPlayer    :: PlayerName
  , tileToPlace      :: TileId
  , gameState        :: GameState
  , lastPlayedTile   :: Maybe Coordinate
  , tileDrawStack    :: [TileId]
  , tileGrid         :: TileGrid
  , meepleGrid       :: MeepleGrid
  } deriving (Show, Eq, Generic, ToJSON, FromJSON)

initializeGame :: [PlayerName] -> Game
initializeGame players = Game
  { playerScores = Map.fromList $ List.map (\playerName -> (playerName, 0)) players
  , players = players
  , currentPlayer = List.head players
  , tileToPlace = firstTile
  , gameState = PlaceTile
  , lastPlayedTile = Nothing
  , tileDrawStack = drawStack
  , tileGrid = Map.fromList [(
    Coordinate
      { x = 0
      , y = 0
      },
    getTile 0
  )]
  , meepleGrid = Map.empty
  } where (firstTile:drawStack) = initializeDrawStack
  


initializeDrawStack :: [TileId]
initializeDrawStack = [1,1,1]