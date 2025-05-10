module Types.TileMapper where

import Types.Tile

getTile :: TileId -> Tile
getTile 0 = Tile
  { tileId = 0
  , rotation = 0
  , north = Side
    { sideId = 0
    , sideFeature = City
    }
  , east = Side
    { sideId = 1
    , sideFeature = Road
    }
  , south = Side
    { sideId = -1
    , sideFeature = Field
    }
  , west = Side
    { sideId = 1
    , sideFeature = Road
    }
  , hasCloister = False
  }

