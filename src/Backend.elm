module Backend exposing (..)

import Helpers.FrontendHelpers exposing (getPlayableTileFromDrawstack)
import Helpers.GameLogic exposing (finishGame, placeMeeple, placeTile, rotateLeft)
import Helpers.TileMapper exposing (getTile)
import Lamdera exposing (ClientId, SessionId, broadcast, sendToFrontend)
import Random
import Random.List
import Types exposing (..)
import Types.Game exposing (..)
import Types.PlayerName exposing (PlayerName)


type alias Model =
    BackendModel


app : { init : ( Model, Cmd BackendMsg ), update : BackendMsg -> Model -> ( Model, Cmd BackendMsg ), updateFromFrontend : SessionId -> ClientId -> ToBackend -> Model -> ( Model, Cmd BackendMsg ), subscriptions : Model -> Sub BackendMsg }
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
            Debug.log sessionId
                ( model, sendToFrontend clientId <| PlayerRegistrationUpdated { players = rest.players } )

        ( InitializeGameAndTileDrawStackShuffled shuffledTileDrawStack, BeGamePlayed { game } ) ->
            let
                ( maybeNextTileId, drawStack ) =
                    getPlayableTileFromDrawstack game.tileGrid shuffledTileDrawStack

                updatedGame : Game
                updatedGame =
                    { game
                        | tileToPlace = getTile (Maybe.withDefault 0 maybeNextTileId)
                        , tileDrawStack = drawStack
                    }
            in
            -- First move should be always possible
            ( BeGamePlayed { game = updatedGame }
            , broadcast (GameInitialized { game = updatedGame })
            )

        ( TileDrawStackShuffled shuffledTileDrawStack, BeGamePlayed { game } ) ->
            case getPlayableTileFromDrawstack game.tileGrid shuffledTileDrawStack of
                ( Just nextTileId, drawStack ) ->
                    let
                        updatedGame : Game
                        updatedGame =
                            { game
                                | tileToPlace = getTile nextTileId
                                , tileDrawStack = drawStack
                            }
                    in
                    ( BeGamePlayed { game = updatedGame }
                    , broadcast (UpdateGameState { game = updatedGame })
                    )

                ( Nothing, _ ) ->
                    let
                        updatedGame : Game
                        updatedGame =
                            finishGame game
                    in
                    ( BeGamePlayed { game = updatedGame }
                    , broadcast (UpdateGameState { game = updatedGame })
                    )

        _ ->
            ( model, Cmd.none )


updateFromFrontend : SessionId -> ClientId -> ToBackend -> Model -> ( Model, Cmd BackendMsg )
updateFromFrontend _ clientId msg model =
    case ( msg, model ) of
        ( RegisterPlayer playerName, BePlayerRegistration { players } ) ->
            let
                nameExists : Bool
                nameExists =
                    List.member playerName players
            in
            if nameExists then
                ( model
                , sendToFrontend clientId (PlayerRegistrationUpdated { players = players })
                )

            else
                let
                    newPlayers : List PlayerName
                    newPlayers =
                        playerName :: players
                in
                if List.length newPlayers <= playerLimit then
                    ( BePlayerRegistration { players = newPlayers }
                    , broadcast (PlayerRegistrationUpdated { players = newPlayers })
                    )

                else
                    ( BePlayerRegistration { players = players }
                    , sendToFrontend clientId LobbyIsFull
                    )

        ( RegisterPlayer _, BeGamePlayed { game } ) ->
            ( model
            , sendToFrontend clientId (JoinedGame { game = game })
            )

        ( KickPlayer playerName, BePlayerRegistration { players } ) ->
            let
                newPlayers : List PlayerName
                newPlayers =
                    List.filter (\name -> name /= playerName) players
            in
            ( BePlayerRegistration { players = newPlayers }
            , broadcast (PlayerKicked { kickedPlayer = playerName, players = newPlayers })
            )

        ( KillLobby, BePlayerRegistration _ ) ->
            ( BePlayerRegistration { players = [] }
            , broadcast LobbyKilled
            )

        ( InitializeGame, BePlayerRegistration { players } ) ->
            let
                game : Game
                game =
                    initializeGame players
            in
            ( BeGamePlayed { game = game }
            , Random.generate InitializeGameAndTileDrawStackShuffled (Random.List.shuffle game.tileDrawStack)
            )

        ( RotateTileLeft, BeGamePlayed { game } ) ->
            let
                updatedGame : Game
                updatedGame =
                    { game | tileToPlace = rotateLeft game.tileToPlace }
            in
            ( BeGamePlayed { game = updatedGame }
            , broadcast (UpdateGameState { game = updatedGame })
            )

        ( PlaceTile coordinates, BeGamePlayed { game } ) ->
            let
                updatedGame : Game
                updatedGame =
                    placeTile game coordinates
            in
            ( BeGamePlayed { game = updatedGame }
            , broadcast (UpdateGameState { game = updatedGame })
            )

        ( PlaceMeeple position, BeGamePlayed { game } ) ->
            let
                updatedGame : Game
                updatedGame =
                    placeMeeple game position
            in
            ( BeGamePlayed { game = updatedGame }
            , Random.generate TileDrawStackShuffled (Random.List.shuffle updatedGame.tileDrawStack)
            )

        ( TerminateGame, BeGamePlayed _ ) ->
            ( BePlayerRegistration { players = [] }
            , broadcast GameTerminated
            )

        _ ->
            ( model, Cmd.none )


subscriptions : a -> Sub BackendMsg
subscriptions _ =
    Lamdera.onConnect ClientConnected
