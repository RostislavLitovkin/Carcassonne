module Backend exposing (..)

import Helpers.GameLogic exposing (placeTile, rotateLeft)
import Lamdera exposing (ClientId, SessionId, broadcast, sendToFrontend)
import Types exposing (..)
import Types.Game exposing (initializeGame)


type alias Model =
    BackendModel


app =
    Lamdera.backend
        { init = init
        , update = update
        , updateFromFrontend = updateFromFrontend
        , subscriptions = subscriptions
        }


init : ( Model, Cmd BackendMsg )
init =
    ( BePlayerRegistration
        { players = []
        }
    , Cmd.none
    )


update : BackendMsg -> Model -> ( Model, Cmd BackendMsg )
update msg model =
    case ( msg, model ) of
        ( ClientConnected sessionId clientId, BePlayerRegistration rest ) ->
            ( model, sendToFrontend clientId <| PlayerRegistrationUpdated { players = rest.players } )

        _ ->
            ( model, Cmd.none )


updateFromFrontend : SessionId -> ClientId -> ToBackend -> Model -> ( Model, Cmd BackendMsg )
updateFromFrontend sessionId clientId msg model =
    case ( msg, model ) of
        ( RegisterPlayer playerName, BePlayerRegistration { players } ) ->
            let
                nameExists =
                    List.member playerName players

                newPlayers =
                    playerName :: players
            in
            if nameExists then
                ( model
                , sendToFrontend clientId (PlayerRegistrationUpdated { players = players })
                )

            else
                ( BePlayerRegistration { players = newPlayers }
                , broadcast (PlayerRegistrationUpdated { players = newPlayers })
                )

        ( KickPlayer playerName, BePlayerRegistration { players } ) ->
            let
                newPlayers =
                    List.filter (\name -> name /= playerName) players
            in
            ( BePlayerRegistration { players = newPlayers }
            , broadcast (PlayerKicked { kickedPlayer = playerName, players = newPlayers })
            )

        ( InitializeGame, BePlayerRegistration { players } ) ->
            let
                game =
                    initializeGame players
            in
            ( BeGamePlayed { game = game }
            , broadcast (GameInitialized { game = game })
            )

        ( RotateTileLeft, BeGamePlayed { game } ) ->
            let
                updatedGame =
                    { game | tileToPlace = rotateLeft game.tileToPlace }
            in
            ( BeGamePlayed { game = updatedGame }
            , broadcast (UpdateGameState { game = updatedGame })
            )

        ( PlaceTile coordinates, BeGamePlayed { game } ) ->
            let
                updatedGame =
                    placeTile game coordinates
            in
            ( BeGamePlayed { game = updatedGame }
            , broadcast (UpdateGameState { game = updatedGame })
            )

        _ ->
            ( model, Cmd.none )


subscriptions model =
    Sub.batch
        [ Lamdera.onConnect ClientConnected
        ]
