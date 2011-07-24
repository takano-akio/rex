{-# LANGUAGE TemplateHaskell, QuasiQuotes, ViewPatterns #-}

module Test where

import Text.Regex.PCRE.Rex
import Data.Maybe (catMaybes)

-- main = interact (unlines . map (show . math) . lines)

math x = mathl x 0

mathl [] x = x
mathl [rex|^  \s*(?{ y }\d+)\s*(?{ id -> s }.*)$|] x = mathl s y
mathl [rex|^\+\s*(?{ y }\d+)\s*(?{ id -> s }.*)$|] x = mathl s $ x + y
mathl [rex|^ -\s*(?{ y }\d+)\s*(?{ id -> s }.*)$|] x = mathl s $ x - y
mathl [rex|^\*\s*(?{ y }\d+)\s*(?{ id -> s }.*)$|] x = mathl s $ x * y
mathl [rex|^ /\s*(?{ y }\d+)\s*(?{ id -> s }.*)$|] x = mathl s $ x / y
mathl str x = error str

peano :: String -> Maybe Int
peano = [rex|^(?{ length . filter (=='S') } \s* (?:S\s+)*Z)\s*$|]

vect2d :: String -> Maybe (Int, Int)
vect2d = [rex|^<\s* (?{}\d+) \s*,\s* (?{}\d+) \s*>$|]

-- From http://www.regular-expressions.info/dates.html
parseDate :: String -> Maybe (Int, Int, Int)
parseDate [rex|^(?{ y }(?:19|20)\d\d)[- /.]
                (?{ m }0[1-9]|1[012])[- /.]
                (?{ d }0[1-9]|[12][0-9]|3[01])$|]
  |  (d > 30 && (m `elem` [4, 6, 9, 11]))
  || (m == 2 &&
       (d ==29 && not (mod y 4 == 0 && (mod y 100 /= 0 || mod y 400 == 0)))
    || (d > 29)) = Nothing
  | otherwise = Just (y, m, d)
parseDate _ = Nothing

onNull a f [] = a
onNull _ f xs = f xs

nonNull = onNull Nothing

disjunct [rex| ^(?:(?{nonNull $ Just . head -> a} .)
             | (?{nonNull $ Just . head -> b} ..)
             | (?{nonNull $ Just . last -> c} ...))$|] =
  head $ catMaybes [a, b, c]
