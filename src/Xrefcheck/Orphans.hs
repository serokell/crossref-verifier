{- SPDX-FileCopyrightText: 2021 Serokell <https://serokell.io>
 -
 - SPDX-License-Identifier: MPL-2.0
 -}

{-# OPTIONS_GHC -fno-warn-orphans #-}

-- | Orphan instances for types from other packages

module Xrefcheck.Orphans () where

import qualified Data.ByteString as BS

import Fmt (Buildable (..), (+|), (|+))
import Network.FTP.Client
  (FTPException (..), FTPMessage (..), FTPResponse (..), ResponseStatus (..))

instance Buildable ResponseStatus where
  build = show

instance Buildable FTPMessage where
  build message = build $ decodeUtf8 @Text (
    case message of
      SingleLine s -> s
      MultiLine ss -> BS.concat ss
    )

instance Buildable FTPResponse where
  build FTPResponse{..} =  frStatus |+ " (" +| frCode |+ ") " +| frMessage |+ ""

instance Buildable FTPException where
  build (BadProtocolResponseException _) = "Raw FTP exception"
  build (FailureRetryException e) = build e
  build (FailureException e) = build e
  build (UnsuccessfulException e) = build e
  build (BogusResponseFormatException e) = build e

