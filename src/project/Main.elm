module Main exposing (..)

import Html
import Hangman


main : Program Never Hangman.Model Hangman.Msg
main =
    Html.program
        { init =
            ( Hangman.initialModel
            , Hangman.getWord
            )
        , view = Hangman.view
        , update = Hangman.update
        , subscriptions = Hangman.subscriptions
        }
