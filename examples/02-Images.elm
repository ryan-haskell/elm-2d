module Examples.Images exposing (main)

import Browser
import Color
import Elm2D
import Elm2D.Spritesheet as Spritesheet exposing (Loadable, Sprite, Spritesheet)
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
    { loadableSpritesheet : Loadable Spritesheet
    }


init : () -> ( Model, Cmd Msg )
init _ =
    ( { loadableSpritesheet = Spritesheet.Loading
      }
    , Spritesheet.load
        { tileSize = 16
        , file = "tileset.png" -- https://fikry13.itch.io/another-rpg-tileset
        , onLoad = LoadedSpritesheet
        }
    )



-- UPDATE


type Msg
    = LoadedSpritesheet (Loadable Spritesheet)


update : Msg -> Model -> ( Model, Cmd Msg )
update msg model =
    case msg of
        LoadedSpritesheet loadable ->
            ( { model | loadableSpritesheet = loadable }
            , Cmd.none
            )


subscriptions : Model -> Sub Msg
subscriptions _ =
    Sub.none



-- VIEW


view : Model -> Html msg
view model =
    case model.loadableSpritesheet of
        Spritesheet.Loading ->
            Html.text "Loading..."

        Spritesheet.Failure reason ->
            Html.text (Debug.toString reason)

        Spritesheet.Success spritesheet ->
            viewScene spritesheet


viewScene : Spritesheet -> Html msg
viewScene spritesheet =
    let
        sprites =
            spritesFor spritesheet
    in
    Elm2D.view
        { size = ( 640, 480 )
        , background = Color.rgb 0.25 0.7 0.5
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
    { chest = sheet |> Spritesheet.select ( 2, 6 )
    , rock = sheet |> Spritesheet.select ( 7, 4 )
    , bush = sheet |> Spritesheet.select ( 5, 4 )
    }
