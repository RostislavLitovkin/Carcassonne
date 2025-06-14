module Helpers.GameLogic exposing (..)

import Dict exposing (Dict)
import Helpers.TileMapper exposing (getTile)
import Maybe
import Set exposing (Set)
import Tuple exposing (first, second)
import Types.Game exposing (..)
import Types.Tile exposing (..)


{-| Rotares the tile by 90 degrees to the left (90 degrees counterclockwise)
-}
rotateLeft : Tile -> Tile
rotateLeft rest =
    { rest
        | north = rest.east
        , west = rest.north
        , south = rest.west
        , east = rest.south
        , rotation = modBy 360 (rest.rotation + 90)
    }


{-| Checks that the tile is rotated correctly along with its features
-}
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


{-| Checks if a tile can be placed on a given coordinate
-}
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


{-| Replaces all SideIds for a different SideId.

Returns the updated TileGrid

-}
replaceSideId : Maybe SideId -> SideId -> TileGrid -> TileGrid
replaceSideId maybeIdToReplace id tileGrid =
    let
        idToReplace =
            Maybe.withDefault -1 maybeIdToReplace

        updateSide side =
            if side.sideId == idToReplace then
                { side | sideId = id }

            else
                side
    in
    -- optimisation: Ignore rewriting fields that are not supposed to have sideId
    if maybeIdToReplace == Nothing || idToReplace == -1 then
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


{-| Count score for a featured.

Prerequisite: You probably want to count only score for a finished feature.

-}
countFeature : TileGrid -> SideId -> Score
countFeature tileGrid sideId =
    if sideId == -1 then
        0

    else
        Dict.filter
            (\_ tile ->
                tile.north.sideId
                    == sideId
                    || tile.east.sideId
                    == sideId
            )
            tileGrid
            |> Dict.size


{-| Checks if the feature is finished
-}
isFeatureFinished : TileGrid -> SideId -> Bool
isFeatureFinished grid sideId =
    Dict.toList grid
        |> List.all
            (\( ( x, y ), tile ) ->
                (tile.north.sideId /= sideId || Dict.get ( x, y + 1 ) grid /= Nothing)
                    && (tile.east.sideId /= sideId || Dict.get ( x + 1, y ) grid /= Nothing)
                    && (tile.south.sideId /= sideId || Dict.get ( x, y - 1 ) grid /= Nothing)
                    && (tile.west.sideId /= sideId || Dict.get ( x - 1, y ) grid /= Nothing)
            )


{-| Count score for cloister

Prerequisite: The entered coordinate should be a tile with cloister

-}
countCloister : TileGrid -> Coordinate -> Score
countCloister grid ( x, y ) =
    [ Dict.get ( x + 1, y + 1 ) grid
    , Dict.get ( x, y + 1 ) grid
    , Dict.get ( x - 1, y + 1 ) grid
    , Dict.get ( x + 1, y ) grid
    , Dict.get ( x - 1, y ) grid
    , Dict.get ( x + 1, y - 1 ) grid
    , Dict.get ( x, y - 1 ) grid
    , Dict.get ( x - 1, y - 1 ) grid
    ]
        |> List.filter (\tile -> tile /= Nothing)
        |> List.length
        |> (+) 1


placeTile : Game -> Coordinate -> Game
placeTile game ( x, y ) =
    let
        -- Update the tile to have correct new sideId
        tileToPlace =
            updateSideIds game.nextSideId game.tileToPlace

        -- get adjacent tile sideIds
        northernAdjacentSideId =
            game.tileGrid |> Dict.get ( x, y + 1 ) |> Maybe.andThen (\t -> Just t.south.sideId)

        easternAdjacentSideId =
            game.tileGrid |> Dict.get ( x + 1, y ) |> Maybe.andThen (\t -> Just t.west.sideId)

        southernAdjacentSideId =
            game.tileGrid |> Dict.get ( x, y - 1 ) |> Maybe.andThen (\t -> Just t.north.sideId)

        westernAdjacentSideId =
            game.tileGrid |> Dict.get ( x - 1, y ) |> Maybe.andThen (\t -> Just t.east.sideId)

        -- Place tile and update sideIds
        tileGrid =
            game.tileGrid
                |> Dict.insert ( x, y ) tileToPlace
                |> replaceSideId northernAdjacentSideId tileToPlace.north.sideId
                |> replaceSideId easternAdjacentSideId tileToPlace.east.sideId
                |> replaceSideId southernAdjacentSideId tileToPlace.south.sideId
                |> replaceSideId westernAdjacentSideId tileToPlace.west.sideId

        -- Update score
        -- TODO
        --
        -- Update draw stack
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
        , nextSideId = getTileMaximumSideId tileToPlace
    }
