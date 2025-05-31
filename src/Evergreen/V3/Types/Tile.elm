module Evergreen.V3.Types.Tile exposing (..)

import Evergreen.V3.Types.Feature


type alias TileId =
    Int


type alias SideId =
    Int


type alias Side =
    { sideId : SideId
    , sideFeature : Evergreen.V3.Types.Feature.Feature
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
