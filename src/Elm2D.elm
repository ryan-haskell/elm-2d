module Elm2D exposing
    ( view
    , Renderable, rectangle, sprite
    )

{-|

@docs view
@docs Size, Position

@docs Renderable, rectangle, sprite

-}

import Color exposing (Color)
import Elm2D.Spritesheet exposing (Sprite)
import Html exposing (Html)
import Html.Attributes as Attr
import Internals.Renderables.Rectangle as Rectangle
import Internals.Renderables.Sprite as Sprite
import Internals.Settings exposing (Settings)
import Internals.Sprite
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
    = Rectangle_ Rectangle.Options
    | Sprite_ Sprite.Options


rectangle :
    { size : ( Float, Float )
    , position : ( Float, Float )
    , color : Color
    }
    -> Renderable
rectangle =
    Rectangle_


sprite :
    { sprite : Sprite
    , size : ( Float, Float )
    , position : ( Float, Float )
    }
    -> Renderable
sprite options =
    Sprite_
        { sprite = Internals.Sprite.unwrap options.sprite
        , size = options.size
        , position = options.position
        }


render : Settings -> Renderable -> WebGL.Entity
render settings item =
    case item of
        Rectangle_ options ->
            Rectangle.view settings options

        Sprite_ options ->
            Sprite.view settings options
