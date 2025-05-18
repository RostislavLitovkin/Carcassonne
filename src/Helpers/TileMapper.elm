module Helpers.TileMapper exposing (getTile)

import Types.Tile exposing (Tile, TileId, Side, SideFeature(..))

getTile : TileId -> Tile
getTile 0 =
  { tileId = 0
  , rotation = 0
  , north = { sideId = 0, sideFeature = City }
  , east = { sideId = 1, sideFeature = Road }
  , south = { sideId = -1, sideFeature = Field }
  , west = { sideId = 1, sideFeature = Road }
  , hasCloister = False
  }
