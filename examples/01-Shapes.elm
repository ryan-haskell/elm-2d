module Examples.Shapes exposing (main)

import Elm2D exposing (Html)
import Elm2D.Color


main : Html msg
main =
    Elm2D.view
        { background = Elm2D.Color.fromRgb255 ( 0, 0, 100 )
        , size = ( 800, 600 )
        }
        [ Elm2D.rectangle
            { color = Elm2D.Color.fromRgb255 ( 200, 200, 0 )
            , position = ( 350, 250 )
            , size = ( 100, 100 )
            }
        ]
