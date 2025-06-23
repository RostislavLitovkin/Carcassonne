module Frontend exposing (Model, app)

import Html exposing (Html)
import Lamdera exposing (Document, Key, Url, UrlRequest, sendToBackend)
import String
import Types exposing (..)
import Types.PlayerName exposing (..)
import Views.GameView exposing (renderGameView)
import Views.PlayerLobbyView exposing (renderPlayerLobbyView)
import Views.PlayerRegistrationView exposing (renderPlayerRegistrationView)


type alias Model =
    FrontendModel


app : { init : Lamdera.Url -> Key -> ( Model, Cmd FrontendMsg ), view : Model -> Document FrontendMsg, update : FrontendMsg -> Model -> ( Model, Cmd FrontendMsg ), updateFromBackend : ToFrontend -> Model -> ( Model, Cmd FrontendMsg ), subscriptions : Model -> Sub FrontendMsg, onUrlRequest : UrlRequest -> FrontendMsg, onUrlChange : Url -> FrontendMsg }
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
                trimmedPlayerName : PlayerName
                trimmedPlayerName =
                    String.trim rest.nameInput
            in
            if String.isEmpty trimmedPlayerName then
                ( FePlayerRegistration { rest | error = Just "Name cannot be empty." }, Cmd.none )

            else
                ( FeLobby { playerName = trimmedPlayerName, players = [] }
                , sendToBackend <| RegisterPlayer trimmedPlayerName
                )

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

        ( FeKillLobby, _ ) ->
            ( model, sendToBackend KillLobby )

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

        ( LobbyIsFull, FePlayerRegistration { nameInput } ) ->
            ( FePlayerRegistration { nameInput = nameInput, error = Just "Lobby is full." }
            , Cmd.none
            )

        ( LobbyIsFull, FeLobby { playerName } ) ->
            ( FePlayerRegistration { nameInput = playerName, error = Just "Lobby is full." }
            , Cmd.none
            )

        ( LobbyKilled, FePlayerRegistration { nameInput } ) ->
            ( FePlayerRegistration { nameInput = nameInput, error = Nothing }
            , Cmd.none
            )

        ( LobbyKilled, FeLobby _ ) ->
            init

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
