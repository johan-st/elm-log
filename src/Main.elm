module Main exposing (..)

import Browser
import Html exposing (..)
import Html.Attributes exposing (..)
import Html.Events exposing (onClick, onInput)
import Http exposing (Error(..))
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
    | LogBtnClicked
    | ReadBtnClicked
    | FindBtnClicked
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

        LogBtnClicked ->
            ( { model | status = Loading }, postLog (E.object [ ( "raw", E.string model.bodyInput ) ]) )

        ReadBtnClicked ->
            ( { model | status = Loading }, readLog model.bodyInput )

        FindBtnClicked ->
            ( { model | status = Loading }, getLog model.bodyInput )

        ClearClicked ->
            ( { model | status = NotAsked }, Cmd.none )

        InputChanged val ->
            ( { model | bodyInput = val }, Cmd.none )


getLog : String -> Cmd Msg
getLog query =
    Http.get
        { expect = Http.expectString GotResponse
        , url = ".netlify/functions/db?q=" ++ query
        }


readLog : String -> Cmd Msg
readLog query =
    Http.get
        { expect = Http.expectString GotResponse
        , url = ".netlify/functions/readLogs?q=" ++ query
        }


postLog : E.Value -> Cmd Msg
postLog jsonValue =
    Http.post
        { expect = Http.expectString GotResponse
        , body = Http.jsonBody jsonValue
        , url = ".netlify/functions/log"
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
                text <| toString err

            Success res ->
                pre [] [ text res ]
        ]


inputFields : Model -> Html Msg
inputFields model =
    div [ class "input-fields" ]
        [ label [ for "raw-data" ] [ text "raw: " ]
        , input [ name "raw-data", value model.bodyInput, onInput InputChanged ] []
        , button [ name "log", onClick <| LogBtnClicked ] [ text "log" ]
        , button [ name "read", onClick <| ReadBtnClicked ] [ text "read" ]
        , button [ name "find", onClick <| FindBtnClicked ] [ text "find" ]
        , button [ name "clear", onClick <| ClearClicked ] [ text "Clear" ]
        ]


toString : Http.Error -> String
toString err =
    case err of
        BadUrl str ->
            "Bad Url: " ++ str

        Timeout ->
            "Timeout"

        NetworkError ->
            "Network Error"

        BadStatus code ->
            "Bad Status: " ++ String.fromInt code

        BadBody str ->
            "Bad Body: " ++ str



---- PROGRAM ----


main : Program () Model Msg
main =
    Browser.element
        { view = view
        , init = \_ -> init
        , update = update
        , subscriptions = always Sub.none
        }
