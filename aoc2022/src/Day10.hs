module Day10 (module Day10) where

import Text.Megaparsec (Parsec, many, (<|>), parse, errorBundlePretty, takeWhileP)
import Text.Megaparsec.Char (eol, string)
import Data.Void (Void)
import Control.Applicative (liftA2)
import Data.List (scanl')

data Op = Noop | Addx Int deriving Show
type Parser = Parsec Void String
type Register = Int

noopP :: Parser [Op]
noopP = [Noop] <$ string "noop"
addxP :: Parser [Op]
addxP = (Noop:) . pure . Addx . read <$> (string "addx " *> takeWhileP Nothing (/= '\n'))
opsP :: Parser [Op]
opsP = concat <$> many ((addxP <|> noopP) <* eol)

doOp :: Op -> Register -> Register
doOp Noop = id
doOp (Addx x) = (x+)

process :: [Op] -> [Register]
process = scanl' (flip doOp) 1

strengthsSum :: [Op] -> Int
strengthsSum ops = let is = [20, 60, 100, 140, 180, 220]
                       rs = process ops
                   in sum [i*rs!!(i-1) | i <- is]

produceLine :: Int -> [Register] -> String
produceLine _ [] = []
produceLine i (x:xs) = let c = if i >= x-1 && i <= x+1 then '#' else '.'
                       in c:produceLine (i+1) xs

produceLines :: [Register] -> [String]
produceLines [] = []
produceLines rs = produceLine 0 (take 40 rs):produceLines (drop 40 rs)

day10 :: IO ()
day10 = readFile "inputs/day10.txt" >>= putStrLn . \s -> case  parse opsP "" s of
  Left err -> errorBundlePretty err
--  Right ops -> show $ strengthsSum ops
  Right ops -> unlines $ produceLines $ process ops
  
