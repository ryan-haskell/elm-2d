module Examples.Images exposing (main)

import Browser
import Elm2D
import Elm2D.Color
import Elm2D.Spritesheet exposing (Sprite, Spritesheet)
import Html exposing (Html)


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
    { spritesheet : Spritesheet
    }


init : () -> ( Model, Cmd Msg )
init _ =
    ( { spritesheet = Elm2D.Spritesheet.blank
      }
    , Elm2D.Spritesheet.load
        { tileSize = 16
        , file = "assets/tileset.png" -- https://fikry13.itch.io/another-rpg-tileset
        , onLoad = LoadedSpritesheet
        }
    )



-- UPDATE


type Msg
    = LoadedSpritesheet Spritesheet


update : Msg -> Model -> ( Model, Cmd Msg )
update msg model =
    case msg of
        LoadedSpritesheet spritesheet ->
            ( { model | spritesheet = spritesheet }
            , Cmd.none
            )


subscriptions : Model -> Sub Msg
subscriptions _ =
    Sub.none



-- VIEW


view : Model -> Html msg
view model =
    let
        sprites =
            spritesFor model.spritesheet
    in
    Elm2D.view
        { size = ( 640, 480 )
        , background = Elm2D.Color.rgb ( 0.25, 0.7, 0.5 )
        }
        [ Elm2D.sprite
            { sprite = sprites.chest
            , size = ( 64, 64 )
            , position = ( 320, 240 )
            }
        , Elm2D.sprite
            { sprite = sprites.rock
            , size = ( 128, 128 )
            , position = ( 64, 64 )
            }
        , Elm2D.sprite
            { sprite = sprites.bush
            , size = ( 64, 64 )
            , position = ( 192, 192 )
            }
        , Elm2D.sprite
            { sprite = sprites.rock
            , size = ( 64, 64 )
            , position = ( 512, 320 )
            }
        ]


spritesFor :
    Spritesheet
    ->
        { chest : Sprite
        , rock : Sprite
        , bush : Sprite
        }
spritesFor sheet =
    let
        select =
            Elm2D.Spritesheet.select sheet
    in
    { chest = select ( 2, 6 )
    , rock = select ( 7, 4 )
    , bush = select ( 5, 4 )
    }
