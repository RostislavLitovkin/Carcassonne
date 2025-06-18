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
            , cloister = Nothing
            }

        1 ->
            { tileId = 1
            , rotation = 0
            , north = { sideId = -1, sideFeature = Field }
            , east = { sideId = -1, sideFeature = Field }
            , south = { sideId = 0, sideFeature = Road }
            , west = { sideId = 0, sideFeature = Road }
            , cloister = Nothing
            }

        2 ->
            { tileId = 2
            , rotation = 0
            , north = { sideId = 0, sideFeature = Road }
            , east = { sideId = -1, sideFeature = Field }
            , south = { sideId = 0, sideFeature = Road }
            , west = { sideId = -1, sideFeature = Field }
            , cloister = Nothing
            }

        3 ->
            { tileId = 3
            , rotation = 0
            , north = { sideId = -1, sideFeature = Field }
            , east = { sideId = -1, sideFeature = Field }
            , south = { sideId = -1, sideFeature = Field }
            , west = { sideId = -1, sideFeature = Field }
            , cloister = Just 0
            }

        4 ->
            { tileId = 4
            , rotation = 0
            , north = { sideId = -1, sideFeature = Field }
            , east = { sideId = -1, sideFeature = Field }
            , south = { sideId = 1, sideFeature = Road }
            , west = { sideId = -1, sideFeature = Field }
            , cloister = Just 0
            }

        5 ->
            { tileId = 5
            , rotation = 0
            , north = { sideId = 0, sideFeature = City }
            , east = { sideId = 0, sideFeature = City }
            , south = { sideId = 0, sideFeature = City }
            , west = { sideId = 0, sideFeature = City }
            , cloister = Nothing
            }

        6 ->
            { tileId = 6
            , rotation = 0
            , north = { sideId = 0, sideFeature = City }
            , east = { sideId = 0, sideFeature = City }
            , south = { sideId = -1, sideFeature = Field }
            , west = { sideId = 0, sideFeature = City }
            , cloister = Nothing
            }

        7 ->
            { tileId = 7
            , rotation = 0
            , north = { sideId = 0, sideFeature = City }
            , east = { sideId = 0, sideFeature = City }
            , south = { sideId = -1, sideFeature = Field }
            , west = { sideId = 0, sideFeature = City }
            , cloister = Nothing
            }

        8 ->
            { tileId = 8
            , rotation = 0
            , north = { sideId = 0, sideFeature = City }
            , east = { sideId = 0, sideFeature = City }
            , south = { sideId = 1, sideFeature = Road }
            , west = { sideId = 0, sideFeature = City }
            , cloister = Nothing
            }

        9 ->
            { tileId = 9
            , rotation = 0
            , north = { sideId = 0, sideFeature = City }
            , east = { sideId = 0, sideFeature = City }
            , south = { sideId = 1, sideFeature = Road }
            , west = { sideId = 0, sideFeature = City }
            , cloister = Nothing
            }

        10 ->
            { tileId = 10
            , rotation = 0
            , north = { sideId = 0, sideFeature = City }
            , east = { sideId = -1, sideFeature = Field }
            , south = { sideId = -1, sideFeature = Field }
            , west = { sideId = 0, sideFeature = City }
            , cloister = Nothing
            }

        11 ->
            { tileId = 11
            , rotation = 0
            , north = { sideId = 0, sideFeature = City }
            , east = { sideId = -1, sideFeature = Field }
            , south = { sideId = -1, sideFeature = Field }
            , west = { sideId = -1, sideFeature = Field }
            , cloister = Nothing
            }

        12 ->
            { tileId = 12
            , rotation = 0
            , north = { sideId = 0, sideFeature = City }
            , east = { sideId = -1, sideFeature = Field }
            , south = { sideId = 1, sideFeature = City }
            , west = { sideId = -1, sideFeature = Field }
            , cloister = Nothing
            }

        13 ->
            { tileId = 13
            , rotation = 0
            , north = { sideId = 0, sideFeature = City }
            , east = { sideId = -1, sideFeature = Field }
            , south = { sideId = -1, sideFeature = Field }
            , west = { sideId = 1, sideFeature = City }
            , cloister = Nothing
            }

        14 ->
            { tileId = 14
            , rotation = 0
            , north = { sideId = -1, sideFeature = Field }
            , east = { sideId = 0, sideFeature = City }
            , south = { sideId = -1, sideFeature = Field }
            , west = { sideId = 0, sideFeature = City }
            , cloister = Nothing
            }

        15 ->
            { tileId = 15
            , rotation = 0
            , north = { sideId = -1, sideFeature = Field }
            , east = { sideId = 0, sideFeature = City }
            , south = { sideId = -1, sideFeature = Field }
            , west = { sideId = 0, sideFeature = City }
            , cloister = Nothing
            }

        16 ->
            { tileId = 16
            , rotation = 0
            , north = { sideId = 0, sideFeature = City }
            , east = { sideId = 1, sideFeature = Road }
            , south = { sideId = 1, sideFeature = Road }
            , west = { sideId = 0, sideFeature = City }
            , cloister = Nothing
            }

        17 ->
            { tileId = 17
            , rotation = 0
            , north = { sideId = 0, sideFeature = City }
            , east = { sideId = 1, sideFeature = Road }
            , south = { sideId = 1, sideFeature = Road }
            , west = { sideId = 0, sideFeature = City }
            , cloister = Nothing
            }

        18 ->
            { tileId = 18
            , rotation = 0
            , north = { sideId = 0, sideFeature = City }
            , east = { sideId = -1, sideFeature = Field }
            , south = { sideId = -1, sideFeature = Field }
            , west = { sideId = 0, sideFeature = City }
            , cloister = Nothing
            }

        19 ->
            { tileId = 19
            , rotation = 0
            , north = { sideId = 0, sideFeature = City }
            , east = { sideId = -1, sideFeature = Field }
            , south = { sideId = 1, sideFeature = Road }
            , west = { sideId = 1, sideFeature = Road }
            , cloister = Nothing
            }

        20 ->
            { tileId = 20
            , rotation = 0
            , north = { sideId = 0, sideFeature = City }
            , east = { sideId = 1, sideFeature = Road }
            , south = { sideId = 1, sideFeature = Road }
            , west = { sideId = -1, sideFeature = Field }
            , cloister = Nothing
            }

        21 ->
            { tileId = 21
            , rotation = 0
            , north = { sideId = 0, sideFeature = Road }
            , east = { sideId = 0, sideFeature = Road }
            , south = { sideId = 0, sideFeature = Road }
            , west = { sideId = 0, sideFeature = Road }
            , cloister = Nothing
            }

        22 ->
            { tileId = 22
            , rotation = 0
            , north = { sideId = -1, sideFeature = Field }
            , east = { sideId = 0, sideFeature = Road }
            , south = { sideId = 1, sideFeature = Road }
            , west = { sideId = 2, sideFeature = Road }
            , cloister = Nothing
            }

        23 ->
            { tileId = 23
            , rotation = 0
            , north = { sideId = 0, sideFeature = Road }
            , east = { sideId = 1, sideFeature = Road }
            , south = { sideId = 2, sideFeature = Road }
            , west = { sideId = 3, sideFeature = Road }
            , cloister = Nothing
            }

        _ ->
            getTile 0



-- Should never happen
