module Log exposing (..)

import Json.Decode exposing (Decoder, bool, list, string, succeed)
import Json.Decode.Pipeline exposing (required)
import Json.Encode as E



---- API SPECIFIC ----


type alias LogHubResponse =
    { ok : Bool, data : List GenericLog }


logHubResponseDecoder : Decoder LogHubResponse
logHubResponseDecoder =
    succeed
        LogHubResponse
        |> required "ok" bool
        |> required "data" (list logDecoder)



---- LOG ----


type Log
    = Generic GenericLog
    | HTTP_request HTTP_requestLog


type alias GenericLog =
    { id : String
    , time : String
    , data : String
    }



-- {
--   "_id": "5fbbc0f8802f73727cbb077a",
--   "logType": "TEST",
--   "data": "test created through web ui",
--   "time": "2020-11-24T21:32:23.061Z"
-- }


type alias HTTP_requestLog =
    { id : String
    , time : String
    , data :
        { id : String
        , method : String
        , path : String
        }
    }



-- {
--   "_id": "5fbbcdc486ef50390aea8acc",
--   "logType": "HTTP_request",
--   "data": {
--     "id": "ccbd20dd-ddbf-4cd8-84e9-7f1c266d8bed",
--     "method": "GET",
--     "path": "/api/logs"
--   },
--   "time": "2020-11-23T14:57:08.604Z",
--   "__v": 0
-- }


logDecoder : Decoder Log
logDecoder =
    succeed
        GenericLog
        |> required "_id" string
        |> required "time" string
        |> required "data" (succeed "data")


newLogEncoder : String -> E.Value
newLogEncoder data =
    E.object [ ( "data", E.string data ) ]
