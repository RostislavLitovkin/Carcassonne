module Frontend exposing (Model, app)

import Array
import Dict
import Helpers.FrontendHelpers exposing (..)
import Helpers.GameLogic exposing (..)
import Helpers.TileMapper exposing (..)
import Html exposing (Html, br, button, div, img, li, text, ul)
import Html.Attributes exposing (height, src, style, width)
import Html.Events exposing (onClick)
import Lamdera exposing (sendToBackend)
import Set exposing (Set)
import String
import Styles
import Types exposing (..)
import Types.Coordinate exposing (Coordinate)
import Types.Game exposing (..)
import Types.GameState exposing (..)
import Types.Meeple exposing (..)
import Types.PlayerName exposing (..)
import Types.Tile exposing (..)
import Views.GameView exposing (renderGameView)
import Views.PlayerLobbyView exposing (renderPlayerLobbyView)
import Views.PlayerRegistrationView exposing (renderPlayerRegistrationView)


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


view : Model -> Html FrontendMsg
view model =
    case model of
        FePlayerRegistration { nameInput, error } ->
            renderPlayerRegistrationView nameInput error

        FeLobby { playerName, players } ->
            renderPlayerLobbyView playerName players

        FeGamePlayed { playerName, game, debugMode } ->
            renderGameView playerName game debugMode
