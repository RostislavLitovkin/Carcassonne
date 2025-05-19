module Evergreen.V1.Types exposing (..)

import Evergreen.V1.Types.PlayerName
import Lamdera


type FrontendModel
    = FePlayerRegistration
        { nameInput : String
        , error : Maybe String
        }
    | FeLobby
        { playerName : Evergreen.V1.Types.PlayerName.PlayerName
        , players : List Evergreen.V1.Types.PlayerName.PlayerName
        }


type BackendModel
    = BePlayerRegistration
        { players : List Evergreen.V1.Types.PlayerName.PlayerName
        }


type FrontendMsg
    = NameInputChanged String
    | Register
    | Kick Evergreen.V1.Types.PlayerName.PlayerName
    | ClearError
    | FNoop


type ToBackend
    = RegisterPlayer Evergreen.V1.Types.PlayerName.PlayerName
    | KickPlayer Evergreen.V1.Types.PlayerName.PlayerName


type BackendMsg
    = ClientConnected Lamdera.SessionId Lamdera.ClientId
    | NoOpBackendMsg


type ToFrontend
    = PlayerRegistrationUpdated
        { players : List Evergreen.V1.Types.PlayerName.PlayerName
        }
    | PlayerKicked
        { players : List Evergreen.V1.Types.PlayerName.PlayerName
        , kickedPlayer : Evergreen.V1.Types.PlayerName.PlayerName
        }
