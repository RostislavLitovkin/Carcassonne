module Frontend exposing (Model, app)

import Array
import Dict
import Helpers.GameLogic exposing (..)
import Helpers.TileMapper exposing (..)
import Html exposing (Html, br, button, div, img, input, li, text, ul)
import Html.Attributes exposing (height, placeholder, src, style, value, width)
import Html.Events exposing (onClick, onInput, onSubmit)
import Lamdera exposing (sendToBackend)
import Set exposing (Set)
import String
import Styles
import Types exposing (..)
import Types.Game exposing (..)
import Types.GameState exposing (..)
import Types.PlayerName exposing (..)
import Types.Tile exposing (..)


type alias Model =
    FrontendModel


app =
    Lamdera.frontend
        { init = \_ _ -> init
        , update = update
        , updateFromBackend = updateFromBackend
        , view =
            \model ->
                { title = "Carcassonne"
                , body = [ view model ]
                }
        , subscriptions = \_ -> Sub.none
        , onUrlChange = \_ -> FNoop
        , onUrlRequest = \_ -> FNoop
        }


init : ( Model, Cmd FrontendMsg )
init =
    ( FePlayerRegistration
        { nameInput = ""
        , error = Nothing
        }
    , Cmd.none
    )


update : FrontendMsg -> Model -> ( Model, Cmd FrontendMsg )
update msg model =
    case ( msg, model ) of
        ( NameInputChanged str, FePlayerRegistration rest ) ->
            ( FePlayerRegistration { rest | nameInput = str, error = Nothing }, Cmd.none )

        ( Register, FePlayerRegistration rest ) ->
            let
                trimmedPlayerName =
                    String.trim rest.nameInput
            in
            if String.isEmpty trimmedPlayerName then
                ( FePlayerRegistration { rest | error = Just "Name cannot be empty." }, Cmd.none )

            else
                ( FeLobby { playerName = trimmedPlayerName, players = [] }
                , sendToBackend <| RegisterPlayer trimmedPlayerName
                )

        ( ClearError, FePlayerRegistration rest ) ->
            ( FePlayerRegistration { rest | error = Nothing }, Cmd.none )

        ( Kick playerName, _ ) ->
            ( model, sendToBackend <| KickPlayer playerName )

        ( FeInitializeGame, _ ) ->
            ( model, sendToBackend InitializeGame )

        ( FeRotateTileLeft, _ ) ->
            ( model, sendToBackend RotateTileLeft )

        ( ChangeDebugMode, FeGamePlayed { game, debugMode, playerName } ) ->
            ( FeGamePlayed { game = game, debugMode = not debugMode, playerName = playerName }, Cmd.none )

        ( FePlaceTile coordinates, _ ) ->
            ( model, sendToBackend <| PlaceTile coordinates )

        ( FePlaceMeeple position, _ ) ->
            ( model, sendToBackend <| PlaceMeeple position )

        ( FeTerminateGame, _ ) ->
            ( model, sendToBackend TerminateGame )

        _ ->
            ( model, Cmd.none )


updateFromBackend : ToFrontend -> Model -> ( Model, Cmd FrontendMsg )
updateFromBackend msg model =
    case ( msg, model ) of
        ( PlayerRegistrationUpdated { players }, FeLobby rest ) ->
            ( FeLobby { rest | players = players }, Cmd.none )

        ( PlayerKicked { kickedPlayer, players }, FeLobby { playerName } ) ->
            if playerName == kickedPlayer then
                init

            else
                ( FeLobby { playerName = playerName, players = players }
                , Cmd.none
                )

        ( JoinedGame { game }, FeLobby { playerName } ) ->
            ( FeGamePlayed
                { playerName = playerName
                , debugMode = False
                , game = game
                }
            , Cmd.none
            )

        ( GameInitialized { game }, FeLobby { playerName } ) ->
            ( FeGamePlayed
                { playerName = playerName
                , debugMode = False
                , game = game
                }
            , Cmd.none
            )

        ( UpdateGameState { game }, FeGamePlayed { playerName, debugMode } ) ->
            ( FeGamePlayed
                { playerName = playerName
                , debugMode = debugMode
                , game = game
                }
            , Cmd.none
            )

        ( GameTerminated, FeGamePlayed _ ) ->
            init

        _ ->
            ( model, Cmd.none )



-- VIEW


view : Model -> Html FrontendMsg
view model =
    case model of
        FePlayerRegistration rest ->
            div Styles.container
                [ div []
                    [ Html.form
                        [ onSubmit Register ]
                        [ input
                            (Styles.inputBox
                                ++ [ placeholder "Enter your name"
                                   , value rest.nameInput
                                   , onInput NameInputChanged
                                   ]
                            )
                            []
                        , button
                            (Styles.buttonMain ++ [ onClick Register ])
                            [ text "Join" ]
                        ]
                    ]
                , case rest.error of
                    Just err ->
                        div Styles.errorBox [ text err ]

                    Nothing ->
                        text ""
                ]

        FeLobby { playerName, players } ->
            div Styles.container
                [ div []
                    [ text "Your name: "
                    , text playerName
                    , br [] []
                    , text "All players:"
                    , playerNamesView players
                    , button
                        (Styles.buttonMain ++ [ onClick FeInitializeGame ])
                        [ text "Start" ]
                    ]
                ]

        FeGamePlayed { playerName, game, debugMode } ->
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

                _ ->
                    div [] []



--_ -> div [] []


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
        meeplePositions =
            toMeeplePositions meeples

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
                                |> List.map (\x -> renderMeepleCell <| Dict.get ( x, y ) meeplePositions)
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
        ]
        (div [] [ text ("Playing as: " ++ yourPlayerName) ]
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
            ++ [ div
                    [ style "margin" "24px auto"
                    , style "width" "150px"
                    , style "height" "150px"
                    , style "display" "flex"
                    , style "align-items" "center"
                    , style "justify-content" "center"
                    , style "background-color" "#222"
                    ]
                    [ img
                        [ src (getTileImageSource game.tileToPlace.tileId)
                        , width 150
                        , height 150
                        , style "transform" ("rotate(" ++ String.fromInt (negate game.tileToPlace.rotation) ++ "deg)")
                        , style "transition" "transform 0.2s"
                        ]
                        []
                    ]
               , button
                    [ onClick FeRotateTileLeft
                    , style "margin-top" "16px"
                    , style "padding" "8px 16px"
                    , style "background-color" "#666"
                    , style "color" "white"
                    , style "border" "none"
                    , style "cursor" "pointer"
                    ]
                    [ text "Rotate Tile" ]
               , button
                    [ onClick FeTerminateGame
                    , style "margin-top" "16px"
                    , style "padding" "8px 16px"
                    , style "background-color" "#666"
                    , style "color" "white"
                    , style "border" "none"
                    , style "cursor" "pointer"
                    ]
                    [ text "Terminate Game" ]
               , button
                    [ onClick ChangeDebugMode
                    , style "margin-top" "16px"
                    , style "padding" "8px 16px"
                    , style "background-color" "#666"
                    , style "color" "white"
                    , style "border" "none"
                    , style "cursor" "pointer"
                    ]
                    [ text "Change debug mode" ]
               ]
        )


playerNamesView : List PlayerName -> Html FrontendMsg
playerNamesView players =
    ul Styles.playerList
        (List.map
            (\name ->
                li Styles.playerItem
                    [ text name
                    , text " "
                    , div [ onClick <| Kick name, Html.Attributes.style "color" "red" ] [ text "kick" ]
                    ]
            )
            players
        )
