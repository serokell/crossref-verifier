-- SPDX-FileCopyrightText: 2021 Serokell <https://serokell.io>
--
-- SPDX-License-Identifier: MPL-2.0

{-# OPTIONS_GHC -fno-warn-orphans #-}

-- | Orphan instances for types from other packages needed only in tests.

module Test.Orphans () where

import Network.FTP.Client (FTPException (..))
import Xrefcheck.Core (Anchor (Anchor), Position (Position))
import Xrefcheck.Verify (VerifyError (..))

deriving instance Eq VerifyError
deriving instance Eq FTPException
deriving instance Eq Anchor
deriving instance Eq Position
