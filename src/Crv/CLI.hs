{-# LANGUAGE ApplicativeDo #-}

module Crv.CLI
    ( VerifyMode (..)
    , shouldCheckLocal
    , shouldCheckExternal
    , Command (..)
    , Options (..)
    , getCommand
    ) where

import Data.Version (showVersion)
import Options.Applicative (Parser, ReadM, command, eitherReader, execParser, fullDesc, help,
                            helper, hsubparser, info, infoOption, long, metavar, option, progDesc,
                            short, strOption, switch, value)
import Paths_crossref_verifier (version)

import Crv.Core

modeReadM :: ReadM VerifyMode
modeReadM = eitherReader $ \s ->
    case find ((== s) . fst) modes of
        Just (_, mode) -> Right mode
        Nothing -> Left . mconcat $ intersperse "\n"
            [ "Unknown mode " <> show s <> "."
            , "Allowed values: " <> mconcat (intersperse ", " $ map (show . fst) modes)
            ]
  where
    modes =
        [ ("local-only", LocalOnlyMode)
        , ("external-only", ExternalOnlyMode)
        , ("full", FullMode)
        ]

data Command
  = DefaultCommand Options
  | DumpConfig FilePath

data Options = Options
    { oConfigPath      :: Maybe FilePath
    , oRoot            :: FilePath
    , oMode            :: VerifyMode
    , oVerbose         :: Bool
    , oShowProgressBar :: Bool
    }

optionsParser :: Parser Options
optionsParser = do
    oConfigPath <- optional . strOption $
        short 'c' <>
        long "config" <>
        metavar "FILEPATH" <>
        help "Path to configuration file."
    oRoot <- strOption $
        short 'r' <>
        long "root" <>
        metavar "DIRECTORY" <>
        help "Path to repository root." <>
        value "."
    oMode <- option modeReadM $
        short 'm' <>
        long "mode" <>
        metavar "KEYWORD" <>
        value LocalOnlyMode <>
        help "Which parts of verification to invoke. \
             \You can enable only verification of repository-local references, \
             \only verification of external references or both. \
             \Default value: local-only."
    oVerbose <- switch $
        short 'v' <>
        long "verbose" <>
        help "Report repository scan and verification details."
    oShowProgressBar <- fmap not . switch $
        long "no-progress" <>
        help "Do not display progress bar during verification."
    return Options{..}

dumpConfigOptions :: Parser FilePath
dumpConfigOptions = hsubparser $
  command "dump-config" $
    info parser $
    progDesc "Dump default configuration into a file."
  where
    parser = strOption $
      short 'o' <>
      long "output" <>
      metavar "FILEPATH" <>
      value ".crossref-verifier.yaml" <>
      help "Name of created config file."

totalParser :: Parser Command
totalParser = asum
  [ DefaultCommand <$> optionsParser
  , DumpConfig <$> dumpConfigOptions
  ]

versionOption :: Parser (a -> a)
versionOption = infoOption ("crossref-verify-" <> (showVersion version)) $
    long "version" <>
    help "Show version."

getCommand :: IO Command
getCommand = do
    execParser $
        info (helper <*> versionOption <*> totalParser) $
        fullDesc <>
        progDesc "Cross-references verifier for markdown documentation in \
                 \Git repositories."
