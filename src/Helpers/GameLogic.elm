module Helpers.GameLogic exposing (..)

import Array
import Dict
import Helpers.TileMapper exposing (getTile)
import Maybe
import Set
import Types.Coordinate exposing (Coordinate)
import Types.Feature exposing (Feature(..))
import Types.Game exposing (..)
import Types.GameState exposing (GameState(..))
import Types.Meeple exposing (..)
import Types.PlayerIndex exposing (PlayerIndex)
import Types.Score exposing (Score)
import Types.Tile exposing (..)


{-| Rotares the tile by 90 degrees to the left (90 degrees counterclockwise)
-}
rotateLeft : Tile -> Tile
rotateLeft tile =
    -- Prevent problems with overflow
    if tile.rotation >= 360000 then
        { tile
            | north = tile.east
            , west = tile.north
            , south = tile.west
            , east = tile.south
            , rotation = modBy 360 tile.rotation
        }

    else
        { tile
            | north = tile.east
            , west = tile.north
            , south = tile.west
            , east = tile.south
            , rotation = tile.rotation + 90
        }


{-| Checks that the tile is rotated correctly along with its features
-}
isRotatedCorrectly : Tile -> Bool
isRotatedCorrectly tile =
    let
        foundTile =
            getTile tile.tileId
    in
    case modBy 360 tile.rotation of
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


{-| Replaces all SideIds for a different SideId on all tiles

Returns the updated TileGrid

-}
replaceTileSideId : Maybe SideId -> SideId -> TileGrid -> TileGrid
replaceTileSideId maybeIdToReplace id tileGrid =
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


{-| Just updates the meeple sideIds to follow the sideId changes on the tileGrid
-}
replaceMeepleSideId : Maybe SideId -> SideId -> Meeples -> Meeples
replaceMeepleSideId maybeIdToReplace id meeples =
    let
        idToReplace =
            Maybe.withDefault -1 maybeIdToReplace

        meeplesPlacedOnIdToReplace =
            meeples |> Dict.get idToReplace |> Maybe.withDefault []

        meeplesPlacedOnId =
            meeples |> Dict.get id |> Maybe.withDefault []

        combinedMeeples =
            meeplesPlacedOnIdToReplace ++ meeplesPlacedOnId
    in
    -- optimisation: Ignore rewriting fields that are not supposed to have sideId
    if maybeIdToReplace == Nothing || idToReplace == -1 || combinedMeeples == [] then
        meeples

    else
        meeples
            |> Dict.insert id combinedMeeples
            |> Dict.remove idToReplace


{-| Count score for a featured

Prerequisite: You probably want to count only score for a finished feature

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
                    || tile.south.sideId
                    == sideId
                    || tile.west.sideId
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
                    && (tile.cloister |> Maybe.map ((/=) sideId) |> Maybe.withDefault True)
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


{-| Helper function that takes the coordinates of the last placed tile
and checks all of the adjacent tiles (including itself) if it's cloister is completed.
-}
getAdjacentTileCloisterScores : TileGrid -> Coordinate -> List ( SideId, Score )
getAdjacentTileCloisterScores grid ( x, y ) =
    [ ( ( x + 1, y + 1 ), Dict.get ( x + 1, y + 1 ) grid )
    , ( ( x, y + 1 ), Dict.get ( x, y + 1 ) grid )
    , ( ( x - 1, y + 1 ), Dict.get ( x - 1, y + 1 ) grid )
    , ( ( x + 1, y ), Dict.get ( x + 1, y ) grid )
    , ( ( x, y ), Dict.get ( x, y ) grid )
    , ( ( x - 1, y ), Dict.get ( x - 1, y ) grid )
    , ( ( x + 1, y - 1 ), Dict.get ( x + 1, y - 1 ) grid )
    , ( ( x, y - 1 ), Dict.get ( x, y - 1 ) grid )
    , ( ( x - 1, y - 1 ), Dict.get ( x - 1, y - 1 ) grid )
    ]
        |> List.filterMap
            (\( coordinates, maybeTile ) ->
                Maybe.map (\tile -> ( coordinates, tile )) maybeTile
            )
        |> List.filterMap
            (\( coordinates, tile ) ->
                Maybe.map (\cloisterSideId -> ( coordinates, cloisterSideId )) tile.cloister
            )
        |> List.filter (\( coordinates, _ ) -> countCloister grid coordinates == 9)
        |> List.map (\( _, sideId ) -> ( sideId, 9 ))


{-| Returns the list of majority owners for a feature.
-}
getFeatureOwners : Meeples -> SideId -> List PlayerIndex
getFeatureOwners meeples sideId =
    let
        playerNames =
            meeples
                |> Dict.get sideId
                |> Maybe.withDefault []
                |> List.map .owner

        incrementCount maybeCount =
            case maybeCount of
                Nothing ->
                    Just 1

                Just count ->
                    Just (count + 1)

        counts =
            List.foldl
                (\name dict -> Dict.update name incrementCount dict)
                Dict.empty
                playerNames

        maxCount =
            counts
                |> Dict.values
                |> List.foldl max 0

        playersWithMaxCount =
            counts
                |> Dict.filter (\_ count -> count == maxCount)
                |> Dict.keys
    in
    playersWithMaxCount


{-| Find the feature with the SideId

This method can definitely be optimised

This function does not work for cloisters

-}
getSideIdFeature : SideId -> TileGrid -> Feature
getSideIdFeature sideId tileGrid =
    tileGrid
        |> Dict.values
        |> List.map (\tile -> [ tile.north, tile.east, tile.south, tile.west ])
        |> List.concat
        |> List.filter (\side -> side.sideId == sideId)
        |> List.head
        |> Maybe.map (\side -> side.sideFeature)
        |> Maybe.withDefault NoFeature


{-| Places a tile on a given coordinate

Does not check whether the move is valid

Handles all of the surrounding logic related to placing a tile:

  - updates sideIds
  - updates meeple sideIds
  - changes game state
  - calculates nextSideId

-}
placeTile : Game -> Coordinate -> Game
placeTile game ( x, y ) =
    let
        -- Update the tile to have correct new sideId
        tileToPlace =
            updateSideIds (game.nextSideId + 1) game.tileToPlace

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
                |> replaceTileSideId northernAdjacentSideId tileToPlace.north.sideId
                |> replaceTileSideId easternAdjacentSideId tileToPlace.east.sideId
                |> replaceTileSideId southernAdjacentSideId tileToPlace.south.sideId
                |> replaceTileSideId westernAdjacentSideId tileToPlace.west.sideId

        meeples =
            game.meeples
                |> replaceMeepleSideId northernAdjacentSideId tileToPlace.north.sideId
                |> replaceMeepleSideId easternAdjacentSideId tileToPlace.east.sideId
                |> replaceMeepleSideId southernAdjacentSideId tileToPlace.south.sideId
                |> replaceMeepleSideId westernAdjacentSideId tileToPlace.west.sideId
    in
    { game
        | tileGrid = tileGrid
        , nextSideId = getTileMaximumSideId tileToPlace
        , gameState = PlaceMeepleState
        , meeples = meeples
        , lastPlacedTile = ( x, y )
    }


{-| Places a tile on a given position

Does not check whether the move is valid

Handles all of the surrounding logic related to placing a meeple:

  - changes game state
  - counts and updates score for finished features

-}
placeMeeple : Game -> MeeplePosition -> Game
placeMeeple game position =
    let
        meepleToPlace =
            { owner = game.currentPlayer
            , coordinates = game.lastPlacedTile
            , position = position
            }

        lastPlacedTile =
            getLastPlacedTile game

        addedMeeples =
            case position of
                North ->
                    Dict.insert lastPlacedTile.north.sideId [ meepleToPlace ] game.meeples

                East ->
                    Dict.insert lastPlacedTile.east.sideId [ meepleToPlace ] game.meeples

                South ->
                    Dict.insert lastPlacedTile.south.sideId [ meepleToPlace ] game.meeples

                West ->
                    Dict.insert lastPlacedTile.west.sideId [ meepleToPlace ] game.meeples

                Center ->
                    Dict.insert (Maybe.withDefault -1 lastPlacedTile.cloister) [ meepleToPlace ] game.meeples

                Skip ->
                    game.meeples

        finishedFeatureScores =
            getTileSideIds lastPlacedTile
                |> Set.toList
                |> List.filter (isFeatureFinished game.tileGrid)
                |> List.map
                    (\sideId ->
                        let
                            score =
                                countFeature game.tileGrid sideId
                        in
                        -- Cities that are larger than 2 tiles give 2x points if they are completed before the game ends
                        if score > 2 && getSideIdFeature sideId game.tileGrid == City then
                            ( sideId, 2 * score )

                        else
                            ( sideId, score )
                    )
                -- Append cloister score if exists
                |> List.append (getAdjacentTileCloisterScores game.tileGrid game.lastPlacedTile)

        meeples =
            List.foldl (\( sideId, _ ) m -> Dict.remove sideId m) addedMeeples finishedFeatureScores

        playerScores =
            finishedFeatureScores
                |> List.map
                    (\( sideId, score ) ->
                        getFeatureOwners addedMeeples sideId
                            |> List.map (\playerIndex -> ( playerIndex, score ))
                    )
                |> List.concat
                |> List.foldl
                    (\( playerIndex, score ) scores ->
                        let
                            playerName =
                                game.players
                                    |> Array.get playerIndex
                                    -- Should never happen
                                    |> Maybe.withDefault ""
                        in
                        Dict.update playerName (Maybe.andThen (\x -> Just (x + score))) scores
                    )
                    game.playerScores

        currentPlayerName =
            Array.get game.currentPlayer game.players |> Maybe.withDefault ""

        returnMeeple meeple tempPlayerMeeples =
            let
                playerName =
                    game.players
                        |> Array.get meeple.owner
                        -- Should never happen
                        |> Maybe.withDefault ""
            in
            Dict.update playerName (Maybe.map <| (+) 1) tempPlayerMeeples

        playerMeeples =
            List.foldl
                (\( sideId, _ ) tempPlayerMeeples ->
                    addedMeeples
                        |> Dict.get sideId
                        |> Maybe.withDefault []
                        |> List.foldl returnMeeple tempPlayerMeeples
                )
                game.playerMeeples
                finishedFeatureScores
                |> Dict.update currentPlayerName
                    (Maybe.map <|
                        if position /= Skip then
                            (+) -1

                        else
                            (+) 0
                    )
    in
    { game
        | currentPlayer = getNextPlayer game
        , meeples = meeples
        , playerMeeples = playerMeeples
        , playerScores = playerScores
        , gameState = PlaceTileState
    }


finishGame : Game -> Game
finishGame game =
    let
        featureScores =
            game.meeples
                |> Dict.keys
                |> List.map (\sideId -> ( sideId, countFeature game.tileGrid sideId ))

        cloisterScores =
            game.tileGrid
                |> Dict.toList
                |> List.filterMap
                    (\( coordinates, tile ) ->
                        Maybe.map (\sideId -> ( sideId, countCloister game.tileGrid coordinates )) tile.cloister
                    )

        -- Append cloister score if exists
        --|> List.append (getAdjacentTileCloisterScores game.tileGrid game.lastPlacedTile)
        playerScores =
            featureScores
                |> List.append cloisterScores
                |> List.map
                    (\( sideId, score ) ->
                        getFeatureOwners game.meeples sideId
                            |> List.map (\playerIndex -> ( playerIndex, score ))
                    )
                |> List.concat
                |> List.foldl
                    (\( playerIndex, score ) scores ->
                        let
                            playerName =
                                game.players
                                    |> Array.get playerIndex
                                    -- Should never happen
                                    |> Maybe.withDefault ""
                        in
                        Dict.update playerName (Maybe.andThen (\x -> Just (x + score))) scores
                    )
                    game.playerScores
    in
    { game
        | playerScores = playerScores
        , meeples = Dict.fromList []
        , gameState = FinishedState
    }
