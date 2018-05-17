port module Home exposing (..)


import Html exposing (..)
import Html.Events exposing (..)
import Dict exposing (Dict)
import Json.Encode as Json exposing (..)
import Coders exposing (maybeToValue)


main : Program ( List (String, Document) ) Model Msg
main =
  programWithFlags
    { init = init
    , view = view
    , update = update
    , subscriptions = subscriptions
    }




-- MODEL


type alias Model =
  Dict String Document


type alias Document =
  { name : Maybe String
  , state : String
  , created_at : String
  , last_modified : String
  }


defaultDocument : Document
defaultDocument =
  { name = Just "Untitled"
  , state = "active"
  , created_at = ""
  , last_modified = ""
  }


init : List (String, Document) -> ( Model, Cmd Msg )
init dbObj =
  ( dbObj
      |> Dict.fromList
  , Cmd.none
  )




-- UPDATE

type Msg
  = NoOp
  | New
  | Load String (Maybe String)
  | Import



update : Msg -> Model -> ( Model, Cmd Msg )
update msg model =
  case msg of
    New ->
      model ! [ forJS { tag = "New", data = string "" }]

    Load dbname docName_ ->
      let
        data =
          [ string dbname, maybeToValue string docName_ ]
            |> list
      in
      model ! [ forJS { tag = "Load", data = data }]

    _ ->
      model ! []




-- VIEW

view : Model -> Html Msg
view model =
  div []
    [ button [ onClick New ][ text "New" ]
    , viewDocList model
    ]


viewDocList : Model -> Html Msg
viewDocList { documents, tableState }=
  let
    docList =
      documents
        |> Dict.toList
        |> List.map (\(k, v) -> addId k v)
  in
  Table.view config tableState docList


config : Table.Config (WithId Document) Msg
config =
  let
    dateColumn name =
      Table.customColumn
        { name = name
        , viewData = .last_modified
        , sorter = Table.decreasingOrIncreasingBy .last_modified
        }
  in
  Table.config
    { toId = .id
    , toMsg = SetTableState
    , columns =
        [ Table.stringColumn "Name" (Maybe.withDefault "Untitled" << .name)
        , dateColumn "Date Modified"
        ]
    }


viewDocumentItem : ( String, Document) -> Html Msg
viewDocumentItem (dbname, document) =
  li []
    [ text ( document.name |> Maybe.withDefault "Untitled" )
    , text " | "
    , text document.last_modified
    , button [onClick (Load dbname document.name)][ text "Open" ]
    ]


-- SUBSCRIPTIONS

port forJS : { tag : String, data : Json.Value } -> Cmd msg

subscriptions : Model -> Sub Msg
subscriptions model =
  Sub.none

