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
    , secretWordCharList : List String
    , guessedSoFar : List String
    , wordSoFar : List String
    , incorrectGuesses : Int
    , spinner : Bool
    , error : Maybe Http.Error
    }


dictionary : Array String
dictionary =
    fromList [ "approvingly", "carnivals" ]


initialModel : Model
initialModel =
    Model "" "" [] [] [] 0 True Nothing



-- UPDATE


type Msg
    = SubmitGuess String
    | Reset
    | SetGuess String
    | LoadWord (Result Http.Error String)


defaultWord : String
defaultWord =
    "pteropine"


submitGuess : Model -> String -> Model
submitGuess model letter =
    let
        guessedSoFar =
            letter :: model.guessedSoFar

        wordSoFar =
            List.map2 (mapCharToUnderscore letter) model.secretWordCharList model.wordSoFar
    in
        if String.contains letter model.secretWord then
            { model | guessedSoFar = guessedSoFar, currentGuess = "", wordSoFar = wordSoFar }
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


mapCharToUnderscore : String -> String -> String -> String
mapCharToUnderscore letter str1 str2 =
    if str1 == letter || str2 /= "_" then
        String.toUpper str1
    else
        "_"


update : Msg -> Model -> ( Model, Cmd Msg )
update msg model =
    case msg of
        Reset ->
            -- Return new initial model and fetch new word
            ( initialModel, getWord )

        SubmitGuess letter ->
            ( submitGuess model (String.toLower letter), Cmd.none )

        SetGuess entry ->
            ( { model | currentGuess = entry }, Cmd.none )

        LoadWord (Ok word) ->
            let
                wordSoFar : List String
                wordSoFar =
                    List.repeat (String.length word) "_"
            in
                ( { model | secretWord = word, spinner = False, wordSoFar = wordSoFar, secretWordCharList = String.split "" word }, Cmd.none )

        LoadWord (Err httpError) ->
            let
                wordSoFar : List String
                wordSoFar =
                    List.repeat (String.length defaultWord) "_"
            in
                ( { model | error = Just httpError, wordSoFar = wordSoFar, secretWord = defaultWord, spinner = False, secretWordCharList = String.split "" defaultWord }, Cmd.none )



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



-- TODO: refactor for view
-- handleHttpError : Http.Error -> Model -> ( Model, Cmd Msg )
-- handleHttpError httpErr model =
--     case httpErr of
--         Http.BadUrl err ->
--             ( { model | error = "BAD URL ERROR: " ++ err }, Cmd.none )
--
--         Http.Timeout ->
--             ( { model | error = "TIMEOUT ERROR" }, Cmd.none )
--
--         Http.NetworkError ->
--             ( { model | error = "NETWORK ERROR" }, Cmd.none )
--
--         Http.BadStatus _ ->
--             ( { model | error = "BAD STATUS ERROR" }, Cmd.none )
--
--         Http.BadPayload _ _ ->
--             ( { model | error = "BAD PAYLOAD ERROR" }, Cmd.none )


isLength : String -> Int -> Bool
isLength str2 int =
    String.length str2 == int


isGameWon : Model -> Bool
isGameWon model =
    model.wordSoFar
        |> List.filter (\x -> x /= "_")
        |> List.length
        |> isLength model.secretWord


gameOverView : Html Msg
gameOverView =
    div [ class "content" ]
        [ div [ class "error" ]
            [ text "Game Over :{"
            , button [ onClick Reset ] [ text "Play again?" ]
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
        , div [] [ text ("Word so far: " ++ (String.join " " model.wordSoFar)) ]
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
    if model.spinner then
        contentView (div [] [])
    else if model.incorrectGuesses >= 6 then
        contentView gameOverView
    else if isGameWon model then
        contentView gameOverView
    else
        contentView (submitGuessView model)



-- SUBSCRIPTIONS


subscriptions : Model -> Sub Msg
subscriptions model =
    Sub.none



-- HTTP


type alias Request =
    { verb : String
    , headers : List ( String, String )
    , url : String
    }


getWord : Cmd Msg
getWord =
    Http.getString "/getword"
        |> Http.send LoadWord
