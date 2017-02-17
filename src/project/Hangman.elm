module Hangman exposing (..)

import Html exposing (..)
import Html.Events exposing (..)
import Html.Attributes exposing (..)
import Array exposing (..)


-- MODEL


type alias Model =
    { secretWord : String
    , currentGuess : String
    , guessedSoFar : List String
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



-- UPDATE


type Msg
    = SubmitGuess String
    | Reset
    | SetGuess String


submitGuess : Model -> String -> Model
submitGuess model letter =
    let
        guessedSoFar =
            letter :: model.guessedSoFar
    in
        if String.contains letter model.secretWord then
            { model | guessedSoFar = guessedSoFar, currentGuess = "" }
        else
            { model | guessedSoFar = guessedSoFar, currentGuess = "", incorrectGuesses = model.incorrectGuesses + 1 }


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
            submitGuess model (String.toLower letter)

        SetGuess entry ->
            { model | currentGuess = entry }



-- VIEW


isNotMemberOf : List String -> String -> Bool
isNotMemberOf xs s =
    not <| List.member (String.toLower s) xs


checkDuplicateGuess : List String -> String -> Result String String
checkDuplicateGuess list str =
    if str |> isNotMemberOf list then
        Ok str
    else
        Err "Sorry, you've already guessed that letter. Please guess a new one."


validateGuess : Model -> Html Msg
validateGuess { currentGuess, guessedSoFar } =
    let
        result =
            Ok currentGuess
                |> Result.andThen (checkDuplicateGuess guessedSoFar)
    in
        case result of
            Ok _ ->
                button [ onClick (SubmitGuess currentGuess) ] [ text "Guess Letter" ]

            Err errorMessage ->
                div [ class "error" ] [ text errorMessage ]


joinAndUppercase : List String -> String
joinAndUppercase list =
    List.map String.toUpper list
        |> String.join ", "


gameOverView : Html Msg
gameOverView =
    div [ class "content" ]
        [ div [ class "error" ]
            [ text "Game Over :{"
            , button [ onClick Reset ] [ text "Try Again" ]
            ]
        ]


submitGuessView : Model -> Html Msg
submitGuessView model =
    div [ class "content" ]
        [ div [] [ text (joinAndUppercase model.guessedSoFar) ]
        , button [ onClick Reset ] [ text "New Game" ]
        , input [ onInput SetGuess, maxlength 1, placeholder "Guess a Letter", value model.currentGuess ] []
        , validateGuess model
        ]


contentView : Html Msg -> Html Msg
contentView view =
    div []
        [ header []
            [ h1 [ class "content" ]
                [ text "Hangman" ]
            ]
        , view
        ]


view : Model -> Html Msg
view model =
    if model.incorrectGuesses >= 6 then
        contentView gameOverView
    else
        contentView (submitGuessView model)
