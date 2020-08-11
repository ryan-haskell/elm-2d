module Examples.Dungeon exposing (main)

import Browser
import Color
import Dict exposing (Dict)
import Elm2D
import Elm2D.Spritesheet exposing (Animation, Sprite, Spritesheet)
import Html exposing (Html)
import Time


main : Program () Model Msg
main =
    Browser.element
        { init = init
        , update = update
        , view = view
        , subscriptions = subscriptions
        }



-- INIT


type alias Model =
    { counter : Int
    , spritesheet : Maybe Spritesheet
    }


init : () -> ( Model, Cmd Msg )
init _ =
    ( { counter = 0
      , spritesheet = Nothing
      }
    , Elm2D.Spritesheet.load
        { tileSize = 16
        , file = "assets/dungeon-tileset.png"
        , onLoad = LoadedSpritesheet
        }
    )



-- UPDATE


type Msg
    = LoadedSpritesheet (Maybe Spritesheet)
    | Tick


update : Msg -> Model -> ( Model, Cmd Msg )
update msg model =
    case msg of
        Tick ->
            ( { model | counter = model.counter + 1 }
            , Cmd.none
            )

        LoadedSpritesheet spritesheet ->
            ( { model | spritesheet = spritesheet }
            , Cmd.none
            )


subscriptions : Model -> Sub Msg
subscriptions model =
    Time.every 100 (always Tick)



-- VIEW


view : Model -> Html Msg
view model =
    model.spritesheet
        |> Maybe.map (viewMap model)
        |> Maybe.withDefault (Html.text "Loading...")


viewMap : Model -> Spritesheet -> Html Msg
viewMap { counter } spritesheet =
    Elm2D.view
        { size = ( 640, 480 )
        , background = Color.rgb255 50 50 50
        }
        (List.concat
            [ coordinates |> List.map (\c -> viewTile counter spritesheet ( c, Floor ))
            , Dict.toList map
                |> List.map (viewTile counter spritesheet)
            ]
        )



-- Map


tileSize =
    32


dimensions =
    { width = 20
    , height = 15
    }


coordinates : List Coordinate
coordinates =
    List.concatMap
        (\y ->
            List.range 0 (dimensions.width - 1)
                |> List.map (\x -> ( x, y ))
        )
        (List.range 0 (dimensions.height - 1))


type alias Map =
    Dict Coordinate Tile


map : Map
map =
    Dict.empty
        |> Dict.insert ( 1, 1 ) Wall
        |> Dict.insert ( 4, 3 ) SpikeTrap


type alias Coordinate =
    ( Int, Int )


type Tile
    = Floor
    | Wall
    | SpikeTrap


viewTile : Int -> Spritesheet -> ( Coordinate, Tile ) -> Elm2D.Element
viewTile frame spritesheet ( ( x, y ), tile ) =
    let
        sprites =
            spritesFrom spritesheet

        sprite =
            case tile of
                Floor ->
                    sprites.floor

                Wall ->
                    sprites.wall

                SpikeTrap ->
                    sprites.spikeTrap frame
    in
    Elm2D.sprite
        { size = ( tileSize, tileSize )
        , position = ( toFloat x * tileSize, toFloat y * tileSize )
        , sprite = sprite
        }


spritesFrom :
    Spritesheet
    ->
        { floor : Sprite
        , wall : Sprite
        , spikeTrap : Int -> Sprite
        }
spritesFrom dungeon =
    let
        select =
            Elm2D.Spritesheet.select dungeon

        animation list i =
            Elm2D.Spritesheet.animation dungeon list
                |> Elm2D.Spritesheet.frame i
    in
    { floor = select ( 1, 4 )
    , wall = select ( 1, 1 )
    , spikeTrap =
        animation <|
            List.concat
                [ List.repeat 20 ( 1, 11 )
                , [ ( 2, 11 )
                  , ( 3, 11 )
                  , ( 4, 11 )
                  , ( 3, 11 )
                  , ( 2, 11 )
                  ]
                ]
    }
