module Evergreen.V10.Types exposing (..)

import Evergreen.V10.Types.Coordinate
import Evergreen.V10.Types.Game
import Evergreen.V10.Types.Meeple
import Evergreen.V10.Types.PlayerName
import Evergreen.V10.Types.Tile
import Lamdera


type FrontendModel
    = FePlayerRegistration
        { nameInput : String
        , error : Maybe String
        }
    | FeLobby
        { playerName : Evergreen.V10.Types.PlayerName.PlayerName
        , players : List Evergreen.V10.Types.PlayerName.PlayerName
        }
    | FeGamePlayed
        { playerName : Evergreen.V10.Types.PlayerName.PlayerName
        , debugMode : Bool
        , game : Evergreen.V10.Types.Game.Game
        }


type BackendModel
    = BePlayerRegistration
        { players : List Evergreen.V10.Types.PlayerName.PlayerName
        }
    | BeGamePlayed
        { game : Evergreen.V10.Types.Game.Game
        }


type FrontendMsg
    = NameInputChanged String
    | Register
    | Kick Evergreen.V10.Types.PlayerName.PlayerName
    | FeKillLobby
    | FeInitializeGame
    | FeRotateTileLeft
    | ChangeDebugMode
    | FePlaceTile Evergreen.V10.Types.Coordinate.Coordinate
    | FePlaceMeeple Evergreen.V10.Types.Meeple.MeeplePosition
    | FeTerminateGame
    | ClearError
    | FNoop


type ToBackend
    = RegisterPlayer Evergreen.V10.Types.PlayerName.PlayerName
    | KickPlayer Evergreen.V10.Types.PlayerName.PlayerName
    | KillLobby
    | InitializeGame
    | RotateTileLeft
    | PlaceTile Evergreen.V10.Types.Coordinate.Coordinate
    | PlaceMeeple Evergreen.V10.Types.Meeple.MeeplePosition
    | TerminateGame


type BackendMsg
    = ClientConnected Lamdera.SessionId Lamdera.ClientId
    | InitializeGameAndTileDrawStackShuffled (List Evergreen.V10.Types.Tile.SideId)
    | TileDrawStackShuffled (List Evergreen.V10.Types.Tile.SideId)
    | NoOpBackendMsg


type ToFrontend
    = PlayerRegistrationUpdated
        { players : List Evergreen.V10.Types.PlayerName.PlayerName
        }
    | PlayerKicked
        { players : List Evergreen.V10.Types.PlayerName.PlayerName
        , kickedPlayer : Evergreen.V10.Types.PlayerName.PlayerName
        }
    | LobbyIsFull
    | LobbyKilled
    | GameInitialized
        { game : Evergreen.V10.Types.Game.Game
        }
    | UpdateGameState
        { game : Evergreen.V10.Types.Game.Game
        }
    | JoinedGame
        { game : Evergreen.V10.Types.Game.Game
        }
    | GameTerminated
