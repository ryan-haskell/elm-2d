module Examples.Platformer exposing (main)

import Browser
import Browser.Events
import Color
import Elm2D
import Html exposing (Html)
import Json.Decode as Json
import Set exposing (Set)



-- START THE PROGRAM


type alias Flags =
    ()


main : Program Flags Model Msg
main =
    Browser.element
        { init = init
        , update = update
        , view = view
        , subscriptions = subscriptions
        }



-- INIT


type alias Model =
    { player : Player
    , pressedKeys : Set Key
    }


init : Flags -> ( Model, Cmd Msg )
init _ =
    ( { player = newPlayer ( 100, 100 )
      , pressedKeys = Set.empty
      }
    , Cmd.none
    )



-- UPDATE


type Msg
    = Tick Float
    | KeyPressed Key
    | KeyReleased Key


update : Msg -> Model -> ( Model, Cmd Msg )
update msg model =
    case msg of
        KeyPressed key ->
            ( { model | pressedKeys = Set.insert key model.pressedKeys }
            , Cmd.none
            )

        KeyReleased key ->
            ( { model | pressedKeys = Set.remove key model.pressedKeys }
            , Cmd.none
            )

        Tick delta ->
            let
                moveVector : ( Float, Float )
                moveVector =
                    model.pressedKeys
                        |> Set.toList
                        |> List.filterMap toMovementDelta
                        |> List.foldl addVectors ( 0, 0 )

                isJumping =
                    model.pressedKeys
                        |> Set.member "Space"
            in
            ( { model | player = movePlayer delta moveVector isJumping model.player }
            , Cmd.none
            )


subscriptions : Model -> Sub Msg
subscriptions model =
    Sub.batch
        [ Browser.Events.onAnimationFrameDelta Tick
        , Browser.Events.onKeyDown (useKeyboardEvent KeyPressed)
        , Browser.Events.onKeyUp (useKeyboardEvent KeyReleased)
        ]



-- VIEW


size =
    ( 800, 600 )


view : Model -> Html Msg
view model =
    Elm2D.view
        { size = size
        , background = Color.black
        }
        [ Elm2D.rectangle
            { color = Color.blue
            , size = model.player.size
            , position = model.player.position
            }
        ]



-- KEYBOARD INPUT


type alias Key =
    String


useKeyboardEvent : (Key -> msg) -> Json.Decoder msg
useKeyboardEvent fromKeyCode =
    Json.string
        |> Json.field "code"
        |> Json.map fromKeyCode


toMovementDelta : String -> Maybe ( Float, Float )
toMovementDelta keyCode =
    case keyCode of
        -- "KeyW" ->
        --     Just ( 0, -1 )
        -- "KeyS" ->
        --     Just ( 0, 1 )
        "KeyA" ->
            Just ( -1, 0 )

        "KeyD" ->
            Just ( 1, 0 )

        _ ->
            Nothing



-- PLAYER


type alias Player =
    { size : Dimensions
    , direction : Direction
    , velocity : Velocity
    , position : Position
    }


newPlayer : Position -> Player
newPlayer position =
    Player ( 50, 50 ) Right ( 0, 0 ) position


movePlayer : Float -> ( Float, Float ) -> Bool -> Player -> Player
movePlayer delta ( dx, dy ) isJumping player =
    let
        speed =
            delta * 0.125

        gravity =
            delta * 0.035

        friction =
            delta * 0.025

        jump =
            delta * 0.8

        onGround : Bool
        onGround =
            Tuple.second player.position
                >= (Tuple.second size - Tuple.second player.size)

        applyMovement : Velocity -> Velocity
        applyMovement ( vx, vy ) =
            if onGround then
                ( vx + (dx * speed)
                , vy + (dy * speed)
                )

            else
                ( vx + (dx * speed * 0.25)
                , vy + (dy * speed * 0.25)
                )

        applyFriction : Velocity -> Velocity
        applyFriction ( vx, vy ) =
            if onGround then
                ( if vx > 0 then
                    max 0 (vx - friction)

                  else if vx < 0 then
                    min 0 (vx + friction)

                  else
                    vx
                , vy
                )

            else
                ( vx, vy )

        applyGravity : Velocity -> Velocity
        applyGravity ( vx, vy ) =
            if onGround then
                ( vx, 0 )

            else
                ( vx, vy + gravity )

        applyJump : Velocity -> Velocity
        applyJump ( vx, vy ) =
            if onGround && isJumping then
                ( vx, -jump )

            else
                ( vx, vy )

        applyTerminalVelocity : Velocity -> Velocity
        applyTerminalVelocity ( vx, vy ) =
            let
                maxVx =
                    10

                maxVy =
                    15
            in
            ( within -maxVx maxVx vx
            , within -maxVy maxVy vy
            )

        velocity : Velocity
        velocity =
            player.velocity
                |> applyMovement
                |> applyFriction
                |> applyGravity
                |> applyJump
                |> applyTerminalVelocity

        applyVelocity : Position -> Position
        applyVelocity =
            addVectors velocity
    in
    { player
        | direction =
            if dx > 0 then
                Right

            else if dx < 0 then
                Left

            else
                player.direction
        , position =
            player.position
                |> applyVelocity
                |> checkBounds player.size size
        , velocity = velocity
    }



-- DIRECTION


type Direction
    = Left
    | Right



-- POSITION


type alias Position =
    ( Float, Float )


type alias Velocity =
    ( Float, Float )


type alias Dimensions =
    ( Float, Float )


checkBounds : Dimensions -> Dimensions -> Position -> Position
checkBounds ( width, height ) ( maxX, maxY ) ( x, y ) =
    ( within 0 (maxX - width) x
    , within 0 (maxY - height) y
    )


within : Float -> Float -> Float -> Float
within left right value =
    max left (min right value)


addVectors : Position -> Position -> Position
addVectors ( x, y ) ( dx, dy ) =
    ( x + dx, y + dy )
