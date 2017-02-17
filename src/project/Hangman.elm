module Hangman exposing (..)

import Html exposing (..)
import Html.Events exposing (..)
import Html.Attributes exposing (..)
import Array exposing (..)


-- MODEL


type alias Model =
    { secretWord : String
    , setGuess : String
    , guessSoFar : List String
    , wordSoFar : List String
    , dictionary : Array String
    , incorrectGuesses : Int
    }


dictionary : Array String
dictionary =
    fromList [ "approvingly", "carnivals" ]


initialModel : Model
initialModel =
    Model (getFirstWordFromDictionary dictionary) "" [] [] dictionary 0


getFirstWordFromDictionary : Array String -> String
getFirstWordFromDictionary dictionary =
    let
        -- Hardcoded which element to grab
        word =
            Array.get 0 dictionary
    in
        case word of
            Just word ->
                word

            Nothing ->
                -- TODO: add some error handling here
                "Error: Word not found!"



-- UPDATE


type Msg
    = SubmitGuess String
    | Reset
    | SetGuess String


submitGuess : Model -> String -> Model
submitGuess model letter =
    let
        guessSoFar =
            letter :: model.guessSoFar
    in
        if String.contains model.secretWord letter then
            { model | guessSoFar = guessSoFar, setGuess = "" }
        else
            { model | guessSoFar = guessSoFar, setGuess = "", incorrectGuesses = model.incorrectGuesses + 1 }


update : Msg -> Model -> Model
update msg model =
    case msg of
        Reset ->
            let
                dictionary =
                    model.dictionary

                secretWord =
                    getFirstWordFromDictionary dictionary
            in
                -- Return new Model
                Model secretWord "" [] [] dictionary 0

        SubmitGuess letter ->
            (submitGuess model letter)

        SetGuess entry ->
            { model | setGuess = entry }



-- VIEW


view : Model -> Html Msg
view model =
    if model.incorrectGuesses >= 6 then
        div []
            [ text "Game Over :{"
            , button [ onClick Reset ] [ text "Try Again" ]
            ]
    else if String.length model.setGuess == 1 then
        div []
            [ button [ onClick Reset ] [ text "Reset" ]
            , input [ onInput SetGuess, placeholder "Guess a Letter", value model.setGuess ] []
            , button [ onClick (SubmitGuess model.setGuess) ] [ text "Guess Letter" ]
            ]
    else
        div []
            [ button [ onClick Reset ] [ text "Reset" ]
            , input [ onInput SetGuess, placeholder "Guess a Letter", value model.setGuess ] []
            ]
