module Helpers.GameLogic exposing (..)

import Dict exposing (Dict)
import Helpers.TileMapper exposing (getTile)
import Maybe
import Set exposing (Set)
import Tuple exposing (first, second)
import Types.Game exposing (..)
import Types.Tile exposing (..)


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


getCoordinatesToBePlacedOn : TileGrid -> Tile -> Set Coordinate
getCoordinatesToBePlacedOn tileGrid tile =
    let
        occupiedCoords =
            Dict.keys tileGrid

        adjacentCoords =
            occupiedCoords
                |> List.concatMap
                    (\( x, y ) ->
                        [ ( x + 1, y )
                        , ( x - 1, y )
                        , ( x, y + 1 )
                        , ( x, y - 1 )
                        ]
                    )
                |> List.filter (\coord -> Dict.get coord tileGrid == Nothing)
                |> Set.fromList
    in
    Set.filter (tileCanBePlaced tileGrid tile) adjacentCoords


updateSideId : TileGrid -> SideId -> SideId -> TileGrid
updateSideId tileGrid idToReplace id =
    let
        updateSide side =
            if side.sideId == idToReplace then
                { side | sideId = id }

            else
                side
    in
    -- optimisation: Ignore rewriting fields that are not supposed to have sideId
    if idToReplace == -1 then
        tileGrid

    else
        Dict.map
            (\_ tile ->
                { tile
                    | north = updateSide tile.north
                    , east = updateSide tile.east
                    , south = updateSide tile.south
                    , west = updateSide tile.west
                }
            )
            tileGrid


placeTile : Game -> Coordinate -> Game
placeTile game coordinates =
    let
        -- update sideId
        -- TODO
        --
        tileGrid =
            Dict.insert coordinates game.tileToPlace game.tileGrid

        ( nextTile, drawStack ) =
            case game.tileDrawStack of
                first :: rest ->
                    ( first, rest )

                [] ->
                    ( 0, [] )
    in
    { game
        | tileGrid = tileGrid
        , tileToPlace = getTile nextTile
        , tileDrawStack = drawStack
    }
