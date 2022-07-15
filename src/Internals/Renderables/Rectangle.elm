module Internals.Renderables.Rectangle exposing (Options, view)

import Elm2D.Color exposing (Color)
import Internals.Color
import Internals.Position exposing (Position)
import Internals.Settings exposing (Settings)
import Internals.Size exposing (Size)
import Math.Vector2 exposing (Vec2, vec2)
import Math.Vector4 exposing (Vec4)
import WebGL


type alias Options =
    { position : Position
    , size : Size
    , color : Color
    }


view : Settings -> Options -> WebGL.Entity
view settings options =
    let
        uniforms : Uniforms
        uniforms =
            { position = Internals.Position.toVector options.position
            , size = Internals.Size.toVector options.size
            , window = Internals.Size.toVector settings.size
            , color = Internals.Color.toVector options.color
            }
    in
    WebGL.entity vertex fragment mesh uniforms



-- WebGL Stuff


type alias Attributes =
    { index : Vec2
    }


type alias Uniforms =
    { position : Vec2
    , size : Vec2
    , window : Vec2
    , color : Vec4
    }


type alias Varyings =
    {}


vertex : WebGL.Shader Attributes Uniforms Varyings
vertex =
    [glsl|
uniform vec2 position;
uniform vec2 size;
uniform vec2 window;
attribute vec2 index;

void main () {
  gl_Position =
    vec4(
        (index * size + position)
            / window
            * vec2(2, -2)
            + vec2(-1, 1),
        0.0, 1.0
    );
}
|]


fragment : WebGL.Shader {} Uniforms Varyings
fragment =
    [glsl|
precision mediump float;
uniform vec4 color;

void main () {
  gl_FragColor = color;
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
