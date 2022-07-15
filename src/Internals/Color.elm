module Internals.Color exposing (toVector)

import Elm2D.Color exposing (Color)
import Math.Vector4 exposing (Vec4, vec4)


toVector : Color -> Vec4
toVector color =
    let
        { red, green, blue, alpha } =
            Elm2D.Color.toRgba color
    in
    vec4 red green blue alpha
