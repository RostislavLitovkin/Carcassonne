module Evergreen.V3.Types exposing (..)

import Evergreen.V3.Types.Game
import Evergreen.V3.Types.PlayerName
import Lamdera


type FrontendModel
    = FePlayerRegistration
        { nameInput : String
        , error : Maybe String
        }
    | FeLobby
        { playerName : Evergreen.V3.Types.PlayerName.PlayerName
        , players : List Evergreen.V3.Types.PlayerName.PlayerName
        }
    | FeGamePlayed
        { playerName : Evergreen.V3.Types.PlayerName.PlayerName
        , game : Evergreen.V3.Types.Game.Game
        }


type BackendModel
    = BePlayerRegistration
        { players : List Evergreen.V3.Types.PlayerName.PlayerName
        }
    | BeGamePlayed
        { game : Evergreen.V3.Types.Game.Game
        }


type FrontendMsg
    = NameInputChanged String
    | Register
    | Kick Evergreen.V3.Types.PlayerName.PlayerName
    | FeInitializeGame
    | FeRotateTileLeft
    | FePlaceTile Evergreen.V3.Types.Game.Coordinate
    | ClearError
    | FNoop


type ToBackend
    = RegisterPlayer Evergreen.V3.Types.PlayerName.PlayerName
    | KickPlayer Evergreen.V3.Types.PlayerName.PlayerName
    | InitializeGame
    | RotateTileLeft
    | PlaceTile Evergreen.V3.Types.Game.Coordinate


type BackendMsg
    = ClientConnected Lamdera.SessionId Lamdera.ClientId
    | NoOpBackendMsg


type ToFrontend
    = PlayerRegistrationUpdated
        { players : List Evergreen.V3.Types.PlayerName.PlayerName
        }
    | PlayerKicked
        { players : List Evergreen.V3.Types.PlayerName.PlayerName
        , kickedPlayer : Evergreen.V3.Types.PlayerName.PlayerName
        }
    | GameInitialized
        { game : Evergreen.V3.Types.Game.Game
        }
    | UpdateGameState
        { game : Evergreen.V3.Types.Game.Game
        }
