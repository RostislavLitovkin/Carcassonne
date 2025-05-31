module Evergreen.V5.Types exposing (..)

import Evergreen.V5.Types.Game
import Evergreen.V5.Types.PlayerName
import Lamdera


type FrontendModel
    = FePlayerRegistration
        { nameInput : String
        , error : Maybe String
        }
    | FeLobby
        { playerName : Evergreen.V5.Types.PlayerName.PlayerName
        , players : List Evergreen.V5.Types.PlayerName.PlayerName
        }
    | FeGamePlayed
        { playerName : Evergreen.V5.Types.PlayerName.PlayerName
        , game : Evergreen.V5.Types.Game.Game
        }


type BackendModel
    = BePlayerRegistration
        { players : List Evergreen.V5.Types.PlayerName.PlayerName
        }
    | BeGamePlayed
        { game : Evergreen.V5.Types.Game.Game
        }


type FrontendMsg
    = NameInputChanged String
    | Register
    | Kick Evergreen.V5.Types.PlayerName.PlayerName
    | FeInitializeGame
    | FeRotateTileLeft
    | FePlaceTile Evergreen.V5.Types.Game.Coordinate
    | FeTerminateGame
    | ClearError
    | FNoop


type ToBackend
    = RegisterPlayer Evergreen.V5.Types.PlayerName.PlayerName
    | KickPlayer Evergreen.V5.Types.PlayerName.PlayerName
    | InitializeGame
    | RotateTileLeft
    | PlaceTile Evergreen.V5.Types.Game.Coordinate
    | TerminateGame


type BackendMsg
    = ClientConnected Lamdera.SessionId Lamdera.ClientId
    | NoOpBackendMsg


type ToFrontend
    = PlayerRegistrationUpdated
        { players : List Evergreen.V5.Types.PlayerName.PlayerName
        }
    | PlayerKicked
        { players : List Evergreen.V5.Types.PlayerName.PlayerName
        , kickedPlayer : Evergreen.V5.Types.PlayerName.PlayerName
        }
    | GameInitialized
        { game : Evergreen.V5.Types.Game.Game
        }
    | UpdateGameState
        { game : Evergreen.V5.Types.Game.Game
        }
    | JoinedGame
        { game : Evergreen.V5.Types.Game.Game
        }
    | GameTerminated
