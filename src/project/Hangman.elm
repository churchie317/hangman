module Hangman exposing (..)

import Html exposing (..)
import Html.Events exposing (..)
import Html.Attributes exposing (..)
import Http


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
            List.map2
                (mapUnderscoreToLetter letter)
                model.secretWordCharList
                model.wordSoFar

        newModel =
            { model
                | guessedSoFar = guessedSoFar
                , currentGuess = ""
                , wordSoFar = wordSoFar
            }
    in
        if String.contains letter model.secretWord then
            { newModel | wordSoFar = wordSoFar }
        else
            { newModel | incorrectGuesses = model.incorrectGuesses + 1 }


mapUnderscoreToLetter : String -> String -> String -> String
mapUnderscoreToLetter toMatch source target =
    if source == toMatch then
        String.toUpper source
    else if target /= "_" then
        target
    else
        "_"


wordSoFar : String -> List String
wordSoFar word =
    List.repeat (String.length word) "_"


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
            ( { model
                | secretWord = word
                , spinner = False
                , wordSoFar = wordSoFar word
                , secretWordCharList = String.split "" word
              }
            , Cmd.none
            )

        LoadWord (Err httpError) ->
            ( { model
                | error = Just httpError
                , wordSoFar = wordSoFar defaultWord
                , secretWord = defaultWord
                , spinner = False
                , secretWordCharList = String.split "" defaultWord
              }
            , Cmd.none
            )



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
        Err "Yikes, you've already guessed that letter. Please try another one."


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
                div []
                    [ button [ onClick (SubmitGuess currentGuess), class "search", disabled False ]
                        [ text "Guess Letter" ]
                    ]

            Err errorMessage ->
                div []
                    [ button [ onClick (SubmitGuess currentGuess), class "search", disabled True ]
                        [ text "Guess Letter" ]
                    , div [ class "error" ] [ text errorMessage ]
                    ]


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


gameOverView : Model -> Html Msg
gameOverView model =
    div [ class "content" ]
        [ div [ class "error" ]
            [ text ("Game Over: your word was " ++ model.secretWord) ]
        ]


gameWonView : Model -> Html Msg
gameWonView model =
    div [ class "content" ]
        [ div [ class "error" ]
            [ text ("Congratulations! You successfully guessed the word: " ++ model.secretWord) ]
        ]


activeGameView : Model -> Html Msg
activeGameView model =
    div [ class "content" ]
        [ div [ class "board" ]
            [ text
                ("Guessed letters: "
                    ++ (joinAndUppercase model.guessedSoFar)
                )
            , div [] [ text ("Word so far: " ++ (String.join " " model.wordSoFar)) ]
            , div [] [ text ("Incorrect guesses remaining: " ++ (6 - model.incorrectGuesses |> toString)) ]
            ]
        , div [ class "center" ]
            [ input
                [ onInput SetGuess
                , maxlength 1
                , placeholder "Guess a Letter"
                , value model.currentGuess
                , class "input"
                ]
                []
            , validateGuess model
            ]
        ]


contentView : Html Msg -> Html Msg
contentView view =
    div []
        [ header []
            [ ul []
                [ li []
                    [ h1 [ class "content" ]
                        [ text "Hangman" ]
                    ]
                , button [ onClick Reset, class "reset" ] [ text "New Game" ]
                ]
            ]
        , view
        ]


view : Model -> Html Msg
view model =
    if model.spinner then
        contentView (div [ class "spinner" ] [])
    else if model.incorrectGuesses >= 6 then
        contentView (gameOverView model)
    else if isGameWon model then
        contentView (gameOverView model)
    else
        contentView (activeGameView model)



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
