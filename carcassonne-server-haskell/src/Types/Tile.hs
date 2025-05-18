{-# LANGUAGE DeriveGeneric #-}
{-# LANGUAGE DeriveAnyClass #-}

module Types.Tile where

import GHC.Generics (Generic)
import Data.Aeson (ToJSON, FromJSON)

type TileId = Int

data Feature = Road | City | Field
  deriving (Show, Eq, Enum, Bounded, Generic, ToJSON, FromJSON)

data Side = Side
  { sideId    :: Int
  , sideFeature :: Feature
  } deriving (Show, Eq, Generic, ToJSON, FromJSON)

data Tile = Tile
  { tileId      :: TileId
  , rotation    :: Int
  , north       :: Side
  , east        :: Side
  , south       :: Side
  , west        :: Side
  , hasCloister :: Bool
  } deriving (Show, Eq, Generic, ToJSON, FromJSON)