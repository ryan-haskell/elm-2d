module Examples.Dungeon exposing (main)

import Browser
import Dict exposing (Dict)
import Elm2D
import Elm2D.Color
import Elm2D.Spritesheet exposing (Sprite, Spritesheet)
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
    , spritesheet : Spritesheet
    }


init : () -> ( Model, Cmd Msg )
init _ =
    ( { counter = 0
      , spritesheet = Elm2D.Spritesheet.blank
      }
    , Elm2D.Spritesheet.load
        { tileSize = 16
        , file = "assets/dungeon-tileset.png"
        , onLoad = LoadedSpritesheet
        }
    )



-- UPDATE


type Msg
    = LoadedSpritesheet Spritesheet
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
view { counter, spritesheet } =
    Elm2D.view
        { size =
            ( tileSize * dimensions.width
            , tileSize * dimensions.height + tileSize
            )
        , background = Elm2D.Color.fromRgb255 ( 0, 0, 0 )
        }
        (List.concat
            [ backgroundLayer
                |> List.map (viewTile counter spritesheet)
            , Dict.toList map
                |> List.map (viewTile counter spritesheet)
            ]
        )



-- BACKGROUND LAYER


tileSize : number
tileSize =
    48


dimensions : { width : number, height : number }
dimensions =
    { width = 20
    , height = 15
    }


backgroundLayer : List ( Coordinate, Tile )
backgroundLayer =
    coordinates
        |> List.map
            (\( x, y ) ->
                ( ( x, y )
                , if y == 0 then
                    TopOfWall

                  else
                    Floor
                )
            )


coordinates : List Coordinate
coordinates =
    List.range -1 (dimensions.height - 1)
        |> List.concatMap
            (\y ->
                List.range 0 (dimensions.width - 1)
                    |> List.map (\x -> ( x, y ))
            )



-- MAP


type alias Map =
    Dict Coordinate Tile


map : Map
map =
    fromString """
`xxxxxx=`xxxxxxxxxx=
<      ><          >
< K    ><          >
<      .,      K   >
<      SS          >
<      SS          >
<      ><          >
<      ><   K      >
Z___S__?<          >
`xxxSxx=<          >
<   S  ><          >
<      ><          >
z______/z__________/
xxxxxxxxxxxxxxxxxxxx
"""


fromString : String -> Map
fromString rawMapString =
    let
        list : List ( Coordinate, Char )
        list =
            String.trim rawMapString
                |> String.lines
                |> List.indexedMap pairCharWithCoordinate
                |> List.concat

        pairCharWithCoordinate : Int -> String -> List ( Coordinate, Char )
        pairCharWithCoordinate y line =
            List.indexedMap
                (\x char -> ( ( x, y + 1 ), char ))
                (String.toList line)

        insertTileIfPresent : ( Coordinate, Char ) -> Map -> Map
        insertTileIfPresent ( coordinate, char ) dict =
            case fromCharToTile char of
                Just tile ->
                    dict |> Dict.insert coordinate tile

                Nothing ->
                    dict
    in
    list
        |> List.foldl
            insertTileIfPresent
            Dict.empty


fromCharToTile : Char -> Maybe Tile
fromCharToTile char =
    case char of
        'x' ->
            Just Wall

        '_' ->
            Just TopOfWall

        '`' ->
            Just TopLeftWall

        '=' ->
            Just TopRightWall

        '<' ->
            Just LeftWall

        ',' ->
            Just LeftWallAlt

        '>' ->
            Just RightWall

        '.' ->
            Just RightWallAlt

        'z' ->
            Just BottomLeftWall

        'Z' ->
            Just BottomLeftWallAlt

        '/' ->
            Just BottomRightWall

        '?' ->
            Just BottomRightWallAlt

        'S' ->
            Just SpikeTrap

        'K' ->
            Just Kent

        _ ->
            Nothing


type alias Coordinate =
    ( Int, Int )


type Tile
    = Floor
    | Wall
    | TopOfWall
    | TopLeftWall
    | TopRightWall
    | LeftWall
    | LeftWallAlt
    | RightWall
    | RightWallAlt
    | BottomLeftWall
    | BottomRightWall
    | BottomLeftWallAlt
    | BottomRightWallAlt
    | SpikeTrap
    | Kent


viewTile : Int -> Spritesheet -> ( Coordinate, Tile ) -> Elm2D.Element
viewTile frame spritesheet ( ( x, y ), tile ) =
    let
        sprites =
            spritesFrom spritesheet

        ( scale, sprite ) =
            case tile of
                Floor ->
                    sprites.floor

                Wall ->
                    sprites.wall

                TopOfWall ->
                    sprites.topOfWall

                TopLeftWall ->
                    sprites.topLeftWall

                TopRightWall ->
                    sprites.topRightWall

                LeftWall ->
                    sprites.leftWall

                RightWall ->
                    sprites.rightWall

                LeftWallAlt ->
                    sprites.leftWallAlt

                RightWallAlt ->
                    sprites.rightWallAlt

                BottomLeftWall ->
                    sprites.bottomLeftWall

                BottomRightWall ->
                    sprites.bottomRightWall

                BottomLeftWallAlt ->
                    sprites.bottomLeftWallAlt

                BottomRightWallAlt ->
                    sprites.bottomRightWallAlt

                SpikeTrap ->
                    sprites.spikeTrap frame

                Kent ->
                    sprites.kent frame
    in
    Elm2D.sprite
        { size = ( tileSize * scale, tileSize * scale )
        , position = ( toFloat x * tileSize, toFloat y * tileSize )
        , sprite = sprite
        }


spritesFrom :
    Spritesheet
    ->
        { floor : ( number, Sprite )
        , wall : ( number, Sprite )
        , topOfWall : ( number, Sprite )
        , leftWall : ( number, Sprite )
        , rightWall : ( number, Sprite )
        , leftWallAlt : ( number, Sprite )
        , rightWallAlt : ( number, Sprite )
        , topLeftWall : ( number, Sprite )
        , topRightWall : ( number, Sprite )
        , bottomLeftWall : ( number, Sprite )
        , bottomRightWall : ( number, Sprite )
        , bottomLeftWallAlt : ( number, Sprite )
        , bottomRightWallAlt : ( number, Sprite )
        , spikeTrap : Int -> ( number, Sprite )
        , kent : Int -> ( number, Sprite )
        }
spritesFrom dungeon =
    let
        select =
            Elm2D.Spritesheet.select dungeon

        animation list i =
            Elm2D.Spritesheet.animation dungeon list
                |> Elm2D.Spritesheet.frame i

        region =
            Elm2D.Spritesheet.region dungeon
    in
    { floor = ( 1, select ( 1, 4 ) )
    , wall = ( 1, select ( 1, 1 ) )
    , topOfWall = ( 1, select ( 1, 0 ) )
    , leftWall = ( 1, select ( 1, 8 ) )
    , rightWall = ( 1, select ( 0, 8 ) )
    , leftWallAlt = ( 1, select ( 1, 9 ) )
    , rightWallAlt = ( 1, select ( 0, 9 ) )
    , topLeftWall = ( 1, select ( 2, 8 ) )
    , topRightWall = ( 1, select ( 3, 8 ) )
    , bottomLeftWall = ( 1, select ( 2, 9 ) )
    , bottomRightWall = ( 1, select ( 3, 9 ) )
    , bottomLeftWallAlt = ( 1, select ( 5, 8 ) )
    , bottomRightWallAlt = ( 1, select ( 4, 8 ) )
    , spikeTrap =
        \i ->
            ( 1
            , animation
                (List.concat
                    [ List.repeat 20 ( 1, 11 )
                    , [ ( 2, 11 )
                      , ( 3, 11 )
                      , ( 4, 11 )
                      , ( 3, 11 )
                      , ( 2, 11 )
                      ]
                    ]
                )
                i
            )
    , kent =
        \i ->
            ( 2
            , region ( 1 + (modBy 8 i // 2 * 2), 20 ) ( 2 + (modBy 8 i // 2 * 2), 21 )
            )
    }
