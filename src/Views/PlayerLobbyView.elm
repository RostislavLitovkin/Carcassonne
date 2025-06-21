module Views.PlayerLobbyView exposing (..)

import Html exposing (..)
import Html.Attributes
import Html.Events exposing (onClick)
import Styles
import Types exposing (FrontendMsg(..))
import Types.PlayerName exposing (PlayerName)


renderPlayerLobbyView : String -> List PlayerName -> Html FrontendMsg
renderPlayerLobbyView playerName players =
    div Styles.container
        [ div []
            [ text "Your name: "
            , text playerName
            , br [] []
            , text "All players:"
            , renderPlayerNames players
            , button
                (Styles.buttonMain ++ [ onClick FeInitializeGame ])
                [ text "Start" ]
            ]
        ]


renderPlayerNames : List PlayerName -> Html FrontendMsg
renderPlayerNames players =
    ul Styles.playerList
        (List.map
            (\name ->
                li Styles.playerItem
                    [ text name
                    , text " "
                    , div [ onClick <| Kick name, Html.Attributes.style "color" "red" ] [ text "kick" ]
                    ]
            )
            players
        )
