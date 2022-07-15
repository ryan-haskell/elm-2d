module Elm2D exposing
    ( Html, view, viewCustom
    , Element, rectangle, sprite
    )

{-|

@docs Html, view, viewCustom

@docs Element, rectangle, sprite

-}

import Elm2D.Color
import Elm2D.Spritesheet exposing (Sprite)
import Html
import Html.Attributes as Attr
import Internals.Renderables.Rectangle as Rectangle
import Internals.Renderables.Sprite as Sprite
import Internals.Settings exposing (Settings)
import Internals.Sprite
import WebGL


type alias Html msg =
    Html.Html msg


view :
    { size : ( Float, Float )
    , background : Elm2D.Color.Color
    }
    -> List Element
    -> Html msg
view options elements =
    Html.div []
        [ Html.node "style"
            []
            [ Html.text """
                html, body, div {
                  height: 100%;
                  margin: 0;
                }
                body > div {
                  background: black;
                  color: white;
                  display: flex;
                  flex-direction: column;
                  justify-content: center;
                  align-items: center;
                } 
              """
            ]
        , viewCustom options elements
        ]


viewCustom :
    { size : ( Float, Float )
    , background : Elm2D.Color.Color
    }
    -> List Element
    -> Html msg
viewCustom options children =
    WebGL.toHtml
        [ Attr.width (floor (Tuple.first options.size))
        , Attr.height (floor (Tuple.second options.size))
        , Attr.style "background-color" (Elm2D.Color.toCssString options.background)
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
    , color : Elm2D.Color.Color
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
