module Types exposing (..)

import Lamdera exposing (ClientId, SessionId)
import Types.Game exposing (Coordinate, Game, MeeplePosition)
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
    | FeInitializeGame
    | FeRotateTileLeft
    | ChangeDebugMode
    | FePlaceTile Coordinate
    | FePlaceMeeple MeeplePosition
    | FeTerminateGame
    | ClearError
    | FNoop


type ToBackend
    = RegisterPlayer PlayerName
    | KickPlayer PlayerName
    | InitializeGame
    | RotateTileLeft
    | PlaceTile Coordinate
    | PlaceMeeple MeeplePosition
    | TerminateGame


type BackendMsg
    = ClientConnected SessionId ClientId
    | InitializeGameAndTileDrawStackShuffled (List SideId)
    | TileDrawStackShuffled (List SideId)
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
    | JoinedGame
        { game : Game
        }
    | GameTerminated
