{-# LANGUAGE DataKinds         #-}
{-# LANGUAGE OverloadedStrings #-}

module Main (main) where

import qualified PlutusTx.Prelude as P

main :: IO ()
main = do
    putStrLn "World"
    -- do some plutus calc to prove the modules are in scope.
    let x = 14 :: P.Integer
    print $ P.modulo x 10