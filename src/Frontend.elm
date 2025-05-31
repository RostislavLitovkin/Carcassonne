module Frontend exposing (Model, app)

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
import Types.Game exposing (Coordinate, Game, TileGrid)
import Types.PlayerName exposing (..)
import Types.Tile exposing (getTileImageSource)


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

        ( FePlaceTile coordinates, _ ) ->
            ( model, sendToBackend <| PlaceTile coordinates )

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
                , game = game
                }
            , Cmd.none
            )

        ( GameInitialized { game }, FeLobby { playerName } ) ->
            ( FeGamePlayed
                { playerName = playerName
                , game = game
                }
            , Cmd.none
            )

        ( UpdateGameState { game }, FeGamePlayed { playerName } ) ->
            ( FeGamePlayed
                { playerName = playerName
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

        FeGamePlayed { playerName, game } ->
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
                , div [ style "flex" "1" ]
                    [ viewTileGrid game.tileGrid coordinatesToBePlacedOn ]
                ]



--_ -> div [] []


viewTileGrid : TileGrid -> Set Coordinate -> Html FrontendMsg
viewTileGrid tileGrid coordinatesToBePlacedOn =
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
                                |> List.map (\x -> renderTileCell ( x, y ) tileGrid coordinatesToBePlacedOn)
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


renderTileCell : Coordinate -> TileGrid -> Set Coordinate -> Html FrontendMsg
renderTileCell coord grid coordinatesToBePlacedOn =
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
                div
                    [ style "width" "64px"
                    , style "height" "64px"
                    , style "background-color" "transparent"
                    , style "border" "1px solid #ccc"
                    ]
                    []


renderSideBar : Game -> PlayerName -> Html FrontendMsg
renderSideBar game playerName =
    let
        otherPlayers =
            List.filter (\p -> p /= playerName) game.players
    in
    div
        [ style "width" "500px"
        , style "background-color" "#444444"
        , style "color" "white"
        , style "padding" "16px"
        , style "box-sizing" "border-box"
        , style "height" "100vh"
        , style "min-height" "100vh"
        ]
        ([ div [] [ text ("Playing as: " ++ playerName) ] ]
            ++ List.map (\p -> div [] [ text p ]) otherPlayers
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
