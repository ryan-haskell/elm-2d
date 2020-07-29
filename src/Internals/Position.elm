module Internals.Position exposing (Position, toVector)

import Math.Vector2 exposing (Vec2, vec2)


type alias Position =
    ( Float, Float )


toVector : Position -> Vec2
toVector ( x, y ) =
    vec2 x y
