module Main exposing (..)

import Html
import Hangman


main : Program Never Hangman.Model Hangman.Msg
main =
    Html.beginnerProgram
        { model = Hangman.model
        , update = Hangman.update
        , view = Hangman.view
        }
