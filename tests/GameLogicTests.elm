module GameLogicTests exposing (..)

import Expect
import Helpers.GameLogic exposing (..)
import Helpers.TileMapper exposing (..)
import Set
import Test exposing (..)
import Types.Feature exposing (..)
import Types.Game exposing (initializeTileGrid)


isRotatedCorrectlyTest : Test
isRotatedCorrectlyTest =
    describe "isRotatedCorrectly"
        [ test "Correct rotation 0" <|
            \_ ->
                let
                    rotatedTile =
                        getTile 0
                in
                Expect.equal (isRotatedCorrectly rotatedTile) True
        , test "Correct rotation 1" <|
            \_ ->
                let
                    rotatedTile =
                        rotateLeft <| getTile 0
                in
                Expect.equal (isRotatedCorrectly rotatedTile) True
        , test "Correct rotation 2" <|
            \_ ->
                let
                    rotatedTile =
                        rotateLeft <| rotateLeft <| getTile 0
                in
                Expect.equal (isRotatedCorrectly rotatedTile) True
        , test "Correct rotation 3" <|
            \_ ->
                let
                    rotatedTile =
                        rotateLeft <| rotateLeft <| rotateLeft <| getTile 0
                in
                Expect.equal (isRotatedCorrectly rotatedTile) True
        , test "Correct rotation 4" <|
            \_ ->
                let
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
                    tileToBePlaced =
                        getTile 0

                    tileGrid =
                        initializeTileGrid

                    coordinates =
                        ( -1, 0 )
                in
                Expect.equal (tileCanBePlaced tileGrid tileToBePlaced coordinates) True
        , test "Tile with road can be placed 2" <|
            \_ ->
                let
                    tileToBePlaced =
                        getTile 0

                    tileGrid =
                        initializeTileGrid

                    coordinates =
                        ( 1, 0 )
                in
                Expect.equal (tileCanBePlaced tileGrid tileToBePlaced coordinates) True
        , test "Tile with field can be placed 1" <|
            \_ ->
                let
                    tileToBePlaced =
                        rotateLeft <| rotateLeft <| getTile 0

                    tileGrid =
                        initializeTileGrid

                    coordinates =
                        ( 0, 1 )
                in
                Expect.equal (tileCanBePlaced tileGrid tileToBePlaced coordinates) True
        , test "Tile with city can be placed 1" <|
            \_ ->
                let
                    tileToBePlaced =
                        rotateLeft <| rotateLeft <| getTile 0

                    tileGrid =
                        initializeTileGrid

                    coordinates =
                        ( 0, 1 )
                in
                Expect.equal (tileCanBePlaced tileGrid tileToBePlaced coordinates) True
        , test "Tile with field can not be placed next to road 1" <|
            \_ ->
                let
                    tileToBePlaced =
                        rotateLeft <| getTile 0

                    tileGrid =
                        initializeTileGrid

                    coordinates =
                        ( -1, 0 )
                in
                Expect.equal (tileCanBePlaced tileGrid tileToBePlaced coordinates) False
        , test "Tile with field can not be placed next to road 2" <|
            \_ ->
                let
                    tileToBePlaced =
                        rotateLeft <| getTile 0

                    tileGrid =
                        initializeTileGrid

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
                    tileToBePlaced =
                        getTile 1

                    tileGrid =
                        initializeTileGrid
                in
                Expect.equal (getCoordinatesToBePlacedOn tileGrid tileToBePlaced) (Set.fromList [ ( 1, 0 ), ( 0, -1 ) ])
        , test "Tile to be placed on coordinates 2" <|
            \_ ->
                let
                    tileToBePlaced =
                        rotateLeft <| getTile 1

                    tileGrid =
                        initializeTileGrid
                in
                Expect.equal (getCoordinatesToBePlacedOn tileGrid tileToBePlaced) (Set.fromList [ ( -1, 0 ), ( 0, -1 ) ])
        , test "Tile to be placed on coordinates 3" <|
            \_ ->
                let
                    tileToBePlaced =
                        getTile 0

                    tileGrid =
                        initializeTileGrid
                in
                Expect.equal (getCoordinatesToBePlacedOn tileGrid tileToBePlaced) (Set.fromList [ ( -1, 0 ), ( 1, 0 ) ])
        , test "Tile to be placed on coordinates 4" <|
            \_ ->
                let
                    tileToBePlaced =
                        rotateLeft <| rotateLeft <| getTile 0

                    tileGrid =
                        initializeTileGrid
                in
                Expect.equal (getCoordinatesToBePlacedOn tileGrid tileToBePlaced) (Set.fromList [ ( -1, 0 ), ( 0, -1 ), ( 1, 0 ), ( 0, 1 ) ])
        , test "Tile to be placed on coordinates 5" <|
            \_ ->
                let
                    tileToBePlaced =
                        rotateLeft <| getTile 0

                    tileGrid =
                        initializeTileGrid
                in
                Expect.equal (getCoordinatesToBePlacedOn tileGrid tileToBePlaced) (Set.fromList [])
        ]
