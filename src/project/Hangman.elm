module Hangman exposing (..)

import Html exposing (..)
import Html.Events exposing (..)
import Html.Attributes exposing (..)
import Http
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
    | LoadWords (Result Http.Error String)


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


update : Msg -> Model -> ( Model, Cmd Msg )
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
                ( Model secretWord "" [] [] dictionary 0, Cmd.none )

        SubmitGuess letter ->
            ( submitGuess model (String.toLower letter), Cmd.none )

        SetGuess entry ->
            ( { model | currentGuess = entry }, Cmd.none )

        LoadWords (Ok words) ->
            ( { model | dictionary = String.lines words |> Array.fromList }, Cmd.none )

        LoadWords (Err _) ->
            -- TODO: handle HTTP REQUEST error
            ( model, Cmd.none )



-- VIEW


isNotEmptyTextField : String -> Result String String
isNotEmptyTextField str =
    if String.length str >= 1 then
        Ok str
    else
        Err ""


isLetter : String -> Result String String
isLetter str =
    let
        lowerStr =
            String.toLower str
    in
        if "a" <= lowerStr && lowerStr <= "z" then
            Ok str
        else
            Err "Whoops, make sure your guess is a letter!"


isNotMemberOf : List String -> String -> Bool
isNotMemberOf xs s =
    not <| List.member (String.toLower s) xs


isNotDuplicate : List String -> String -> Result String String
isNotDuplicate list str =
    if str |> isNotMemberOf list then
        Ok str
    else
        Err "Sorry, you've already guessed that letter. Please guess a new one."


validateGuess : Model -> Html Msg
validateGuess { currentGuess, guessedSoFar } =
    let
        result =
            Ok currentGuess
                |> Result.andThen (isNotEmptyTextField)
                |> Result.andThen (isLetter)
                |> Result.andThen (isNotDuplicate guessedSoFar)
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
        [ div []
            [ text
                ("Guessed letters: "
                    ++ (joinAndUppercase model.guessedSoFar)
                )
            ]
        , button [ onClick Reset ] [ text "New Game" ]
        , input [ onInput SetGuess, maxlength 1, placeholder "Guess a Letter", value model.currentGuess ] []
        , validateGuess model
        , div [] [ text ("Incorrect guesses remaining: " ++ (6 - model.incorrectGuesses |> toString)) ]
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



-- SUBSCRIPTIONS


subscriptions : Model -> Sub Msg
subscriptions model =
    Sub.none



-- HTTP


getWords : String -> Cmd Msg
getWords url =
    Http.send LoadWords (Http.getString url)
