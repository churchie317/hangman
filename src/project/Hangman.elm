module Hangman exposing (..)

import Html exposing (..)


-- MODEL


type alias Model =
    { secretWord : String
    , guessSoFar : List String
    , wordSoFar : List String
    }


model : Model
model =
    -- Hardcoded secretWord
    -- TODO: make GET request to fetch word
    Model "Hi" [] []



-- UPDATE


type Msg
    = GuessLetter String
    | Reset


update : Msg -> Model -> Model
update msg model =
    case msg of
        Reset ->
            { model | secretWord = "", guessSoFar = [], wordSoFar = [] }

        GuessLetter letter ->
            { model | guessSoFar = letter :: model.guessSoFar }



-- VIEW
-- TODO: incorporate model into view function


view : Model -> Html msg
view model =
    div [] [ text "Hello World" ]
