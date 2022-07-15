# ryannhg/elm-2d
> a package for building games in WebGL

![An example of a 2D game](./examples/screenshots/animations.png)

## install

```bash
elm install ryannhg/elm-2d
```

## an example

```elm
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
```

![A screenshot of a yellow rectangle](./examples/screenshots/intro.png)


### even more examples

You can see more interesting examples in this project's `examples` folder. Clone this repo and run:

```
elm reactor
```

The examples will be available at http://localhost:8000

