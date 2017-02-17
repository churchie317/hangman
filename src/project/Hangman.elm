module Hangman exposing (..)

import Html exposing (..)
import Html.Events exposing (..)
import Html.Attributes exposing (..)
import Array exposing (..)


-- MODEL


type alias Model =
    { secretWord : String
    , currentGuess : String
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
        if String.contains letter model.secretWord then
            { model | guessSoFar = guessSoFar, currentGuess = "" }
        else
            { model | guessSoFar = guessSoFar, currentGuess = "", incorrectGuesses = model.incorrectGuesses + 1 }


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
            { model | currentGuess = entry }



-- VIEW


isNotMemberOf : List String -> String -> Bool
isNotMemberOf xs s =
    not <| List.member s xs


checkDuplicateGuess : List String -> String -> Result String String
checkDuplicateGuess list str =
    if str |> isNotMemberOf list then
        Ok str
    else
        Err "Letter already guessed"


validateGuess : Model -> Html Msg
validateGuess { currentGuess, guessSoFar } =
    let
        result =
            Ok currentGuess
                |> Result.andThen (checkDuplicateGuess guessSoFar)
    in
        case result of
            Ok _ ->
                button [ onClick (SubmitGuess currentGuess) ] [ text "Guess Letter" ]

            Err errorMessage ->
                div [ style [ ( "color", "red" ) ] ] [ text errorMessage ]


view : Model -> Html Msg
view model =
    if model.incorrectGuesses >= 6 then
        div []
            [ text "Game Over :{"
            , button [ onClick Reset ] [ text "Try Again" ]
            ]
    else
        div []
            [ button [ onClick Reset ] [ text "Reset" ]
            , input [ onInput SetGuess, maxlength 1, placeholder "Guess a Letter", value model.currentGuess ] []
            , validateGuess model
            ]
