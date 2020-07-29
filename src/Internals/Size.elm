module Internals.Size exposing (Size, toVector)

import Math.Vector2 exposing (Vec2, vec2)


type alias Size =
    ( Float, Float )


toVector : Size -> Vec2
toVector ( width, height ) =
    vec2 width height
