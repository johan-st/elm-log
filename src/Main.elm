module Main exposing (..)

import Browser
import Html exposing (..)
import Html.Attributes exposing (..)
import Html.Events exposing (onClick, onInput)
import Http exposing (Error(..))
import Json.Decode as D
import Json.Encode as E
import Result exposing (Result)



---- MODEL ----


type Status
    = NotAsked
    | Loading
    | Success (List Log)
    | Failure Http.Error


type Page
    = ListLog
    | AddLog String


type alias Filter =
    { logType : Maybe String }


type alias Model =
    { status : Status, input : String, filter : Filter }


init : ( Model, Cmd Msg )
init =
    ( Model NotAsked "" { logType = Nothing }, getLogs )



---- UPDATE ----


type Msg
    = GotResponse (Result Http.Error (List Log))
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
            ( { model | status = NotAsked }, Cmd.none )

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

            Success logs ->
                div [] <| logList (List.reverse logs)
        ]


inputFields : Model -> Html Msg
inputFields model =
    div [ class "input-fields" ]
        [ label [ for "raw-data" ] [ text "input: " ]
        , input [ name "raw-data", value model.input, onInput InputChanged ] []
        , btn "log string" LogClicked
        , btn "list logs" ReadClicked
        , btn "search" FindClicked
        , btn "clear" ClearClicked
        ]


logList : List Log -> List (Html Msg)
logList list =
    List.map
        (\log ->
            div [ class "log" ]
                [ p [ class "log__id" ] [ text <| "id: " ++ log.id ]
                , p [ class "log__time" ] [ text <| "time: " ++ log.time ]
                , p [ class "log__type" ] [ text <| "type: " ++ log.logType ]
                , p [ class "log__data" ] [ text <| "log: " ++ log.data ]
                ]
        )
        list


btn : String -> Msg -> Html Msg
btn str msg =
    button [ name str, onClick msg ] [ text str ]


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



---- API SPECIFIC ----


type alias LogHubResponse =
    { ok : Bool, data : List Log }


logHubResponseDecoder : D.Decoder (List Log)
logHubResponseDecoder =
    D.field "data" (D.list logDecoder)



---- LOG ----


type alias Log =
    { id : String
    , time : String
    , logType : String
    , data : ReqLog
    }


type alias ReqLog =
    String


logDecoder : D.Decoder Log
logDecoder =
    D.map4
        Log
        (D.field "_id" D.string)
        (D.field "time" D.string)
        (D.field "logType" D.string)
        (D.field "data" D.string)


newLogEncoder : String -> E.Value
newLogEncoder data =
    E.object [ ( "data", E.string data ) ]



---- PROGRAM ----


main : Program () Model Msg
main =
    Browser.element
        { view = view
        , init = \_ -> init
        , update = update
        , subscriptions = always Sub.none
        }
