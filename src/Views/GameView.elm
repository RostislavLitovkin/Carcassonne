module Views.GameView exposing (..)

import Array
import Dict
import Helpers.FrontendHelpers exposing (..)
import Html exposing (..)
import Html.Attributes exposing (height, src, style, width)
import Html.Events exposing (onClick)
import Set exposing (Set)
import Styles exposing (buttonMain)
import Types exposing (FrontendMsg(..))
import Types.Coordinate exposing (Coordinate)
import Types.Game exposing (..)
import Types.GameState as GameState exposing (GameState(..))
import Types.Meeple exposing (..)
import Types.PlayerName exposing (PlayerName)
import Types.Tile exposing (..)


renderGameView : PlayerName -> Game -> Bool -> Html FrontendMsg
renderGameView playerName game debugMode =
    let
        currentPlayerName =
            game.players |> Array.get game.currentPlayer |> Maybe.withDefault ""
    in
    case game.gameState of
        PlaceTileState ->
            let
                coordinatesToBePlacedOn =
                    getCoordinatesToBePlacedOn game.tileGrid game.tileToPlace
            in
            div
                [ style "display" "flex"
                , style "flex-direction" "row"
                , style "align-items" "flex-start"
                ]
                [ renderSideBar game playerName
                , div
                    [ style "flex" "1"
                    , style "position" "relative"
                    , style "display" "flex"
                    , style "justify-content" "center"
                    , style "align-items" "center"
                    ]
                    ([ div
                        [ style "position" "absolute"
                        , style "top" "50%"
                        , style "left" "50%"
                        , style "transform" "translate(-50%, 0%)"
                        ]
                        [ viewTileGrid game.tileGrid ]
                     , div
                        [ style "position" "absolute"
                        , style "top" "50%"
                        , style "left" "50%"
                        , style "transform" "translate(-50%, 0%)"
                        ]
                        [ viewMeepleGrid game.tileGrid game.meeples ]
                     ]
                        ++ (if playerName == currentPlayerName then
                                [ div
                                    [ style "position" "absolute"
                                    , style "top" "50%"
                                    , style "left" "50%"
                                    , style "transform" "translate(-50%, 0%)"
                                    ]
                                    [ viewPlaceableGrid game.tileGrid coordinatesToBePlacedOn ]
                                ]

                            else
                                []
                           )
                        ++ (if debugMode then
                                [ div
                                    [ style "position" "absolute"
                                    , style "top" "50%"
                                    , style "left" "50%"
                                    , style "transform" "translate(-50%, 0%)"
                                    ]
                                    [ viewDebugOverlay game.tileGrid ]
                                ]

                            else
                                []
                           )
                    )
                ]

        PlaceMeepleState ->
            let
                lastPlacedTile =
                    getLastPlacedTile game

                positionsToBePlacedOn =
                    getMeeplePositionsToBePlacedOn game.meeples lastPlacedTile
            in
            div
                [ style "display" "flex"
                , style "flex-direction" "row"
                , style "align-items" "flex-start"
                ]
                [ renderSideBar game playerName
                , div
                    [ style "flex" "1"
                    , style "position" "relative"
                    , style "display" "flex"
                    , style "justify-content" "center"
                    , style "align-items" "center"
                    ]
                    ([ div
                        [ style "position" "absolute"
                        , style "top" "50%"
                        , style "left" "50%"
                        , style "transform" "translate(-50%, 0%)"
                        ]
                        [ viewTileGrid game.tileGrid ]
                     , div
                        [ style "position" "absolute"
                        , style "top" "50%"
                        , style "left" "50%"
                        , style "transform" "translate(-50%, 0%)"
                        ]
                        [ viewMeepleGrid game.tileGrid game.meeples ]
                     ]
                        ++ (if playerName == currentPlayerName then
                                [ div
                                    [ style "position" "absolute"
                                    , style "top" "50%"
                                    , style "left" "50%"
                                    , style "transform" "translate(-50%, 0%)"
                                    ]
                                    [ viewMeeplePositionsOverlay game.tileGrid game.lastPlacedTile positionsToBePlacedOn ]
                                ]

                            else
                                []
                           )
                        ++ (if debugMode then
                                [ div
                                    [ style "position" "absolute"
                                    , style "top" "50%"
                                    , style "left" "50%"
                                    , style "transform" "translate(-50%, 0%)"
                                    ]
                                    [ viewDebugOverlay game.tileGrid ]
                                ]

                            else
                                []
                           )
                    )
                ]

        FinishedState ->
            div
                [ style "display" "flex"
                , style "flex-direction" "row"
                , style "align-items" "flex-start"
                ]
                [ renderSideBar game playerName
                , div
                    [ style "flex" "1"
                    , style "position" "relative"
                    , style "display" "flex"
                    , style "justify-content" "center"
                    , style "align-items" "center"
                    ]
                    (div
                        [ style "position" "absolute"
                        , style "top" "50%"
                        , style "left" "50%"
                        , style "transform" "translate(-50%, 0%)"
                        ]
                        [ viewTileGrid game.tileGrid ]
                        :: (if debugMode then
                                [ div
                                    [ style "position" "absolute"
                                    , style "top" "50%"
                                    , style "left" "50%"
                                    , style "transform" "translate(-50%, 0%)"
                                    ]
                                    [ viewDebugOverlay game.tileGrid ]
                                ]

                            else
                                []
                           )
                    )
                ]


viewTileGrid : TileGrid -> Html FrontendMsg
viewTileGrid tileGrid =
    let
        coordinates =
            Dict.keys tileGrid

        minX =
            List.minimum (List.map Tuple.first coordinates) |> Maybe.withDefault 0

        maxX =
            List.maximum (List.map Tuple.first coordinates) |> Maybe.withDefault 0

        minY =
            List.minimum (List.map Tuple.second coordinates) |> Maybe.withDefault 0

        maxY =
            List.maximum (List.map Tuple.second coordinates) |> Maybe.withDefault 0

        rows =
            List.range (minY - 1) (maxY + 1)
                |> List.reverse
                |> List.map
                    (\y ->
                        div [ style "display" "flex" ]
                            (List.range (minX - 1) (maxX + 1)
                                |> List.map (\x -> renderTileCell ( x, y ) tileGrid)
                            )
                    )
    in
    div
        [ style "display" "flex"
        , style "justify-content" "center"
        , style "align-items" "center"
        , style "min-height" "100vh"
        ]
        [ div
            [ style "display" "flex"
            , style "flex-direction" "column"
            , style "gap" "0px"
            ]
            rows
        ]


renderTileCell : Coordinate -> TileGrid -> Html FrontendMsg
renderTileCell coord grid =
    case Dict.get coord grid of
        Just tile ->
            let
                rotationStyle =
                    "rotate(" ++ String.fromInt (negate tile.rotation) ++ "deg)"
            in
            img
                [ src <| getTileImageSource tile.tileId
                , style "width" "64px"
                , style "height" "64px"
                , style "transform" rotationStyle
                ]
                []

        Nothing ->
            renderEmptyTile


viewPlaceableGrid : TileGrid -> Set Coordinate -> Html FrontendMsg
viewPlaceableGrid tileGrid coordinatesToBePlacedOn =
    let
        coordinates =
            Dict.keys tileGrid

        minX =
            List.minimum (List.map Tuple.first coordinates) |> Maybe.withDefault 0

        maxX =
            List.maximum (List.map Tuple.first coordinates) |> Maybe.withDefault 0

        minY =
            List.minimum (List.map Tuple.second coordinates) |> Maybe.withDefault 0

        maxY =
            List.maximum (List.map Tuple.second coordinates) |> Maybe.withDefault 0

        rows =
            List.range (minY - 1) (maxY + 1)
                |> List.reverse
                |> List.map
                    (\y ->
                        div [ style "display" "flex" ]
                            (List.range (minX - 1) (maxX + 1)
                                |> List.map (\x -> renderPlaceableCell ( x, y ) coordinatesToBePlacedOn)
                            )
                    )
    in
    div
        [ style "display" "flex"
        , style "justify-content" "center"
        , style "align-items" "center"
        , style "min-height" "100vh"
        ]
        [ div
            [ style "display" "flex"
            , style "flex-direction" "column"
            , style "gap" "0px"
            ]
            rows
        ]


renderPlaceableCell : Coordinate -> Set Coordinate -> Html FrontendMsg
renderPlaceableCell coord coordinatesToBePlacedOn =
    if Set.member coord coordinatesToBePlacedOn then
        div
            [ style "width" "64px"
            , style "height" "64px"
            , style "background-color" "rgba(144, 238, 144, 0.4)"
            , style "border" "1px dashed #5a5"
            , style "cursor" "pointer"
            , onClick <| FePlaceTile coord
            ]
            []

    else
        renderEmptyTile


viewMeeplePositionsOverlay : TileGrid -> Coordinate -> List MeeplePosition -> Html FrontendMsg
viewMeeplePositionsOverlay tileGrid lastTilePlacedCoordinates positionsToBePlacedOn =
    let
        coordinates =
            Dict.keys tileGrid

        minX =
            List.minimum (List.map Tuple.first coordinates) |> Maybe.withDefault 0

        maxX =
            List.maximum (List.map Tuple.first coordinates) |> Maybe.withDefault 0

        minY =
            List.minimum (List.map Tuple.second coordinates) |> Maybe.withDefault 0

        maxY =
            List.maximum (List.map Tuple.second coordinates) |> Maybe.withDefault 0

        rows =
            List.range (minY - 1) (maxY + 1)
                |> List.reverse
                |> List.map
                    (\y ->
                        div [ style "display" "flex" ]
                            (List.range (minX - 1) (maxX + 1)
                                |> List.map (\x -> renderOverlayCell ( x, y ) lastTilePlacedCoordinates positionsToBePlacedOn)
                            )
                    )
    in
    div
        [ style "display" "flex"
        , style "justify-content" "center"
        , style "align-items" "center"
        , style "min-height" "100vh"
        ]
        [ div
            [ style "display" "flex"
            , style "flex-direction" "column"
            , style "gap" "0px"
            ]
            rows
        , button
            [ style "position" "absolute"
            , style "top" "100%"
            , style "left" "50%"
            , style "transform" "translate(-50%, -70px)"
            , style "padding" "8px 16px"
            , style "background-color" "rgba(255, 74, 231, 0.67)"
            , style "border-radius" "9px"
            , style "color" "white"
            , style "border" "none"
            , style "cursor" "pointer"
            , onClick <| FePlaceMeeple Skip
            ]
            [ text "Skip Meeple placement" ]
        ]


renderOverlayCell : Coordinate -> Coordinate -> List MeeplePosition -> Html FrontendMsg
renderOverlayCell coordinates lastTilePlacedCoordinates positionsToBePlacedOn =
    if coordinates /= lastTilePlacedCoordinates then
        renderEmptyTile

    else
        div
            [ style "width" "64px"
            , style "height" "64px"
            , style "display" "grid"
            , style "grid-template-columns" "repeat(3, 1fr)"
            , style "grid-template-rows" "repeat(3, 1fr)"
            , style "gap" "2px"
            , style "background-color" "transparent"
            ]
            [ div [] []
            , renderMeepleCircle North positionsToBePlacedOn
            , div [] []
            , renderMeepleCircle West positionsToBePlacedOn
            , renderMeepleCircle Center positionsToBePlacedOn
            , renderMeepleCircle East positionsToBePlacedOn
            , div [] []
            , renderMeepleCircle South positionsToBePlacedOn
            , div [] []
            ]


viewMeepleGrid : TileGrid -> Meeples -> Html FrontendMsg
viewMeepleGrid tileGrid meeples =
    let
        meepleCoordinates =
            toMeepleCoordinates meeples

        coordinates =
            Dict.keys tileGrid

        minX =
            List.minimum (List.map Tuple.first coordinates) |> Maybe.withDefault 0

        maxX =
            List.maximum (List.map Tuple.first coordinates) |> Maybe.withDefault 0

        minY =
            List.minimum (List.map Tuple.second coordinates) |> Maybe.withDefault 0

        maxY =
            List.maximum (List.map Tuple.second coordinates) |> Maybe.withDefault 0

        rows =
            List.range (minY - 1) (maxY + 1)
                |> List.reverse
                |> List.map
                    (\y ->
                        div [ style "display" "flex" ]
                            (List.range (minX - 1) (maxX + 1)
                                |> List.map (\x -> renderMeepleCell <| Dict.get ( x, y ) meepleCoordinates)
                            )
                    )
    in
    div
        [ style "display" "flex"
        , style "justify-content" "center"
        , style "align-items" "center"
        , style "min-height" "100vh"
        ]
        [ div
            [ style "display" "flex"
            , style "flex-direction" "column"
            , style "gap" "0px"
            ]
            rows
        ]


renderMeepleCell : Maybe Meeple -> Html FrontendMsg
renderMeepleCell maybeMeeple =
    case maybeMeeple of
        Nothing ->
            renderEmptyTile

        Just meeple ->
            div
                [ style "width" "64px"
                , style "height" "64px"
                , style "display" "grid"
                , style "grid-template-columns" "repeat(3, 1fr)"
                , style "grid-template-rows" "repeat(3, 1fr)"
                , style "gap" "2px"
                , style "background-color" "transparent"
                ]
                [ div [] []
                , renderMeepleFigure North meeple
                , div [] []
                , renderMeepleFigure West meeple
                , renderMeepleFigure Center meeple
                , renderMeepleFigure East meeple
                , div [] []
                , renderMeepleFigure South meeple
                , div [] []
                ]


renderMeepleFigure : MeeplePosition -> Meeple -> Html FrontendMsg
renderMeepleFigure position meeple =
    if position == meeple.position then
        div [ style "display" "flex", style "justify-content" "center", style "align-items" "center" ]
            [ img
                [ style "width" "18px"
                , style "height" "18px"
                , src <| getMeepleImageSource meeple.owner
                ]
                []
            ]

    else
        div [] []


renderMeepleCircle : MeeplePosition -> List MeeplePosition -> Html FrontendMsg
renderMeepleCircle position positionsToBePlacedOn =
    if List.member position positionsToBePlacedOn then
        div [ style "display" "flex", style "justify-content" "center", style "align-items" "center" ]
            [ div
                [ style "width" "18px"
                , style "height" "18px"
                , style "border-radius" "50%"
                , style "background-color" "rgba(255, 74, 231, 0.67)"
                , onClick <| FePlaceMeeple position
                ]
                []
            ]

    else
        div [] []


viewDebugOverlay : TileGrid -> Html FrontendMsg
viewDebugOverlay tileGrid =
    let
        coordinates =
            Dict.keys tileGrid

        minX =
            List.minimum (List.map Tuple.first coordinates) |> Maybe.withDefault 0

        maxX =
            List.maximum (List.map Tuple.first coordinates) |> Maybe.withDefault 0

        minY =
            List.minimum (List.map Tuple.second coordinates) |> Maybe.withDefault 0

        maxY =
            List.maximum (List.map Tuple.second coordinates) |> Maybe.withDefault 0

        rows =
            List.range (minY - 1) (maxY + 1)
                |> List.reverse
                |> List.map
                    (\y ->
                        div [ style "display" "flex" ]
                            (List.range (minX - 1) (maxX + 1)
                                |> List.map (\x -> renderDebugCell (Dict.get ( x, y ) tileGrid))
                            )
                    )
    in
    div
        [ style "display" "flex"
        , style "justify-content" "center"
        , style "align-items" "center"
        , style "min-height" "100vh"
        , style "pointer-events" "none"
        ]
        [ div
            [ style "display" "flex"
            , style "flex-direction" "column"
            , style "gap" "0px"
            ]
            rows
        ]


renderDebugCell : Maybe Tile -> Html FrontendMsg
renderDebugCell maybeTile =
    case maybeTile of
        Just tile ->
            div
                [ style "width" "64px"
                , style "height" "64px"
                , style "display" "grid"
                , style "grid-template-columns" "repeat(3, 1fr)"
                , style "grid-template-rows" "repeat(3, 1fr)"
                , style "gap" "2px"
                , style "background-color" "transparent"
                ]
                [ div [] []
                , renderDebugSideId (Just tile.north.sideId)
                , div [] []
                , renderDebugSideId (Just tile.west.sideId)
                , renderDebugSideId tile.cloister
                , renderDebugSideId (Just tile.east.sideId)
                , div [] []
                , renderDebugSideId (Just tile.south.sideId)
                , div [] []
                ]

        Nothing ->
            renderEmptyTile


renderDebugSideId : Maybe SideId -> Html FrontendMsg
renderDebugSideId sideId =
    div
        [ style "display" "flex"
        , style "justify-content" "center"
        , style "align-items" "center"
        ]
        [ text <| (sideId |> Maybe.map String.fromInt |> Maybe.withDefault "") ]


renderEmptyTile : Html FrontendMsg
renderEmptyTile =
    div
        [ style "width" "64px"
        , style "height" "64px"
        , style "background-color" "transparent"
        ]
        []


renderSideBar : Game -> PlayerName -> Html FrontendMsg
renderSideBar game yourPlayerName =
    div
        [ style "width" "500px"
        , style "background-color" "#444444"
        , style "color" "white"
        , style "padding" "16px"
        , style "box-sizing" "border-box"
        , style "height" "100vh"
        , style "min-height" "100vh"
        , style "font-family" "Roboto, Arial, sans-serif"
        ]
        (div
            [ style "font-weight" "bold"
            , style "font-size" "36px"
            , style "text-align" "center"
            , style "width" "100%"
            ]
            [ text (GameState.toString game.gameState) ]
            :: div [] [ text ("Playing as: " ++ yourPlayerName) ]
            :: br [] []
            :: br [] []
            :: (List.range 0 (Array.length game.players - 1)
                    |> List.map
                        (\playerIndex ->
                            let
                                playerName =
                                    Array.get playerIndex game.players |> Maybe.withDefault ""

                                playerScore =
                                    Dict.get playerName game.playerScores |> Maybe.withDefault 0

                                availableMeeples =
                                    Dict.get playerName game.playerMeeples |> Maybe.withDefault 0
                            in
                            div
                                [ style "display" "flex"
                                , style "align-items" "center"
                                , style "margin-bottom" "8px"
                                ]
                                [ div [ style "flex" "1" ]
                                    [ text <|
                                        playerName
                                            ++ (if playerIndex == game.currentPlayer then
                                                    " (Now playing)"

                                                else
                                                    ""
                                               )
                                    ]
                                , div [ style "margin-right" "10px" ] [ text ("Score: " ++ String.fromInt playerScore) ]
                                , div
                                    [ style "display" "flex"
                                    , style "align-items" "center"
                                    ]
                                    [ text (String.fromInt availableMeeples)
                                    , img
                                        [ src (getMeepleImageSource playerIndex)
                                        , style "width" "16px"
                                        , style "height" "16px"
                                        , style "margin-left" "4px"
                                        ]
                                        []
                                    ]
                                ]
                        )
               )
            ++ [ br [] []
               , br [] []
               , div
                    [ style "margin" "24px auto"
                    , style "width" "150px"
                    , style "height" "150px"
                    , style "display" "flex"
                    , style "align-items" "center"
                    , style "justify-content" "center"
                    , style "background-color" "#222"
                    ]
                    [ img
                        ([ width 150
                         , height 150
                         , style "transition" "transform 0.2s"
                         ]
                            ++ (if game.gameState == PlaceTileState then
                                    [ src <| getTileImageSource game.tileToPlace.tileId
                                    , style "transform" ("rotate(" ++ String.fromInt (negate game.tileToPlace.rotation) ++ "deg)")
                                    ]

                                else
                                    [ src "questionmark.png" ]
                               )
                        )
                        []
                    ]
               , br [] []
               , br [] []
               , button
                    (onClick FeRotateTileLeft :: buttonMain)
                    [ text "Rotate Tile" ]
               , button
                    (onClick FeTerminateGame :: buttonMain)
                    [ text "Terminate Game" ]
               , button
                    (onClick ChangeDebugMode :: buttonMain)
                    [ text "Debug mode" ]
               ]
        )
