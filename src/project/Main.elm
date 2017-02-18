module Main exposing (..)

import Html
import Hangman


main : Program Never Hangman.Model Hangman.Msg
main =
    Html.program
        { init =
            ( Hangman.initialModel
            , Hangman.getWords "http://linkedin-reach.hagbpyjegb.us-west-2.elasticbeanstalk.com/words"
            )
        , view = Hangman.view
        , update = Hangman.update
        , subscriptions = Hangman.subscriptions
        }
