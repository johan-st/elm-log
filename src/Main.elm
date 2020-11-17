module Main exposing (..)

import Browser
import Html exposing (..)
import Html.Attributes exposing (..)
import Html.Events exposing (onClick, onInput)
import Http
import Result exposing (Result)



---- MODEL ----


type Status
    = NotAsked
    | Loading
    | Success String
    | Failure Http.Error


type alias Model =
    { status : Status, urlInput : String, bodyInput : String }


init : ( Model, Cmd Msg )
init =
    ( Model NotAsked "" "", Cmd.none )



---- UPDATE ----


type Msg
    = GotResponse (Result Http.Error String)
    | Clicked
    | ClearClicked
    | FunctionClicked String
    | UrlUpdated String
    | BodyUpdated String


update : Msg -> Model -> ( Model, Cmd Msg )
update msg model =
    case msg of
        GotResponse res ->
            case res of
                Ok response ->
                    ( { model | status = Success response }, Cmd.none )

                Err err ->
                    ( { model | status = Failure err }, Cmd.none )

        Clicked ->
            ( { status = Loading, bodyInput = "", urlInput = "" }, callFunction model.urlInput model.bodyInput )

        FunctionClicked url ->
            ( { model | status = Loading }, callFunction url "function functoin fp" )

        ClearClicked ->
            ( { model | status = NotAsked }, Cmd.none )

        UrlUpdated val ->
            ( { model | urlInput = val }, Cmd.none )

        BodyUpdated val ->
            ( { model | bodyInput = val }, Cmd.none )


callFunction : String -> String -> Cmd Msg
callFunction url body =
    Http.post
        { expect = Http.expectString GotResponse
        , body = Http.stringBody "text" body
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
        -- [ input [ type_ "text", value model.urlInput, onInput UrlUpdated ] []
        -- , input [ type_ "text", value model.bodyInput, onInput BodyUpdated ] []
        [ button [ onClick <| FunctionClicked "log" ] [ text "log" ]
        , button [ onClick <| ClearClicked ] [ text "Clear" ]
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
