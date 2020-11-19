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
    { status : Status, input : String }


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
            ( { model | status = Loading }, postLog (E.object [ ( "log", E.string model.input ) ]) )

        ReadBtnClicked ->
            ( { model | status = Loading }, getLogs )

        FindBtnClicked ->
            ( { model | status = Loading }, queryLogs model.input )

        ClearClicked ->
            ( { model | status = NotAsked }, Cmd.none )

        InputChanged val ->
            ( { model | input = val }, Cmd.none )


queryLogs : String -> Cmd Msg
queryLogs query =
    Http.get
        { expect = Http.expectString GotResponse
        , url = "/logs?q=" ++ query
        }


getLogs : Cmd Msg
getLogs =
    Http.get
        { expect = Http.expectString GotResponse
        , url = "/logs"
        }


postLog : E.Value -> Cmd Msg
postLog jsonValue =
    Http.post
        { expect = Http.expectString GotResponse
        , body = Http.jsonBody jsonValue
        , url = "/logs"
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
        [ label [ for "raw-data" ] [ text "input: " ]
        , input [ name "raw-data", value model.input, onInput InputChanged ] []
        , button [ name "log", onClick <| LogBtnClicked ] [ text "log" ]
        , button [ name "get logs", onClick <| ReadBtnClicked ] [ text "get logs" ]
        , button [ name "search", onClick <| FindBtnClicked ] [ text "search" ]
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
