module Tests exposing (..)

import Array exposing (Array)
import Test exposing (..)
import Expect exposing (..)
import ElmTestBDDStyle exposing (..)
import Hangman


suite : Test
suite =
    describe "Validation Suite"
        [ describe "getFirstWordFromDictionary"
            [ it "returns first word from list when word exists" <|
                let
                    dictionary =
                        Array.fromList [ "approvingly", "carnivals" ]
                in
                    expect (Hangman.getFirstWordFromDictionary dictionary) to equal <|
                        "approvingly"
            , it "returns a String when array is empty" <|
                let
                    dictionary =
                        Array.fromList []
                in
                    expect (Hangman.getFirstWordFromDictionary dictionary) to equal <|
                        "Error: Word not found!"
            ]
        , describe "update functionality"
            [ it "handles Reset messages" <|
                expect (Hangman.update Hangman.Reset Hangman.initialModel) to equal <|
                    Hangman.initialModel
            ]
        ]
