module Params where
import           Data.Text           (Text, strip)
import           Options.Applicative

data Params = Params {
    fname    :: FilePath
  , company  :: Maybe Text
  , chart    :: Bool
  , htmlFile :: Maybe FilePath
  , silent   :: Bool
  }

mkParams :: Parser Params
mkParams = Params
           <$> strArgument (metavar "FILE" <> help "CSV file name")
           <*> optional (strip <$> strOption (long "name" <> short 'n' <> help "companan name"))
           <*> switch (long "chart" <> short 'c' <> help "generate chart")
           <*> optional (strOption $ long "html" <> metavar "FILE" <> help "generate HTML report")
           <*> switch (long "silent" <> short 's' <> help "don't print statistics")

cmdLineParser :: IO Params
cmdLineParser = execParser opts
  where
    opts = info (mkParams <**> helper)
                (fullDesc <> progDesc "Stock quotes data processing")
