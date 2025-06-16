module MeepleTests exposing (..)

import Dict
import Expect
import Helpers.GameLogic exposing (getFeatureOwners)
import Test exposing (..)
import Types.Game exposing (..)


getFeatureOwnersTest : Test
getFeatureOwnersTest =
    describe "getFeatureOwners"
        [ test "No meeples" <|
            \_ ->
                let
                    meeples =
                        Dict.fromList []
                in
                Expect.equal (getFeatureOwners meeples 0) []
        , test "1 meeple" <|
            \_ ->
                let
                    meeples =
                        Dict.fromList
                            [ ( 1, [ { owner = 0, coordinates = ( -1, 0 ), position = South } ] )
                            , ( 0, [ { owner = 1, coordinates = ( 0, 0 ), position = North } ] )
                            , ( 2, [ { owner = 0, coordinates = ( -5, 0 ), position = West } ] )
                            ]
                in
                Expect.equal (getFeatureOwners meeples 0) [ 1 ]
        , test "2 meeples" <|
            \_ ->
                let
                    meeples =
                        Dict.fromList
                            [ ( 0, [ { owner = 1, coordinates = ( 0, 0 ), position = North }, { owner = 1, coordinates = ( 1, 0 ), position = East } ] )
                            , ( 2, [ { owner = 0, coordinates = ( -5, 0 ), position = West } ] )
                            , ( 7, [ { owner = 2, coordinates = ( -1, 0 ), position = South } ] )
                            ]
                in
                Expect.equal (getFeatureOwners meeples 0) [ 1 ]
        , test "1 meeple split" <|
            \_ ->
                let
                    meeples =
                        Dict.fromList
                            [ ( 0, [ { owner = 1, coordinates = ( 0, 0 ), position = North }, { owner = 0, coordinates = ( 1, 0 ), position = East } ] )
                            , ( 2, [ { owner = 0, coordinates = ( -5, 0 ), position = West } ] )
                            , ( 7, [ { owner = 2, coordinates = ( -1, 0 ), position = South } ] )
                            ]
                in
                Expect.equal (getFeatureOwners meeples 0) [ 0, 1 ]
        , test "2 meeples > 1 meeple" <|
            \_ ->
                let
                    meeples =
                        Dict.fromList
                            [ ( 0, [ { owner = 0, coordinates = ( 1, 0 ), position = East } ] )
                            , ( 2, [ { owner = 0, coordinates = ( -5, 0 ), position = West }, { owner = 1, coordinates = ( 1, 1 ), position = East }, { owner = 0, coordinates = ( -3, 2 ), position = West } ] )
                            , ( 7, [ { owner = 2, coordinates = ( -1, 0 ), position = South } ] )
                            ]
                in
                Expect.equal (getFeatureOwners meeples 2) [ 0 ]
        ]
