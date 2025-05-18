module Types.Tile exposing (..)

import Types.Feature (Feature)

type alias TileId = Int

type alias Side =
  { sideId : Int
  , sideFeature : Feature
  }

type alias Tile =
  { tileId : TileId
  , rotation : Int
  , north : Side
  , east : Side
  , south : Side
  , west : Side
  , hasCloister : Bool
  }
