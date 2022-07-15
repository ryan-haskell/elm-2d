module Internals.Sprite exposing
    ( ProtectedSprite
    , Sprite
    , unwrap
    , wrap
    )

import WebGL.Texture exposing (Texture)


type alias Sprite =
    { size : Int
    , topLeft : ( Int, Int )
    , bottomRight : ( Int, Int )
    , texture : Maybe Texture
    }


type ProtectedSprite
    = ProtectedSprite Sprite


wrap : Sprite -> ProtectedSprite
wrap s =
    ProtectedSprite s


unwrap : ProtectedSprite -> Sprite
unwrap (ProtectedSprite s) =
    s
