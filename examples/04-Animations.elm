module Examples.Animations exposing (main)

import Array exposing (Array)
import Browser
import Browser.Events
import Color
import Elm2D
import Elm2D.Spritesheet as Spritesheet exposing (Loadable, Sprite, Spritesheet)
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
    { tileset : Loadable Spritesheet
    , dungeon : Loadable Spritesheet
    , counter : Int
    }


init : () -> ( Model, Cmd Msg )
init _ =
    ( { tileset = Spritesheet.Loading
      , dungeon = Spritesheet.Loading
      , counter = 0
      }
    , Cmd.batch
        [ Spritesheet.load
            { tileSize = 16
            , file = "assets/tileset.png" -- Artwork from: https://fikry13.itch.io/another-rpg-tileset
            , onLoad = Loaded Tileset
            }
        , Spritesheet.load
            { tileSize = 1
            , file = "assets/dungeon-tileset.png" -- Artwork from: https://0x72.itch.io/dungeontileset-ii
            , onLoad = Loaded Dungeon
            }
        ]
    )



-- UPDATE


type Msg
    = Loaded Asset (Loadable Spritesheet)
    | TickAnimation Float


type Asset
    = Tileset
    | Dungeon


update : Msg -> Model -> ( Model, Cmd Msg )
update msg model =
    case msg of
        Loaded Tileset loadable ->
            ( { model | tileset = loadable }
            , Cmd.none
            )

        Loaded Dungeon loadable ->
            ( { model | dungeon = loadable }
            , Cmd.none
            )

        TickAnimation _ ->
            ( { model | counter = modBy 640 (model.counter + 1) }
            , Cmd.none
            )


subscriptions : Model -> Sub Msg
subscriptions _ =
    Browser.Events.onAnimationFrameDelta TickAnimation



-- VIEW


view : Model -> Html msg
view model =
    case ( model.tileset, model.dungeon ) of
        ( Spritesheet.Success t, Spritesheet.Success d ) ->
            viewScene model { tileset = t, dungeon = d }

        ( Spritesheet.Failure reason, _ ) ->
            Html.text (Debug.toString reason)

        ( _, Spritesheet.Failure reason ) ->
            Html.text (Debug.toString reason)

        _ ->
            Html.text "Loading..."


viewScene : Model -> { tileset : Spritesheet, dungeon : Spritesheet } -> Html msg
viewScene model spritesheets =
    let
        sprites =
            spritesFor spritesheets

        animatedSprites options =
            options.sprites
                |> Array.get (modBy (Array.length options.sprites) (model.counter // 8))
                |> Maybe.withDefault sprites.rock
                |> (\sprite ->
                        Elm2D.sprite
                            { sprite = sprite
                            , size = options.size
                            , position = options.position
                            }
                   )
    in
    Elm2D.view
        { size = ( 640, 480 )
        , background = Color.rgb 0.25 0.7 0.5
        }
        [ animatedSprites
            { sprites = sprites.wizard.run
            , size = ( 64, 112 )
            , position = ( toFloat model.counter * 2 - 200, 0 )
            }
        , Elm2D.sprite
            { sprite = sprites.chest
            , size = ( 64, 64 )
            , position = ( 320, 240 )
            }
        , Elm2D.sprite
            { sprite = sprites.rock
            , size = ( 128, 128 )
            , position = ( 64, 64 )
            }
        , animatedSprites
            { sprites = sprites.elf.idle
            , size = ( 64, 112 )
            , position = ( 112, 112 )
            }
        , Elm2D.sprite
            { sprite = sprites.bush
            , size = ( 64, 64 )
            , position = ( 192, 192 )
            }
        , Elm2D.sprite
            { sprite = sprites.forest.left
            , size = ( 128, 256 )
            , position = ( 320, -32 )
            }
        , Elm2D.sprite
            { sprite = sprites.forest.middle
            , size = ( 64, 256 )
            , position = ( 448, -32 )
            }
        , Elm2D.sprite
            { sprite = sprites.forest.middle
            , size = ( 64, 256 )
            , position = ( 512, -32 )
            }
        , Elm2D.sprite
            { sprite = sprites.forest.right
            , size = ( 128, 256 )
            , position = ( 576, -32 )
            }
        , animatedSprites
            { sprites = sprites.elf.run
            , size = ( 64, 112 )
            , position = ( toFloat model.counter * 4 - 800, 250 )
            }
        , Elm2D.sprite
            { sprite = sprites.tree
            , size = ( 256, 256 )
            , position = ( 414, 192 )
            }
        ]


spritesFor :
    { tileset : Spritesheet, dungeon : Spritesheet }
    ->
        { chest : Sprite
        , rock : Sprite
        , bush : Sprite
        , tree : Sprite
        , forest :
            { left : Sprite
            , middle : Sprite
            , right : Sprite
            }
        , elf :
            { idle : Array Sprite
            , run : Array Sprite
            }
        , wizard :
            { run : Array Sprite
            }
        }
spritesFor { tileset, dungeon } =
    { chest = tileset |> Spritesheet.select ( 3, 6 )
    , rock = tileset |> Spritesheet.select ( 7, 4 )
    , bush = tileset |> Spritesheet.select ( 5, 4 )
    , tree = tileset |> Spritesheet.region ( 3, 1 ) ( 5, 3 )
    , forest =
        { left = tileset |> Spritesheet.region ( 2, 7 ) ( 3, 10 )
        , middle = tileset |> Spritesheet.region ( 4, 7 ) ( 4, 10 )
        , right = tileset |> Spritesheet.region ( 5, 7 ) ( 6, 10 )
        }
    , elf =
        { idle = animation dungeon ( 16, 28 ) ( 128, 36 ) 4
        , run = animation dungeon ( 16, 28 ) ( 192, 36 ) 4
        }
    , wizard =
        { run =
            Array.fromList
                [ dungeon |> Spritesheet.region ( 192 + (16 * 0), 164 ) ( 192 + 15 + (16 * 0), 164 + 28 )
                , dungeon |> Spritesheet.region ( 192 + (16 * 1), 164 ) ( 192 + 15 + (16 * 1), 164 + 28 )
                , dungeon |> Spritesheet.region ( 192 + (16 * 2), 164 ) ( 192 + 15 + (16 * 2), 164 + 28 )
                , dungeon |> Spritesheet.region ( 192 + (16 * 3), 164 ) ( 192 + 15 + (16 * 3), 164 + 28 )
                ]
        }
    }


animation : Spritesheet -> ( Int, Int ) -> ( Int, Int ) -> Int -> Array Sprite
animation sheet ( w, h ) ( x, y ) count =
    List.range 1 count
        |> List.map (\i -> sheet |> Spritesheet.region ( x + (w * (i - 1)), y ) ( x + (w * i), y + h ))
        |> Array.fromList
