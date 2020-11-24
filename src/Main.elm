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
import Log exposing (GenericLog, LogHubResponse, logDecoder, logHubResponseDecoder, newLogEncoder)
import Result exposing (Result)



---- MODEL ----


type Status
    = Loading
    | Reloading
    | Success
    | Failure Http.Error


type Page
    = ListLog
    | AddLog String


type alias Filter =
    { logType : Maybe String }


type alias Model =
    { status : Status, data : Maybe LogHubResponse, input : String, filter : Filter }


initialModel : Model
initialModel =
    { status = Loading, data = Nothing, input = "", filter = { logType = Nothing } }


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
                    ( { model | status = Success, data = Just logs }, Cmd.none )

                Err err ->
                    ( { model | status = Failure err }, Cmd.none )

        LogClicked ->
            ( { model | status = Reloading }, postLog <| newLogEncoder model.input )

        ReadClicked ->
            ( model, getLogs )

        FindClicked ->
            ( { model | status = Reloading }, queryLogs model.input )

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
    Element.layout
        [ width fill
        , Font.size 14
        , Font.color mainClr
        , Background.color bgClr
        , padding 50
        ]
    <|
        column
            [ width fill, spacing 50 ]
            [ inputFields model
            , case model.status of
                Loading ->
                    text "loading..."

                Reloading ->
                    case model.data of
                        Just resp ->
                            logTable resp.data

                        Nothing ->
                            text "no data"

                Failure err ->
                    text <| toString err

                Success ->
                    case model.data of
                        Just resp ->
                            logTable resp.data

                        Nothing ->
                            text "no data"

            -- logList <| List.reverse logHubRes.data
            ]


inputFields : Model -> Element Msg
inputFields model =
    el
        [ centerX
        , width fill
        ]
        (row
            [ spacing 20
            ]
            [ Input.text
                []
                { onChange = InputChanged
                , text = model.input
                , placeholder = Nothing
                , label = Input.labelHidden "search"

                -- , spellcheck = True
                }
            , btn "find" FindClicked
            , btn "list all" ReadClicked
            ]
        )


logTable : List GenericLog -> Element Msg
logTable logs =
    table
        [ padding 10
        , spacing 5
        , Border.width 1
        , Border.color mutedClr
        ]
        { data = logs
        , columns =
            [ { header = text "time"
              , width = shrink
              , view = \log -> text log.time
              }
            , { header = text "id"
              , width = shrink
              , view = \log -> text log.id
              }
            , { header = text "data"
              , width = fill
              , view = \log -> text log.data
              }
            ]
        }


logList : List GenericLog -> Element Msg
logList list =
    column []
        (List.map
            (\log -> logEl log)
            list
        )


logEl : GenericLog -> Element Msg
logEl log =
    paragraph [ width fill, Font.family [ Font.monospace ] ]
        [ text <| "id: " ++ log.id
        , text <| "time: " ++ log.time
        , text <| "type: " ++ "generic"
        , el [ Font.color accentClr ] <| text <| log.data
        ]


btn : String -> Msg -> Element Msg
btn str msg =
    Input.button
        [ Border.width 1
        , padding 20
        , mouseOver [ Border.color accentClr ]
        , focused [ Border.color accentClr ]
        ]
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
