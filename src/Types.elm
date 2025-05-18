module Types exposing (..)

import Browser exposing (UrlRequest)
import Browser.Navigation exposing (Key)
import Url exposing (Url)
import Types.PlayerName exposing (..)
import Lamdera exposing (ClientId, SessionId)


type BackendModel =
    BePlayerRegistration {
        players : List PlayerName
    }

type FrontendModel
    = FePlayerRegistration { nameInput : String
                           , error : Maybe String
                           }
    | FeLobby { playerName : PlayerName
    , players : List PlayerName
    }

type FrontendMsg
    = NameInputChanged String
    | Register
    | Kick PlayerName
    | ClearError
    | FNoop


type ToBackend
    = RegisterPlayer PlayerName
    | KickPlayer PlayerName


type BackendMsg
    = ClientConnected SessionId ClientId
    | NoOpBackendMsg


type ToFrontend
    = PlayerRegistrationUpdated {
        players : List PlayerName
    }
    | PlayerKicked { players : List PlayerName
    , kickedPlayer : PlayerName
    }