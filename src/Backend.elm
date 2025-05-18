module Backend exposing (..)


import Lamdera exposing (ClientId, SessionId, broadcast, sendToFrontend)
import Types exposing (..)


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
    ( BePlayerRegistration {
        players = []
    }
    , Cmd.none
    )


update : BackendMsg -> Model -> ( Model, Cmd BackendMsg )
update msg model =
    case (msg, model) of
        (ClientConnected sessionId clientId, BePlayerRegistration rest) ->
            ( model, sendToFrontend clientId <| PlayerRegistrationUpdated { players = rest.players } )

        _ ->
            ( model, Cmd.none )

updateFromFrontend : SessionId -> ClientId -> ToBackend -> Model -> ( Model, Cmd BackendMsg )
updateFromFrontend sessionId clientId msg model =
    case (msg, model) of
        (RegisterPlayer playerName, BePlayerRegistration { players }) ->
            let
                nameExists = List.member playerName players
                
                newPlayers = playerName :: players
            in
                if (nameExists) then
                    ( model
                    , sendToFrontend clientId (PlayerRegistrationUpdated { players = players })
                    )
                else 
                    ( BePlayerRegistration { players = newPlayers }
                    , broadcast (PlayerRegistrationUpdated { players = newPlayers })
                    )
        (KickPlayer playerName, BePlayerRegistration { players }) ->
            let
                newPlayers = List.filter (\name -> name /= playerName) players
            in
                ( BePlayerRegistration { players = newPlayers }
                , broadcast (PlayerKicked { kickedPlayer = playerName, players = newPlayers })
                )

        --_ -> ( model, Cmd.none )


subscriptions model =
    Sub.batch
        [ Lamdera.onConnect ClientConnected
        ]