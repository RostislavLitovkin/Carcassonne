module GameLogicTests exposing (..)

import Expect
import Helpers.GameLogic exposing (..)
import Helpers.TileMapper exposing (..)
import Test exposing (..)
import Types.Feature exposing (..)

isRotatedCorrectlyTest : Test
isRotatedCorrectlyTest =
    describe "isRotatedCorrectly"
        [ test "Correct rotation 0" <|
            \_ ->
                let
                    rotatedTile = getTile 0
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