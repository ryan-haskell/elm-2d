module Examples.Shapes exposing (main)

import Color
import Elm2D


main =
    Elm2D.view
        { background = Color.blue
        , size = ( 800, 600 )
        }
        [ Elm2D.rectangle
            { color = Color.yellow
            , position = ( 350, 250 )
            , size = ( 100, 100 )
            }
        ]
