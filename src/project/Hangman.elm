module Hangman exposing (..)

import Html exposing (..)
import Array exposing (..)


-- MODEL


type alias Model =
    { secretWord : String
    , guessSoFar : List String
    , wordSoFar : List String
    , incorrectGuesses : Int
    , dictionary : Array String
    }


model : Model
model =
    -- Hardcoded secretWord
    -- TODO: make GET request to fetch word
    Model "Hi" [] [] 0 (fromList [ "approvingly", "carnivals" ])



-- UPDATE


type Msg
    = GuessLetter String
    | Reset


guessLetter : String -> Model -> Model
guessLetter letter model =
    let
        guessSoFar =
            letter :: model.guessSoFar
    in
        if String.contains model.secretWord letter then
            { model | guessSoFar = guessSoFar }
        else
            { model | guessSoFar = guessSoFar, incorrectGuesses = model.incorrectGuesses + 1 }


update : Msg -> Model -> Model
update msg model =
    case msg of
        Reset ->
            { model | secretWord = "", guessSoFar = [], wordSoFar = [] }

        GuessLetter letter ->
            let
                guessSoFar =
                    letter :: model.guessSoFar
            in
                if String.contains model.secretWord letter then
                    { model | guessSoFar = guessSoFar }
                else
                    { model | guessSoFar = guessSoFar, incorrectGuesses = model.incorrectGuesses + 1 }



-- VIEW
-- TODO: incorporate model into view function


view : Model -> Html msg
view model =
    div [] [ text "Hello World" ]
