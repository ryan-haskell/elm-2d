module Elm2D.Spritesheet exposing
    ( Loadable(..)
    , Sprite
    , Spritesheet
    , load
    , select
    )

import Internals.Sprite exposing (Sprite)
import Task
import WebGL.Texture exposing (defaultOptions)


type Spritesheet
    = Spritesheet Int WebGL.Texture.Texture


type Loadable spritesheet
    = Loading
    | Success spritesheet
    | Failure WebGL.Texture.Error


options_ : WebGL.Texture.Options
options_ =
    { defaultOptions | magnify = WebGL.Texture.nearest }


load : { tileSize : Int, file : String, onLoad : Loadable Spritesheet -> msg } -> Cmd msg
load options =
    WebGL.Texture.loadWith options_
        options.file
        |> Task.attempt (toLoadable options.tileSize >> options.onLoad)


type alias Sprite =
    Internals.Sprite.ProtectedSprite


select : ( Int, Int ) -> Spritesheet -> Sprite
select coordinates (Spritesheet size texture) =
    Internals.Sprite.wrap
        { size = size
        , coordinates = coordinates
        , texture = texture
        }



-- INTERNALS


toLoadable : Int -> Result WebGL.Texture.Error WebGL.Texture.Texture -> Loadable Spritesheet
toLoadable tileSize result =
    case result of
        Ok texture ->
            Success (Spritesheet tileSize texture)

        Err reason ->
            Failure reason
