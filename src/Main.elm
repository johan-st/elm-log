module Main exposing (..)

import Browser
import Element exposing (..)
import Element.Background as Background
import Element.Border as Border
import Element.Events exposing (onClick)
import Element.Font as Font
import Element.Input as Input
import Html exposing (Html)
import Http exposing (Error(..))
import Json.Decode as D
import Json.Encode as E
import Log exposing (Log, LogHubResponse, logDecoder, logHubResponseDecoder, newLogEncoder)
import Result exposing (Result)



---- MODEL ----


type Status
    = Loading
    | Success LogHubResponse
    | Failure Http.Error


type Page
    = ListLog
    | AddLog String


type alias Filter =
    { logType : Maybe String }


type alias Model =
    { status : Status, input : String, filter : Filter }


initialModel : Model
initialModel =
    { status = Loading, input = "", filter = { logType = Nothing } }


init : ( Model, Cmd Msg )
init =
    ( initialModel, getLogs )



---- UPDATE ----


type Msg
    = GotResponse (Result Http.Error LogHubResponse)
    | ClearClicked
    | LogClicked
    | ReadClicked
    | FindClicked
    | InputChanged String
    | FilterChanged


update : Msg -> Model -> ( Model, Cmd Msg )
update msg model =
    case msg of
        GotResponse res ->
            case res of
                Ok logs ->
                    ( { model | status = Success logs }, Cmd.none )

                Err err ->
                    ( { model | status = Failure err }, Cmd.none )

        LogClicked ->
            ( { model | status = Loading }, postLog <| newLogEncoder model.input )

        ReadClicked ->
            ( { model | status = Loading }, getLogs )

        FindClicked ->
            ( { model | status = Loading }, queryLogs model.input )

        ClearClicked ->
            ( model, Cmd.none )

        InputChanged val ->
            ( { model | input = val }, Cmd.none )

        FilterChanged ->
            ( model, Cmd.none )


queryLogs : String -> Cmd Msg
queryLogs query =
    Http.get
        { expect = Http.expectJson GotResponse logHubResponseDecoder
        , url = "/logs?q=" ++ query
        }


getLogs : Cmd Msg
getLogs =
    Http.get
        { expect = Http.expectJson GotResponse logHubResponseDecoder
        , url = "/logs"
        }


postLog : E.Value -> Cmd Msg
postLog jsonValue =
    Http.post
        { expect = Http.expectJson GotResponse logHubResponseDecoder
        , body = Http.jsonBody jsonValue
        , url = "/logs"
        }



---- VIEW ----


bgClr : Color
bgClr =
    rgb255 33 33 33


mainClr : Color
mainClr =
    rgb255 200 100 0


accentClr : Color
accentClr =
    rgb255 50 200 200


mutedClr : Color
mutedClr =
    rgb255 200 100 0


view : Model -> Html Msg
view model =
    Element.layout [ width fill, Font.size 14, Font.color mainClr, Background.color bgClr ] <|
        column
            [ width fill ]
            [ inputFields model
            , case model.status of
                Loading ->
                    text "loading..."

                Failure err ->
                    text <| toString err

                Success logHubRes ->
                    logList <| List.reverse logHubRes.data
            ]


inputFields : Model -> Element Msg
inputFields model =
    el [ centerX ]
        (row
            []
            [ Input.text []
                { onChange = InputChanged
                , text = model.input
                , placeholder = Nothing
                , label = Input.labelLeft [] (text "search")

                -- , spellcheck = True
                }
            , btn "add too log" LogClicked
            , btn "list all logs" ReadClicked
            , btn "search" FindClicked
            , btn "clear results" ClearClicked
            ]
        )


logList : List Log -> Element Msg
logList list =
    column []
        (List.map
            (\log -> logEl log)
            list
        )


logEl : Log -> Element Msg
logEl log =
    paragraph [ width fill, Font.family [ Font.monospace ] ]
        [ text <| "id: " ++ log.id
        , text <| "time: " ++ log.time
        , text <| "type: " ++ log.logType
        , el [ Font.color accentClr ] <| text <| log.data
        ]


btn : String -> Msg -> Element Msg
btn str msg =
    Input.button
        []
        { onPress = Just msg
        , label = text str
        }


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
