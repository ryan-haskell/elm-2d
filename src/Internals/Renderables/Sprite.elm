module Internals.Renderables.Sprite exposing (Options, view)

import Elm2D.Color
import Internals.Position exposing (Position)
import Internals.Renderables.Rectangle
import Internals.Settings exposing (Settings)
import Internals.Size exposing (Size)
import Internals.Sprite
import Math.Vector2 exposing (Vec2, vec2)
import WebGL
import WebGL.Texture as Texture exposing (Texture)


type alias Options =
    { sprite : Internals.Sprite.Sprite
    , position : Position
    , size : Size
    }


view : Settings -> Options -> WebGL.Entity
view settings options =
    let
        uniforms : Texture -> Uniforms
        uniforms texture =
            { position = Internals.Position.toVector options.position
            , size = Internals.Size.toVector options.size
            , window = Internals.Size.toVector settings.size
            , texture = texture
            , textureSize = Texture.size texture |> coordinatesToVector
            , selectionSize = toFloat options.sprite.size
            , topLeft = coordinatesToVector options.sprite.topLeft
            , bottomRight = coordinatesToVector options.sprite.bottomRight
            }
    in
    case options.sprite.texture of
        Just texture ->
            WebGL.entity vertex fragment mesh (uniforms texture)

        Nothing ->
            Internals.Renderables.Rectangle.view
                { size = settings.size
                }
                { position = options.position
                , size = options.size
                , color = Elm2D.Color.fromRgba ( 0, 0, 0 ) 0
                }


coordinatesToVector : ( Int, Int ) -> Vec2
coordinatesToVector ( x, y ) =
    vec2 (toFloat x) (toFloat y)



-- WebGL Stuff


type alias Attributes =
    { index : Vec2
    }


type alias Uniforms =
    { texture : Texture
    , textureSize : Vec2
    , selectionSize : Float
    , topLeft : Vec2
    , bottomRight : Vec2
    , position : Vec2
    , size : Vec2
    , window : Vec2
    }


type alias Varyings =
    { vindex : Vec2
    }


vertex : WebGL.Shader Attributes Uniforms Varyings
vertex =
    [glsl|
uniform vec2 position;
uniform vec2 size;
uniform vec2 window;
attribute vec2 index;
varying vec2 vindex;

void main () {
  gl_Position =
    vec4(
        (index * size + position)
            / window
            * vec2(2, -2)
            + vec2(-1, 1),
        0.0, 1.0
    );
  vindex = index;
}
|]


fragment : WebGL.Shader {} Uniforms Varyings
fragment =
    [glsl|
precision mediump float;
uniform sampler2D texture;
uniform vec2 textureSize;
uniform float selectionSize;
uniform vec2 topLeft;
uniform vec2 bottomRight;
varying vec2 vindex;

void main () {
  gl_FragColor = texture2D(texture,
    (vindex * (bottomRight - topLeft + vec2(1, 1)) + topLeft)
        / textureSize
        * vec2(selectionSize, selectionSize)
        * vec2(1, -1));
  if (gl_FragColor.a == 0.0) {
    discard;
  }
}
|]


mesh : WebGL.Mesh Attributes
mesh =
    WebGL.indexedTriangles
        [ { index = vec2 0 0 }
        , { index = vec2 1 0 }
        , { index = vec2 1 1 }
        , { index = vec2 0 1 }
        ]
        [ ( 0, 1, 2 )
        , ( 2, 3, 0 )
        ]
