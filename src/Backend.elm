module Backend exposing (..)

import Helpers.FrontendHelpers exposing (getPlayableTileFromDrawstack)
import Helpers.GameLogic exposing (finishGame, placeMeeple, placeTile, rotateLeft)
import Helpers.TileMapper exposing (getTile)
import Lamdera exposing (ClientId, SessionId, broadcast, sendToFrontend)
import Random
import Random.List
import Types exposing (..)
import Types.Game exposing (Game, initializeGame)


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
        ( ClientConnected _ clientId, BePlayerRegistration rest ) ->
            ( model, sendToFrontend clientId <| PlayerRegistrationUpdated { players = rest.players } )

        ( InitializeGameAndTileDrawStackShuffled shuffledTileDrawStack, BeGamePlayed { game } ) ->
            let
                ( maybeNextTileId, drawStack ) =
                    getPlayableTileFromDrawstack game.tileGrid shuffledTileDrawStack

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

        ( RegisterPlayer _, BeGamePlayed { game } ) ->
            ( model
            , sendToFrontend clientId (JoinedGame { game = game })
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
            , Random.generate InitializeGameAndTileDrawStackShuffled (Random.List.shuffle game.tileDrawStack)
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

        ( PlaceMeeple position, BeGamePlayed { game } ) ->
            let
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


subscriptions _ =
    Sub.batch
        [ Lamdera.onConnect ClientConnected
        ]
