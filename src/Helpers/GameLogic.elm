module Helpers.GameLogic exposing (..)

import Dict exposing (Dict)
import Helpers.TileMapper exposing (getTile)
import Maybe
import Types.Game exposing (..)
import Types.Tile exposing (..)
import Tuple exposing (first, second)

rotateLeft : Tile -> Tile
rotateLeft rest =
    { rest
        | north = rest.east
        , west = rest.north
        , south = rest.west
        , east = rest.south
        , rotation = modBy 360 (rest.rotation + 90)
    }


isRotatedCorrectly : Tile -> Bool
isRotatedCorrectly tile =
    let
        foundTile =
            getTile tile.tileId
    in
    case tile.rotation of
        0 ->
            foundTile.north.sideFeature
                == tile.north.sideFeature
                && foundTile.west.sideFeature
                == tile.west.sideFeature
                && foundTile.south.sideFeature
                == tile.south.sideFeature
                && foundTile.east.sideFeature
                == tile.east.sideFeature

        90 ->
            foundTile.north.sideFeature
                == tile.west.sideFeature
                && foundTile.west.sideFeature
                == tile.south.sideFeature
                && foundTile.south.sideFeature
                == tile.east.sideFeature
                && foundTile.east.sideFeature
                == tile.north.sideFeature

        180 ->
            foundTile.north.sideFeature
                == tile.south.sideFeature
                && foundTile.west.sideFeature
                == tile.east.sideFeature
                && foundTile.south.sideFeature
                == tile.north.sideFeature
                && foundTile.east.sideFeature
                == tile.west.sideFeature

        270 ->
            foundTile.north.sideFeature
                == tile.east.sideFeature
                && foundTile.west.sideFeature
                == tile.north.sideFeature
                && foundTile.south.sideFeature
                == tile.west.sideFeature
                && foundTile.east.sideFeature
                == tile.south.sideFeature

        _ ->
            False


tileCanBePlaced : TileGrid -> Tile -> Coordinate -> Bool
tileCanBePlaced tileGrid tile coordinates =
    let
        northernTile =
            Dict.get ( first coordinates, second coordinates + 1 ) tileGrid

        easternTile =
            Dict.get ( first coordinates + 1, second coordinates ) tileGrid

        southernTile =
            Dict.get ( first coordinates, second coordinates - 1 ) tileGrid

        westernTile =
            Dict.get ( first coordinates - 1, second coordinates ) tileGrid
    in
    Dict.get coordinates tileGrid
        == Nothing
        && (northernTile
                |> Maybe.map (\t -> t.south.sideFeature == tile.north.sideFeature)
                |> Maybe.withDefault True
           )
        && (easternTile
                |> Maybe.map (\t -> t.west.sideFeature == tile.east.sideFeature)
                |> Maybe.withDefault True
           )
        && (southernTile
                |> Maybe.map (\t -> t.north.sideFeature == tile.south.sideFeature)
                |> Maybe.withDefault True
           )
        && (westernTile
                |> Maybe.map (\t -> t.east.sideFeature == tile.west.sideFeature)
                |> Maybe.withDefault True
           )
           
