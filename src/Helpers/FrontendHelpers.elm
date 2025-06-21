module Helpers.FrontendHelpers exposing (..)

import Dict exposing (Dict)
import Set exposing (Set)
import Types.Coordinate exposing (Coordinate)
import Types.Game exposing (Meeples, TileGrid)
import Types.Meeple exposing (..)
import Types.Tile exposing (Tile, getAllSides)


{-| Converts meeples into a Coordinate to Meeple Dictionary
-}
toMeepleCoordinates : Meeples -> Dict Coordinate Meeple
toMeepleCoordinates meeples =
    meeples
        |> Dict.values
        |> List.concat
        |> List.map (\meeple -> ( meeple.coordinates, meeple ))
        |> Dict.fromList


{-| Get a set of all coordinates where it is possible to place a meeple
-}
getMeeplePositionsToBePlacedOn : Meeples -> Tile -> List MeeplePosition
getMeeplePositionsToBePlacedOn meeples tile =
    getAllSides tile
        |> List.map2 (\position sideId -> ( sideId, position )) [ North, East, South, West, Center ]
        |> List.filter (\( sideId, _ ) -> Dict.get sideId meeples == Nothing)
        |> List.filterMap
            (\( sideId, position ) ->
                if sideId /= -1 then
                    Just position

                else
                    Nothing
            )


{-| Checks if a tile can be placed on a given coordinate
-}
tileCanBePlaced : TileGrid -> Tile -> Coordinate -> Bool
tileCanBePlaced tileGrid tile ( x, y ) =
    let
        northernTile =
            Dict.get ( x, y + 1 ) tileGrid

        easternTile =
            Dict.get ( x + 1, y ) tileGrid

        southernTile =
            Dict.get ( x, y - 1 ) tileGrid

        westernTile =
            Dict.get ( x - 1, y ) tileGrid
    in
    Dict.get ( x, y ) tileGrid
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


{-| Get a set of all coordinates where it is possible to place the given tile (with it's current rotation)
-}
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
