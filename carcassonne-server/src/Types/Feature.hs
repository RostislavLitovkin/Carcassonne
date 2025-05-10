{-# LANGUAGE DeriveGeneric #-}
{-# LANGUAGE DeriveAnyClass #-}

module Types.Feature (Feature(..)) where 

import GHC.Generics (Generic)
import Data.Aeson (ToJSON, FromJSON)

data Feature
  = City
  | Road
  | Cloister
  deriving (Show, Eq, Generic, ToJSON, FromJSON)