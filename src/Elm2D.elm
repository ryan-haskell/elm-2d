module Elm2D exposing
    ( view
    , Element, rectangle, sprite
    )

{-|

@docs view
@docs Size, Position

@docs Element, rectangle, sprite

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
    -> List Element
    -> Html msg
view options children =
    WebGL.toHtml
        [ Attr.width (floor (Tuple.first options.size))
        , Attr.height (floor (Tuple.second options.size))
        , Attr.style "background-color" (Color.toCssString options.background)
        ]
        -- reverse & map
        (List.foldl
            (\item list -> render { size = options.size } item :: list)
            []
            children
        )



-- ELEMENTS


type Element
    = Rectangle_ Rectangle.Options
    | SpriteElement Sprite.Options


rectangle :
    { size : ( Float, Float )
    , position : ( Float, Float )
    , color : Color
    }
    -> Element
rectangle =
    Rectangle_


sprite :
    { sprite : Sprite
    , size : ( Float, Float )
    , position : ( Float, Float )
    }
    -> Element
sprite options =
    SpriteElement
        { sprite = Internals.Sprite.unwrap options.sprite
        , size = options.size
        , position = options.position
        }


render : Settings -> Element -> WebGL.Entity
render settings item =
    case item of
        Rectangle_ options ->
            Rectangle.view settings options

        SpriteElement options ->
            Sprite.view settings options
