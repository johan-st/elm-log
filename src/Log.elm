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


type alias HTTP_requestLog =
    { id : String
    , time : String
    , data :
        { id : String
        , method : String
        , path : String
        }
    }


logDecoder : Decoder GenericLog
logDecoder =
    succeed
        GenericLog
        |> required "_id" string
        |> required "time" string
        |> required "data" (succeed "data")



-- |> required "data" string


newLogEncoder : String -> E.Value
newLogEncoder data =
    E.object [ ( "data", E.string data ) ]
