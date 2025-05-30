module Frontend exposing (Model, app)

import Html exposing (Html, button, div, input, li, text, ul, br)
import Html.Attributes exposing (placeholder, value)
import Html.Events exposing (onClick, onInput, onSubmit)
import String
import Types exposing (..)
import Types.PlayerName exposing (..)
import Lamdera exposing (sendToBackend )
import Styles


type alias Model =
  FrontendModel


app =
    Lamdera.frontend
        { init = \_ _ -> init
        , update = update
        , updateFromBackend = updateFromBackend
        , view =
            \model ->
                { title = "Carcassonne"
                , body = [ view model ]
                }
        , subscriptions = \_ -> Sub.none
        , onUrlChange = \_ -> FNoop
        , onUrlRequest = \_ -> FNoop
        }


init : ( Model, Cmd FrontendMsg )
init =
  ( FePlayerRegistration { nameInput = ""
  , error = Nothing
  },
  Cmd.none
  )


update : FrontendMsg -> Model -> ( Model, Cmd FrontendMsg )
update msg model =
  case (msg, model) of
    (NameInputChanged str, FePlayerRegistration rest) ->
      ( FePlayerRegistration { rest | nameInput = str, error = Nothing }, Cmd.none )

    (Register, FePlayerRegistration rest) ->
      let
        trimmedPlayerName = String.trim rest.nameInput
      in
      if String.isEmpty trimmedPlayerName then
        ( FePlayerRegistration { rest | error = Just "Name cannot be empty." }, Cmd.none )
      else
        ( FeLobby { playerName = trimmedPlayerName, players = [] }
        , sendToBackend <| RegisterPlayer trimmedPlayerName
        )

    (ClearError, FePlayerRegistration rest) ->
      ( FePlayerRegistration { rest | error = Nothing }, Cmd.none )

    (Kick playerName, _) ->
      ( model, sendToBackend <| KickPlayer playerName )
    _ ->
      (model, Cmd.none)

updateFromBackend : ToFrontend -> Model -> ( Model, Cmd FrontendMsg )
updateFromBackend msg model =
  case (msg, model) of
    (PlayerRegistrationUpdated { players }, FeLobby rest) ->
      ( FeLobby { rest | players = players }, Cmd.none )
    (PlayerKicked { kickedPlayer, players }, FeLobby { playerName }) ->
      if playerName == kickedPlayer then
        init
      else
        ( FeLobby { playerName = playerName, players = players }
        , Cmd.none
        )
    _ -> ( model, Cmd.none )

-- VIEW

view : Model -> Html FrontendMsg
view model =
  case model of
    FePlayerRegistration rest -> 
      div Styles.container
        [ div []
          [ Html.form
            [ onSubmit Register ]
            [ input
              (Styles.inputBox ++
              [ placeholder "Enter your name"
              , value rest.nameInput
              , onInput NameInputChanged
              ])
              []
            , button
              (Styles.buttonMain ++ [ onClick Register ])
              [ text "Join" ]
            ]
          ]
        , case rest.error of
          Just err ->
            div Styles.errorBox [ text err ]
          Nothing ->
            text ""
        ]
    FeLobby { playerName, players } -> div Styles.container
      [ div []
        [ text "Your name: "
        , text playerName
        , br [] []
        , text "All players:"
        , playerNamesView players
        ]
      ]
    --_ -> div [] []

playerNamesView : List PlayerName -> Html FrontendMsg
playerNamesView players =
  ul Styles.playerList 
    ( List.map (\name -> li Styles.playerItem [ text name
    , text " "
    , div ([ onClick <| Kick name , Html.Attributes.style "color" "red" ]) [ text "kick" ]
    ]) players)
