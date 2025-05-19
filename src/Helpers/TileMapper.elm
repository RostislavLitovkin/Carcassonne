module Helpers.TileMapper exposing (getTile)

import Types.Feature exposing (..)
import Types.Tile exposing (..)


getTile : TileId -> Tile
getTile tileId =
    case tileId of
        0 ->
            { tileId = 0
            , rotation = 0
            , north = { sideId = 0, sideFeature = City }
            , east = { sideId = 1, sideFeature = Road }
            , south = { sideId = -1, sideFeature = Field }
            , west = { sideId = 1, sideFeature = Road }
            , hasCloister = False
            }

        _ ->
            getTile 0



-- Should never happen
