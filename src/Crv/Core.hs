-- | Various primitives.

module Crv.Core where

import Control.DeepSeq (NFData)
import Control.Lens (makeLenses, (%=))
import Data.Char (isAlphaNum)
import Data.Default (Default (..))
import qualified Data.List as L
import qualified Data.Map as M
import qualified Data.Text as T
import Fmt (Buildable (..), blockListF, blockListF', nameF, (+|), (|+))
import System.Console.Pretty (Color (..), Style (..), color, style)
import Text.Numeral.Roman (toRoman)

import Crv.Progress
import Crv.Util

-----------------------------------------------------------
-- Types
-----------------------------------------------------------

-- | Full info about a reference.
data Reference = Reference
    { rName   :: Text
      -- ^ Text displayed as reference.
    , rLink   :: Text
      -- ^ File or site reference points to.
    , rAnchor :: Maybe Text
      -- ^ Section or custom anchor tag.
    } deriving (Show, Generic)

-- | Context of anchor.
data AnchorType
    = HeaderAnchor Int
      -- ^ Every section header is usually an anchor
    | HandAnchor
      -- ^ They can be set up manually
    | BiblioAnchor
      -- ^ Id of entry in bibliography
    deriving (Show, Eq, Generic)

-- | A referable anchor.
data Anchor = Anchor
    { aType :: AnchorType
    , aName :: Text
    } deriving (Show, Generic)

-- | All information regarding a single file we care about.
data FileInfo = FileInfo
    { _fiReferences :: [Reference]
    , _fiAnchors    :: [Anchor]
    } deriving (Show, Generic)
makeLenses ''FileInfo

instance Default FileInfo where
    def = FileInfo [] []

newtype RepoInfo = RepoInfo (Map FilePath FileInfo)
    deriving (Show)

finaliseFileInfo :: FileInfo -> FileInfo
finaliseFileInfo = execState $ do
    fiReferences %= reverse
    fiAnchors %= reverse

-----------------------------------------------------------
-- Instances
-----------------------------------------------------------

instance NFData Reference
instance NFData AnchorType
instance NFData Anchor
instance NFData FileInfo

instance Buildable Reference where
    build Reference{..} = nameF ("reference " +| paren (build loc)) $
        blockListF
        [ "text: " <> show rName
        , "link: " <> rLink
        , "anchor: " <> (rAnchor ?: style Faint "-")
        ]
      where
        loc = locationType rLink

instance Buildable AnchorType where
    build = style Faint . \case
        HeaderAnchor l -> color Green ("header " <> toRoman l)
        HandAnchor -> color Yellow "hand made"
        BiblioAnchor -> color Cyan "biblio"

instance Buildable Anchor where
    build (Anchor t a) = a |+ " (" +| t |+ ")"

instance Buildable FileInfo where
    build FileInfo{..} =
        blockListF
        [ nameF "references" $ blockListF _fiReferences
        , nameF "anchors" $ blockListF _fiAnchors
        ]

instance Buildable RepoInfo where
    build (RepoInfo m) =
        blockListF' "⮚" buildFileReport (M.toList m)
      where
        buildFileReport (name, info) = mconcat
            [ color Cyan $ fromString name <> ":\n"
            , build info
            , "\n"
            ]

-----------------------------------------------------------
-- Analysing
-----------------------------------------------------------

-- | Type of reference.
data LocationType
    = LocalLoc
      -- ^ Reference on this file
    | RelativeLoc
      -- ^ Reference to a file relative to given one
    | AbsoluteLoc
      -- ^ Reference to a file relative to the root
    | ExternalLoc
      -- ^ Reference to a file at outer site
    | OtherLoc
      -- ^ Entry not to be processed (e.g. "mailto:e-mail")
    deriving (Show)

instance Buildable LocationType where
    build = \case
        LocalLoc -> color Green "local"
        RelativeLoc -> color Yellow "relative"
        AbsoluteLoc -> color Blue "absolute"
        ExternalLoc -> color Red "external"
        OtherLoc -> ""

-- | Whether this is a link to external resource.
isExternal :: LocationType -> Bool
isExternal = \case
    ExternalLoc -> True
    _ -> False

-- | Whether this is a link to repo-local resource.
isLocal :: LocationType -> Bool
isLocal = \case
    LocalLoc -> True
    RelativeLoc -> True
    AbsoluteLoc -> True
    ExternalLoc -> False
    OtherLoc -> False

-- | Get type of reference.
locationType :: Text -> LocationType
locationType location = case toString location of
    []                  -> LocalLoc
    '/' : _             -> AbsoluteLoc
    '.' : '/' : _       -> RelativeLoc
    '.' : '.' : '/' : _ -> RelativeLoc
    _ | hasUrlProtocol  -> ExternalLoc
      | hasProtocol     -> OtherLoc
      | otherwise       -> RelativeLoc
  where
    hasUrlProtocol = "://" `T.isInfixOf` (T.take 10 location)
    hasProtocol = ":" `T.isInfixOf` (T.take 10 location)

-- | Which parts of verification do we perform.
data VerifyMode
    = LocalOnlyMode
    | ExternalOnlyMode
    | FullMode

shouldCheckLocal :: VerifyMode -> Bool
shouldCheckLocal = \case
    LocalOnlyMode -> True
    ExternalOnlyMode -> False
    FullMode -> True

shouldCheckExternal :: VerifyMode -> Bool
shouldCheckExternal = \case
    LocalOnlyMode -> False
    ExternalOnlyMode -> True
    FullMode -> True

-- | Convert section header name to an anchor refering it.
-- Conversion rules: https://docs.gitlab.com/ee/user/markdown.html#header-ids-and-links
headerToAnchor :: Text -> Text
headerToAnchor =
    T.filter (\c -> isAlphaNum c || c == '-') .
    T.replace " " "-" .
    T.replace "+" "-" .
    T.toLower

-----------------------------------------------------------
-- Visualisation
-----------------------------------------------------------

data VerifyProgress = VerifyProgress
    { vrLocal    :: !(Progress Int)
    , vrExternal :: !(Progress Int)
    } deriving (Show)

initVerifyProgress :: RepoInfo -> VerifyProgress
initVerifyProgress (RepoInfo info) =
    VerifyProgress
    { vrLocal = initProgress (length localRefs)
    , vrExternal = initProgress (length extRefs)
    }
  where
    (extRefs, localRefs) =
        L.partition isExternal $
        map locationType . map rLink . foldMap (_fiReferences) $ toList info

showAnalyseProgress :: VerifyMode -> VerifyProgress -> Text
showAnalyseProgress mode VerifyProgress{..} = mconcat . mconcat $
    [ [ "Verifying " ]
    , [ showProgress "local" 10 White vrLocal <> " "
      | shouldCheckLocal mode ]
    , [ showProgress "external" 15 Yellow vrExternal
      | shouldCheckExternal mode ]
    ]

reprintAnalyseProgress :: Rewrite -> VerifyMode -> VerifyProgress -> IO ()
reprintAnalyseProgress rw mode p = putTextRewrite rw (showAnalyseProgress mode p)
