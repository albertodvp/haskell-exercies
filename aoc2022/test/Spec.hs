module Main where

import Day07Test (day07_tests)
import Test.HUnit

main :: IO Counts
main = runTestTT day07_tests
