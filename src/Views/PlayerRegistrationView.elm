module Views.PlayerRegistrationView exposing (..)

import Html exposing (..)
import Html.Attributes exposing (..)
import Html.Events exposing (..)
import Styles
import Types exposing (FrontendMsg(..))
import Types.PlayerName exposing (PlayerName)


renderPlayerRegistrationView : PlayerName -> Maybe String -> Html FrontendMsg
renderPlayerRegistrationView nameInput error =
    div Styles.container
        [ div []
            [ Html.form
                [ onSubmit Register ]
                ([ input
                    (Styles.inputBox
                        ++ [ placeholder "Enter your name"
                           , value nameInput
                           , onInput NameInputChanged
                           ]
                    )
                    []
                 , button
                    (Styles.buttonMain ++ [ onClick Register ])
                    [ text "Join" ]
                 ]
                    ++ (if error == Just "Lobby is full." then
                            [ button
                                (Styles.buttonMain ++ [ onClick FeKillLobby ])
                                [ text "Kill lobby" ]
                            ]

                        else
                            []
                       )
                )
            ]
        , case error of
            Just err ->
                div Styles.errorBox [ text err ]

            Nothing ->
                text ""
        ]
