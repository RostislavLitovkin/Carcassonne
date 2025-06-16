module Views.PlayerRegistrationView exposing (Model, Msg(..), init, update, view)

import Browser
import Html exposing (Html, button, div, input, li, text, ul)
import Html.Attributes exposing (placeholder, value)
import Html.Events exposing (onClick, onInput, onSubmit)
import String


init : Model
init =
    { nameInput = ""
    , registeredPlayers = []
    , error = Nothing
    }



-- UPDATE


update : Msg -> Model -> Model
update msg model =
    case msg of
        NameInputChanged str ->
            { model | nameInput = str, error = Nothing }

        Register ->
            let
                trimmed =
                    String.trim model.nameInput

                nameExists =
                    List.member trimmed model.registeredPlayers
            in
            if String.isEmpty trimmed then
                { model | error = Just "Name cannot be empty." }

            else if nameExists then
                { model | error = Just "Name already registered." }

            else
                { model
                    | registeredPlayers = model.registeredPlayers ++ [ trimmed ]
                    , nameInput = ""
                    , error = Nothing
                }

        ClearError ->
            { model | error = Nothing }



-- VIEW


view : Model -> Html Msg
view model =
    div []
        [ div []
            [ input
                [ placeholder "Enter your name"
                , value model.nameInput
                , onInput NameInputChanged
                ]
                []
            , button
                [ onClick Register ]
                [ text "Register" ]
            ]
        , case model.error of
            Just err ->
                div [] [ text err ]

            Nothing ->
                text ""
        , div []
            [ text "Registered Players:"
            , ul []
                (List.map (\name -> li [] [ text name ]) model.registeredPlayers)
            ]
        ]
