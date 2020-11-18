module Main exposing (..)

import Browser
import Html exposing (..)
import Html.Attributes exposing (..)
import Html.Events exposing (onClick, onInput)
import Http
import Json.Encode as E
import Result exposing (Result)



---- MODEL ----


type Status
    = NotAsked
    | Loading
    | Success String
    | Failure Http.Error


type alias Model =
    { status : Status, bodyInput : String }


init : ( Model, Cmd Msg )
init =
    ( Model NotAsked "", Cmd.none )



---- UPDATE ----


type Msg
    = GotResponse (Result Http.Error String)
    | ClearClicked
    | FunctionClicked String
    | InputChanged String


update : Msg -> Model -> ( Model, Cmd Msg )
update msg model =
    case msg of
        GotResponse res ->
            case res of
                Ok response ->
                    ( { model | status = Success response }, Cmd.none )

                Err err ->
                    ( { model | status = Failure err }, Cmd.none )

        FunctionClicked url ->
            ( { model | status = Loading }, callFunction url (E.object [ ( "raw", E.string model.bodyInput ) ]) )

        ClearClicked ->
            ( { model | status = NotAsked }, Cmd.none )

        InputChanged val ->
            ( { model | bodyInput = val }, Cmd.none )


callFunction : String -> E.Value -> Cmd Msg
callFunction url jsonValue =
    Http.post
        { expect = Http.expectString GotResponse
        , body = Http.jsonBody jsonValue
        , url = ".netlify/functions/" ++ url
        }



---- VIEW ----


view : Model -> Html Msg
view model =
    div []
        [ inputFields model
        , case model.status of
            NotAsked ->
                text "not asked"

            Loading ->
                text "Loading."

            Failure err ->
                text "Error."

            Success res ->
                pre [] [ text res ]
        ]


inputFields : Model -> Html Msg
inputFields model =
    div [ class "input-fields" ]
        [ label [ for "raw-data" ] [ text "raw: " ]
        , input [ name "raw-data", value model.bodyInput, onInput InputChanged ] []
        , button [ name "log", onClick <| FunctionClicked "log" ] [ text "log" ]
        , button [ name "clear", onClick <| ClearClicked ] [ text "Clear" ]
        ]



---- PROGRAM ----


main : Program () Model Msg
main =
    Browser.element
        { view = view
        , init = \_ -> init
        , update = update
        , subscriptions = always Sub.none
        }
