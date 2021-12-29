module IP where

import           Control.Applicative
import           Control.Monad
import           Data.Bits
import           Data.List
import qualified Data.Map            as M
import           Data.Word
import           Test.Hspec
import           Text.Trifecta
data IPAddress = IPAddress Word32 deriving (Eq, Ord)

instance Show IPAddress where
  show (IPAddress w) = intercalate "." $ show <$> [a,b,c,d]
    where
      a = w `shiftR` 24
      b = w `shiftR` 16 .&. (2^8 - 1)
      c = w `shiftR` 8  .&. (2^8 - 1)
      d = w `shiftL` 24

parseOctec :: Integral a => Parser a
parseOctec = do
  x <- natural
  guard $ x >= 0 && x < 256
  return $ fromInteger x

parseIpv4 :: Parser IPAddress
parseIpv4 = do
  a <- parseOctec
  _ <- char '.'
  b <- parseOctec
  _ <- char '.'
  c <- parseOctec
  _ <- char '.'
  d <- parseOctec
  return $ IPAddress (a*2^24 + b*2^16 + c*2^8 + d)

hexSymbols :: [Char]
hexSymbols = ['0'..'9']++['A'..'F']

hexMap :: Integral a => M.Map Char a
hexMap = M.fromList $ zip hexSymbols [0..]


data IPAddress6 = IPAddress6 Word64 Word64 deriving (Eq, Ord, Show)

parseHex :: Integral a => Parser a
parseHex = f <$> oneOf hexSymbols
  where
    f c = case M.lookup c hexMap of
            Just x  -> x
            Nothing -> error "Cannot parse"

sepOrEnd :: Parser ()
sepOrEnd = try (char ':' >> mempty) <|> notFollowedBy alphaNum

parseGroup :: Integral a => Parser a
parseGroup = do
  hexs <- try (some parseHex <* sepOrEnd) <|> (sepOrEnd >> pure [])
  return $ foldl (\b (val, exp) -> b + val * 16^exp) 0 (zip (reverse hexs) [0..])

parseWord64 :: Parser Word64
parseWord64 = do
  groups <- count 4 parseGroup
  return $ foldl (\b (val, exp) -> b + val * 16^(4*exp)) 0 (zip (reverse groups) [0..])

parseIpv6 :: Parser IPAddress6
parseIpv6 = liftA2 IPAddress6 parseWord64 parseWord64

-- Tests

t1 = "172.16.254.1"
e1 = IPAddress 2886794753

t2 = "204.120.0.15"
e2 = IPAddress 3430416399

t3 = "255.255.255.255"
e3 = IPAddress $ 2^32 - 1

t4 = "0.0.0.0"
e4 = IPAddress 0

t5 = "0000:0000:0000:0000:0000:0000:0000:0000"
e5 = IPAddress6 0 0

t6 = ":::::::"
e6 = IPAddress6 0 0

t7 = "0:0:0:0:0:0:0:0"
e7 = IPAddress6 0 0

t8 = "FFFF:FFFF:FFFF:FFFF:FFFF:FFFF:FFFF:FFFF"
e8 = IPAddress6 (2^64 - 1) (2^64 - 1)

t9 = "::::FFFF:FFFF:FFFF:FFFF"
e9 = IPAddress6 0 (2^64 - 1)

t10 = "FFFF:FFFF:FFFF:FFFF::::"
e10 = IPAddress6 (2^64 - 1) 0

parse p = parseString p mempty

main :: IO ()
main = hspec $ do
  describe "IPv4" $ do
    it ("should parse correctly " ++ t1) $ do
      case parse parseIpv4 t1 of
        Success x -> x `shouldBe` e1
        _         -> error "Parsing failed"
    it ("should parse correctly " ++ t2) $ do
      case parse parseIpv4 t2 of
        Success x -> x `shouldBe` e2
        _         -> error "Parsing failed"
    it ("should parse correctly " ++ t3) $ do
      case parse parseIpv4 t3 of
        Success x -> x `shouldBe` e3
        _         -> error "Parsing failed"
    it ("should parse correctly " ++ t4) $ do
      case parse parseIpv4 t4 of
        Success x -> x `shouldBe` e4
        _         -> error "Parsing failed"
  describe "IPv6" $ do
    it ("should parse correctly " ++ t5) $ do
      case parse parseIpv6 t5 of
        Success x -> x `shouldBe` e5
        _         -> error "Parsing failed"
    it ("should parse correctly " ++ t6) $ do
      case parse parseIpv6 t6 of
        Success x -> x `shouldBe` e6
        _         -> error "Parsing failed"
    it ("should parse correctly " ++ t7) $ do
      case parse parseIpv6 t7 of
        Success x -> x `shouldBe` e7
        _         -> error "Parsing failed"
    it ("should parse correctly " ++ t8) $ do
      case parse parseIpv6 t8 of
        Success x -> x `shouldBe` e8
        _         -> error "Parsing failed"
    it ("should parse correctly " ++ t9) $ do
      case parse parseIpv6 t9 of
        Success x -> x `shouldBe` e9
        _         -> error "Parsing failed"
    it ("should parse correctly " ++ t10) $ do
      case parse parseIpv6 t10 of
        Success x -> x `shouldBe` e10
        _         -> error "Parsing failed"
