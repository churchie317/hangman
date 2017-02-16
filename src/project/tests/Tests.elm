module Tests exposing (..)

import Test exposing (..)
import Expect exposing (..)
import ElmTestBDDStyle exposing (..)
import Hangman


suite : Test
suite =
    describe "Validation Suite"
        [ describe "update functionality"
            [ it "can handle Reset messages" <|
                expect (Hangman.update Hangman.Reset Hangman.model) to equal <|
                    Hangman.model
            ]
        ]
