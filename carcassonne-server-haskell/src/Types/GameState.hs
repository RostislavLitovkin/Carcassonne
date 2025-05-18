{-# LANGUAGE DeriveGeneric #-}
{-# LANGUAGE DeriveAnyClass #-}

module Types.GameState where

import GHC.Generics (Generic)
import Data.Aeson (ToJSON, FromJSON)

data GameState
  = PlaceTile
  | PlaceMeeple
  | Finished
  deriving (Show, Eq, Generic, ToJSON, FromJSON)