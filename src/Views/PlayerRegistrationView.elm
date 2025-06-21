module Views.PlayerRegistrationView exposing (..)

import Html exposing (..)
import Html.Attributes exposing (..)
import Html.Events exposing (..)
import Styles
import Types exposing (FrontendMsg(..))


renderPlayerRegistrationView : String -> Maybe String -> Html FrontendMsg
renderPlayerRegistrationView nameInput error =
    div Styles.container
        [ div []
            [ Html.form
                [ onSubmit Register ]
                [ input
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
            ]
        , case error of
            Just err ->
                div Styles.errorBox [ text err ]

            Nothing ->
                text ""
        ]
