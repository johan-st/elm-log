module Log exposing (..)

import Json.Decode as D
import Json.Encode as E



---- API SPECIFIC ----


type alias LogHubResponse =
    { ok : Bool, data : List Log }


logHubResponseDecoder : D.Decoder LogHubResponse
logHubResponseDecoder =
    D.map2
        LogHubResponse
        (D.field "ok" D.bool)
        (D.field "data" (D.list logDecoder))



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
