module GameLogicTests exposing (..)

import Expect
import Helpers.FrontendHelpers exposing (..)
import Helpers.GameLogic exposing (..)
import Helpers.TileMapper exposing (..)
import Set
import Test exposing (..)
import Types.Coordinate exposing (Coordinate)
import Types.Game exposing (TileGrid, initializeTileGrid)
import Types.Tile exposing (Tile)


isRotatedCorrectlyTest : Test
isRotatedCorrectlyTest =
    describe "isRotatedCorrectly"
        [ test "Correct rotation 0" <|
            \_ ->
                let
                    rotatedTile : Tile
                    rotatedTile =
                        getTile 0
                in
                Expect.equal (isRotatedCorrectly rotatedTile) True
        , test "Correct rotation 1" <|
            \_ ->
                let
                    rotatedTile : Tile
                    rotatedTile =
                        rotateLeft <| getTile 0
                in
                Expect.equal (isRotatedCorrectly rotatedTile) True
        , test "Correct rotation 2" <|
            \_ ->
                let
                    rotatedTile : Tile
                    rotatedTile =
                        rotateLeft <| rotateLeft <| getTile 0
                in
                Expect.equal (isRotatedCorrectly rotatedTile) True
        , test "Correct rotation 3" <|
            \_ ->
                let
                    rotatedTile : Tile
                    rotatedTile =
                        rotateLeft <| rotateLeft <| rotateLeft <| getTile 0
                in
                Expect.equal (isRotatedCorrectly rotatedTile) True
        , test "Correct rotation 4" <|
            \_ ->
                let
                    rotatedTile : Tile
                    rotatedTile =
                        rotateLeft <| rotateLeft <| rotateLeft <| rotateLeft <| getTile 0
                in
                Expect.equal (isRotatedCorrectly rotatedTile) True
        ]


tileCanBePlacedTest : Test
tileCanBePlacedTest =
    describe "tileCanBePlaced"
        [ test "Tile with road can be placed 1" <|
            \_ ->
                let
                    tileToBePlaced : Tile
                    tileToBePlaced =
                        getTile 0

                    tileGrid : TileGrid
                    tileGrid =
                        initializeTileGrid

                    coordinates : Coordinate
                    coordinates =
                        ( -1, 0 )
                in
                Expect.equal (tileCanBePlaced tileGrid tileToBePlaced coordinates) True
        , test "Tile with road can be placed 2" <|
            \_ ->
                let
                    tileToBePlaced : Tile
                    tileToBePlaced =
                        getTile 0

                    tileGrid : TileGrid
                    tileGrid =
                        initializeTileGrid

                    coordinates : Coordinate
                    coordinates =
                        ( 1, 0 )
                in
                Expect.equal (tileCanBePlaced tileGrid tileToBePlaced coordinates) True
        , test "Tile with field can be placed 1" <|
            \_ ->
                let
                    tileToBePlaced : Tile
                    tileToBePlaced =
                        rotateLeft <| rotateLeft <| getTile 0

                    tileGrid : TileGrid
                    tileGrid =
                        initializeTileGrid

                    coordinates : Coordinate
                    coordinates =
                        ( 0, 1 )
                in
                Expect.equal (tileCanBePlaced tileGrid tileToBePlaced coordinates) True
        , test "Tile with city can be placed 1" <|
            \_ ->
                let
                    tileToBePlaced : Tile
                    tileToBePlaced =
                        rotateLeft <| rotateLeft <| getTile 0

                    tileGrid : TileGrid
                    tileGrid =
                        initializeTileGrid

                    coordinates : Coordinate
                    coordinates =
                        ( 0, 1 )
                in
                Expect.equal (tileCanBePlaced tileGrid tileToBePlaced coordinates) True
        , test "Tile with field can not be placed next to road 1" <|
            \_ ->
                let
                    tileToBePlaced : Tile
                    tileToBePlaced =
                        rotateLeft <| getTile 0

                    tileGrid : TileGrid
                    tileGrid =
                        initializeTileGrid

                    coordinates : Coordinate
                    coordinates =
                        ( -1, 0 )
                in
                Expect.equal (tileCanBePlaced tileGrid tileToBePlaced coordinates) False
        , test "Tile with field can not be placed next to road 2" <|
            \_ ->
                let
                    tileToBePlaced : Tile
                    tileToBePlaced =
                        rotateLeft <| getTile 0

                    tileGrid : TileGrid
                    tileGrid =
                        initializeTileGrid

                    coordinates : Coordinate
                    coordinates =
                        ( 1, 0 )
                in
                Expect.equal (tileCanBePlaced tileGrid tileToBePlaced coordinates) False
        ]


getCoordinatesToBePlacedOnTest : Test
getCoordinatesToBePlacedOnTest =
    describe "getCoordinatesToBePlacedOn"
        [ test "Tile to be placed on coordinates 1" <|
            \_ ->
                let
                    tileToBePlaced : Tile
                    tileToBePlaced =
                        getTile 1

                    tileGrid : TileGrid
                    tileGrid =
                        initializeTileGrid
                in
                Expect.equal (getCoordinatesToBePlacedOn tileGrid tileToBePlaced) (Set.fromList [ ( 1, 0 ), ( 0, -1 ) ])
        , test "Tile to be placed on coordinates 2" <|
            \_ ->
                let
                    tileToBePlaced : Tile
                    tileToBePlaced =
                        rotateLeft <| getTile 1

                    tileGrid : TileGrid
                    tileGrid =
                        initializeTileGrid
                in
                Expect.equal (getCoordinatesToBePlacedOn tileGrid tileToBePlaced) (Set.fromList [ ( -1, 0 ), ( 0, -1 ) ])
        , test "Tile to be placed on coordinates 3" <|
            \_ ->
                let
                    tileToBePlaced : Tile
                    tileToBePlaced =
                        getTile 0

                    tileGrid : TileGrid
                    tileGrid =
                        initializeTileGrid
                in
                Expect.equal (getCoordinatesToBePlacedOn tileGrid tileToBePlaced) (Set.fromList [ ( -1, 0 ), ( 1, 0 ) ])
        , test "Tile to be placed on coordinates 4" <|
            \_ ->
                let
                    tileToBePlaced : Tile
                    tileToBePlaced =
                        rotateLeft <| rotateLeft <| getTile 0

                    tileGrid : TileGrid
                    tileGrid =
                        initializeTileGrid
                in
                Expect.equal (getCoordinatesToBePlacedOn tileGrid tileToBePlaced) (Set.fromList [ ( -1, 0 ), ( 0, -1 ), ( 1, 0 ), ( 0, 1 ) ])
        , test "Tile to be placed on coordinates 5" <|
            \_ ->
                let
                    tileToBePlaced : Tile
                    tileToBePlaced =
                        rotateLeft <| getTile 0

                    tileGrid : TileGrid
                    tileGrid =
                        initializeTileGrid
                in
                Expect.equal (getCoordinatesToBePlacedOn tileGrid tileToBePlaced) Set.empty
        ]
