module Types.Tile exposing (..)

import Set exposing (Set)
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


getTileMaximumSideId : Tile -> SideId
getTileMaximumSideId tile =
    List.maximum (getAllSides tile)
        |> Maybe.withDefault 0


getTileSideIds : Tile -> Set SideId
getTileSideIds tile =
    Set.fromList (getAllSides tile)
        |> Set.remove -1


getAllSides : Tile -> List SideId
getAllSides tile =
    [ tile.north.sideId, tile.east.sideId, tile.south.sideId, tile.west.sideId ]


updateSideIds : SideId -> Tile -> Tile
updateSideIds minimumSideId tile =
    let
        updateSide side =
            if side.sideId == -1 then
                side

            else
                { side
                    | sideId = side.sideId + minimumSideId
                }
    in
    { tile
        | north = updateSide tile.north
        , east = updateSide tile.east
        , south = updateSide tile.south
        , west = updateSide tile.west
    }


getTileImageSource : TileId -> String
getTileImageSource tileId =
    "/tile" ++ String.fromInt tileId ++ ".png"
