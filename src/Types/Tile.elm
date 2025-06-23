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
    , cloister : Maybe SideId
    }


{-| Returns the largest sideId of the tile
-}
getTileMaximumSideId : Tile -> SideId
getTileMaximumSideId tile =
    List.maximum (getAllSides tile)
        |> Maybe.withDefault 0


{-| return only meaningful sideIds (without -1), without duplicates
-}
getTileSideIds : Tile -> Set SideId
getTileSideIds tile =
    Set.fromList (getAllSides tile)
        |> Set.remove -1


{-| Returns a list of all sideIds, including duplicates and -1 sideIds
-}
getAllSides : Tile -> List SideId
getAllSides tile =
    case tile.cloister of
        Nothing ->
            [ tile.north.sideId, tile.east.sideId, tile.south.sideId, tile.west.sideId ]

        Just cloisterSideId ->
            [ tile.north.sideId, tile.east.sideId, tile.south.sideId, tile.west.sideId, cloisterSideId ]


{-| raise the tile sideIds to be at least minimumumSideId
-}
updateSideIds : SideId -> Tile -> Tile
updateSideIds minimumSideId tile =
    let
        updateSide : Side -> Side
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
        , cloister = Maybe.map ((+) minimumSideId) tile.cloister
    }


getTileImageSource : TileId -> String
getTileImageSource tileId =
    "/tile" ++ String.fromInt tileId ++ ".png"
