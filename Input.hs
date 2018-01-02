module Input ( Channel
             , Message(..)
             , Nick
             , SANMove
             , parseMessage
             ) where

{-

Parser para los mensajes entrantes

-}

import Text.Parsec ((<|>), ParseError, eof, many1, parse)
import Text.Parsec.Char (alphaNum, char, letter, space, string)
import Text.Parsec.String (Parser)

import Control.Applicative ((<*))

type Channel = String
type Nick    = String
type SANMove = String

data Message = Session Channel
             | Close
             | Register Nick
             | Start    Nick
             | Move     Nick SANMove
             | Draw     Nick
             | Resign   Nick
             deriving (Eq, Show)

-- | Helpers
word :: Parser String
word = many1 letter


-- | Parsers para los distintos mensajes
session :: Parser Message
session = do string  "SESSION"
             space
             hashtag <- char '#'
             chan    <- word
             return (Session (hashtag:chan))

close :: Parser Message
close = do string  "CLOSE"
           return Close

register :: Parser Message
register = do string "REGISTER"
              space
              nick <- word
              return (Register nick)

start :: Parser Message
start = do string "START"
           space
           nick <- word
           return (Start nick)

move :: Parser Message
move = do string "MOVE"
          space
          nick <- word
          space
          move <- many1 alphaNum
          return (Move nick move)

draw :: Parser Message
draw = do string "DRAW"
          space
          nick <- word
          return (Draw nick)
             
resign :: Parser Message
resign = do string "RESIGN"
            space
            nick <- word
            return (Resign nick)

            
-- | Parser principal
parserMsg :: Parser Message
parserMsg = session
        <|> close
        <|> register
        <|> start
        <|> move
        <|> draw
        <|> resign

-- | Función que realiza el parsing
parseMessage :: String -> Either ParseError Message
parseMessage = parse (parserMsg <* eof) ""