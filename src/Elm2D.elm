module Elm2D exposing
    ( view
    , Renderable, rectangle
    )

{-|

@docs view
@docs Size, Position

@docs Renderable, rectangle

-}

import Color exposing (Color)
import Html exposing (Html)
import Html.Attributes as Attr
import Internals.Renderables.Rectangle as Rectangle
import Internals.Settings exposing (Settings)
import WebGL


view :
    { size : ( Float, Float )
    , background : Color
    }
    -> List Renderable
    -> Html msg
view options renderables =
    WebGL.toHtml
        [ Attr.width (floor (Tuple.first options.size))
        , Attr.height (floor (Tuple.second options.size))
        , Attr.style "background-color" (Color.toCssString options.background)
        ]
        -- reverse & map
        (List.foldl
            (\item list -> render { size = options.size } item :: list)
            []
            renderables
        )



-- RENDERABLES


type Renderable
    = Rectangle Rectangle.Options


rectangle : { size : ( Float, Float ), position : ( Float, Float ), color : Color } -> Renderable
rectangle =
    Rectangle


render : Settings -> Renderable -> WebGL.Entity
render settings item =
    case item of
        Rectangle options ->
            Rectangle.view settings options
