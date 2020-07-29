module Internals.Color exposing (toVector)

import Color exposing (Color)
import Math.Vector4 exposing (Vec4, vec4)


toVector : Color -> Vec4
toVector color =
    let
        { red, green, blue, alpha } =
            Color.toRgba color
    in
    vec4 red green blue alpha
