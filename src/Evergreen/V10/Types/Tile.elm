module Evergreen.V10.Types.Tile exposing (..)

import Evergreen.V10.Types.Feature


type alias TileId =
    Int


type alias SideId =
    Int


type alias Side =
    { sideId : SideId
    , sideFeature : Evergreen.V10.Types.Feature.Feature
    }


type alias Tile =
    { tileId : TileId
    , rotation : Int
    , north : Side
    , east : Side
    , south : Side
    , west : Side
    , cloister : Maybe SideId
    }
