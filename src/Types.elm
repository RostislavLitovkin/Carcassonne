module Types exposing (..)

import Browser exposing (UrlRequest)
import Browser.Navigation exposing (Key)
import Lamdera exposing (ClientId, SessionId)
import Types.Game exposing (Coordinate, Game)
import Types.PlayerName exposing (..)
import Url exposing (Url)


type BackendModel
    = BePlayerRegistration
        { players : List PlayerName
        }
    | BeGamePlayed
        { game : Game
        }


type FrontendModel
    = FePlayerRegistration
        { nameInput : String
        , error : Maybe String
        }
    | FeLobby
        { playerName : PlayerName
        , players : List PlayerName
        }
    | FeGamePlayed
        { playerName : PlayerName
        , game : Game
        }


type FrontendMsg
    = NameInputChanged String
    | Register
    | Kick PlayerName
    | FeInitializeGame
    | FeRotateTileLeft
    | FePlaceTile Coordinate
    | ClearError
    | FNoop


type ToBackend
    = RegisterPlayer PlayerName
    | KickPlayer PlayerName
    | InitializeGame
    | RotateTileLeft
    | PlaceTile Coordinate


type BackendMsg
    = ClientConnected SessionId ClientId
    | NoOpBackendMsg


type ToFrontend
    = PlayerRegistrationUpdated
        { players : List PlayerName
        }
    | PlayerKicked
        { players : List PlayerName
        , kickedPlayer : PlayerName
        }
    | GameInitialized
        { game : Game
        }
    | UpdateGameState
        { game : Game
        }
