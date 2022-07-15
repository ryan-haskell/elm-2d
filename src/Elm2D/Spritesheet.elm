module Elm2D.Spritesheet exposing
    ( Spritesheet, blank, load
    , Sprite, select, region
    , Animation, animation, frame
    )

{-|

@docs Spritesheet, blank, load
@docs Sprite, select, region
@docs Animation, animation, frame

-}

import Array exposing (Array)
import Internals.Sprite exposing (Sprite)
import Task
import WebGL.Texture exposing (defaultOptions)


type Spritesheet
    = Spritesheet Int (Maybe WebGL.Texture.Texture)


options_ : WebGL.Texture.Options
options_ =
    { defaultOptions | magnify = WebGL.Texture.nearest }


blank : Spritesheet
blank =
    Spritesheet 1 Nothing


load :
    { tileSize : Int
    , file : String
    , onLoad : Spritesheet -> msg
    }
    -> Cmd msg
load options =
    WebGL.Texture.loadWith options_ options.file
        |> Task.attempt
            (\result ->
                Result.toMaybe result
                    |> Spritesheet options.tileSize
                    |> options.onLoad
            )


type alias Sprite =
    Internals.Sprite.ProtectedSprite


select : Spritesheet -> ( Int, Int ) -> Sprite
select (Spritesheet size texture) coordinates =
    Internals.Sprite.wrap
        { size = size
        , topLeft = coordinates
        , bottomRight = coordinates
        , texture = texture
        }


region : Spritesheet -> ( Int, Int ) -> ( Int, Int ) -> Sprite
region (Spritesheet size texture) topLeft bottomRight =
    Internals.Sprite.wrap
        { size = size
        , topLeft = topLeft
        , bottomRight = bottomRight
        , texture = texture
        }



-- Animations


type Animation
    = Animation Spritesheet (Array Sprite)


animation : Spritesheet -> List ( Int, Int ) -> Animation
animation spritesheet indices =
    indices
        |> List.map (select spritesheet)
        |> Array.fromList
        |> Animation spritesheet


frame : Int -> Animation -> Sprite
frame i (Animation (Spritesheet _ texture) array) =
    array
        |> Array.get (modBy (Array.length array) i)
        |> Maybe.withDefault
            (Internals.Sprite.wrap
                { size = 0
                , topLeft = ( 0, 0 )
                , bottomRight = ( 0, 0 )
                , texture = texture
                }
            )
