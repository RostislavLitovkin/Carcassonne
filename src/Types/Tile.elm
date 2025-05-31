module Types.Tile exposing (..)

import Types.Feature exposing (Feature)


type alias TileId =
    Int


type alias SideId =
    Int


type alias Side =
    { sideId : SideId
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


getTileImageSource : TileId -> String
getTileImageSource tileId =
    "../Tiles/tile" ++ String.fromInt tileId ++ ".png"
