module Elm2D.Color exposing
    ( Color
    , fromRgb, fromRgba
    , fromRgb255, fromRgba255
    , toRgba, toCssString
    )

{-|

@docs Color
@docs fromRgb, fromRgba
@docs fromRgb255, fromRgba255

@docs toRgba, toCssString

-}

import Color as Avh4


type Color
    = Color Avh4.Color


fromRgb : ( Float, Float, Float ) -> Color
fromRgb ( r, g, b ) =
    Color (Avh4.rgb r g b)


fromRgba : ( Float, Float, Float ) -> Float -> Color
fromRgba ( r, g, b ) a =
    Color (Avh4.rgba r g b a)


fromRgb255 : ( Int, Int, Int ) -> Color
fromRgb255 ( r, g, b ) =
    Color (Avh4.rgb255 r g b)


fromRgba255 : ( Int, Int, Int ) -> Float -> Color
fromRgba255 ( r, g, b ) a =
    Color
        (Avh4.fromRgba
            { red = toFloat r / 255
            , green = toFloat g / 255
            , blue = toFloat b / 255
            , alpha = a
            }
        )


toRgba : Color -> { red : Float, blue : Float, green : Float, alpha : Float }
toRgba (Color color) =
    Avh4.toRgba color


toCssString : Color -> String
toCssString (Color color) =
    Avh4.toCssString color
