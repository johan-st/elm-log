module Log exposing (..)

import Html.Attributes exposing (method)
import Json.Decode as D
import Json.Encode as E



---- API SPECIFIC ----


type alias LogHubResponse =
    { ok : Bool, data : List GenericLog }


logHubResponseDecoder : D.Decoder LogHubResponse
logHubResponseDecoder =
    D.map2
        LogHubResponse
        (D.field "ok" D.bool)
        (D.field "data" (D.list logDecoder))



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


logDecoder : D.Decoder GenericLog
logDecoder =
    D.map3
        GenericLog
        (D.field "_id" D.string)
        (D.field "time" D.string)
        (D.succeed "data")


newLogEncoder : String -> E.Value
newLogEncoder data =
    E.object [ ( "data", E.string data ) ]
