module Types exposing (..)

import Lamdera exposing (ClientId, SessionId)
import Types.Coordinate exposing (Coordinate)
import Types.Game exposing (Game)
import Types.Meeple exposing (MeeplePosition)
import Types.PlayerName exposing (..)
import Types.Tile exposing (SideId)


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
        , debugMode : Bool
        , game : Game
        }


type FrontendMsg
    = NameInputChanged String
    | Register
    | Kick PlayerName
    | FeKillLobby
    | FeInitializeGame
    | FeRotateTileLeft
    | ChangeDebugMode
    | FePlaceTile Coordinate
    | FePlaceMeeple MeeplePosition
    | FeTerminateGame
    | FNoop


type ToBackend
    = RegisterPlayer PlayerName
    | KickPlayer PlayerName
    | KillLobby
    | InitializeGame
    | RotateTileLeft
    | PlaceTile Coordinate
    | PlaceMeeple MeeplePosition
    | TerminateGame


type BackendMsg
    = ClientConnected SessionId ClientId
    | InitializeGameAndTileDrawStackShuffled (List SideId)
    | TileDrawStackShuffled (List SideId)


type ToFrontend
    = PlayerRegistrationUpdated
        { players : List PlayerName
        }
    | PlayerKicked
        { players : List PlayerName
        , kickedPlayer : PlayerName
        }
    | LobbyIsFull
    | LobbyKilled
    | GameInitialized
        { game : Game
        }
    | UpdateGameState
        { game : Game
        }
    | JoinedGame
        { game : Game
        }
    | GameTerminated
