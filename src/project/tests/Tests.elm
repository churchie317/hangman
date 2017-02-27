module Tests exposing (..)

import Http
import Test exposing (..)
import Expect exposing (..)
import ElmTestBDDStyle exposing (..)
import Hangman exposing (..)


dummyModel : Model
dummyModel =
    Model
        "approvingly"
        ""
        [ "a", "p", "p", "r", "o", "v", "i", "n", "g", "l", "y" ]
        [ "y", "x" ]
        [ "_", "_", "_", "_", "_", "_", "_", "_", "_", "_", "_" ]
        2
        False
        Nothing


suite : Test
suite =
    describe "Validation Suite"
        [ describe "update"
            [ it "should handle Reset messages" <|
                expect (update Reset dummyModel) to equal <|
                    ( initialModel, getWord )
              -- , it "should handle SubmitGuess"
            , it "should handle SubmitGuess messages" <|
                expect (update (SubmitGuess "p") dummyModel) to equal <|
                    ( submitGuess "p" dummyModel, Cmd.none )
            , it "should handle SetGuess messages" <|
                expect (update (SetGuess "z") dummyModel) to equal <|
                    ( { dummyModel | currentGuess = "z" }, Cmd.none )
            , it "should handle LoadWord when word successfully retrieved from server" <|
                expect (update (LoadWord (Ok "pteropine")) initialModel) to equal <|
                    ( { initialModel
                        | secretWord = "pteropine"
                        , spinner = False
                        , wordSoFar = wordSoFar "pteropine"
                        , secretWordListified = String.split "" "pteropine"
                      }
                    , Cmd.none
                    )
            , it "should fail gracefully when word not retrieved from server" <|
                expect (update (LoadWord (Err Http.NetworkError)) initialModel) to equal <|
                    ( { initialModel
                        | secretWord = "pteropine"
                        , spinner = False
                        , wordSoFar = wordSoFar "pteropine"
                        , secretWordListified = String.split "" "pteropine"
                        , error = Just Http.NetworkError
                      }
                    , Cmd.none
                    )
            ]
        , describe "mapUnderscoreToLetter"
            [ it "should return underscore string when source does not match toMatch" <|
                expect (mapUnderscoreToLetter "a" "b" "_") to equal <|
                    "_"
            , it "should return target when target is not underscore string" <|
                expect (mapUnderscoreToLetter "c" "f" "A") to equal <|
                    "A"
            , it "should return source when toMatch matches source" <|
                expect (mapUnderscoreToLetter "c" "c" "_") to equal <|
                    "C"
            ]
        , describe "submitGuess"
            [ it "should update incorrectGuesses when guess not in secretWord" <|
                expect (submitGuess "z" dummyModel).incorrectGuesses to equal <|
                    3
            , it "should update model when guess in secretWord" <|
                expect (submitGuess "p" dummyModel) to equal <|
                    Model
                        "approvingly"
                        ""
                        [ "a", "p", "p", "r", "o", "v", "i", "n", "g", "l", "y" ]
                        [ "p", "y", "x" ]
                        [ "_", "P", "P", "_", "_", "_", "_", "_", "_", "_", "_" ]
                        2
                        False
                        Nothing
            ]
        ]
