{-# LANGUAGE DeriveAnyClass #-}
{-# LANGUAGE DeriveGeneric #-}
{-# LANGUAGE DuplicateRecordFields #-}
{-# LANGUAGE NamedFieldPuns #-}
{-# LANGUAGE OverloadedStrings #-}

module Main where

import Control.Lens
import Control.Monad
import Data.Aeson as A
import qualified Data.Aeson.KeyMap as KM
import Data.Aeson.Lens
import Data.Function (on)
import Data.List (isPrefixOf, sortBy)
import qualified Data.Map as M
import qualified Data.Set as S
import qualified Data.Text as T
import Data.Time
import qualified Debug.Trace as D
import Development.Shake
import Development.Shake.Classes
import Development.Shake.FilePath
import Development.Shake.Forward
import GHC.Generics (Generic)
import Slick

---Config-----------------------------------------------------------------------

siteMeta :: SiteMeta
siteMeta =
    SiteMeta
        { siteAuthor = "Evie Ciobanu"
        , baseUrl = "https://eevie.ro"
        , siteTitle = "Evie's Blog"
        , twitterHandle = Just "evie_fp"
        , githubUser = Just "eviefp"
        , twitchUser = Just "eviefp"
        }

outputFolder :: FilePath
outputFolder = "docs/"

-- Data models-------------------------------------------------------------------

withSiteMeta :: Value -> Value
withSiteMeta (Object obj) = Object $ KM.union obj siteMetaObj
  where
    Object siteMetaObj = toJSON siteMeta
withSiteMeta _ = error "only add site meta to objects"

data SiteMeta = SiteMeta
    { siteAuthor :: String
    , baseUrl :: String -- e.g. https://example.ca
    , siteTitle :: String
    , twitterHandle :: Maybe String -- Without @
    , githubUser :: Maybe String
    , twitchUser :: Maybe String
    }
    deriving (Generic, Eq, Ord, Show, ToJSON)

-- | Data for the index page
newtype IndexInfo = IndexInfo
    { posts :: [Post]
    }
    deriving (Generic, Show, FromJSON, ToJSON)

data Tag = Tag
    { tag :: String
    , posts :: [Post]
    , url :: String
    }
    deriving (Generic, Show, ToJSON)

-- | Data for a blog post
data Post = Post
    { title :: String
    , author :: String
    , content :: String
    , url :: String
    , date :: String
    , tags :: [String]
    , description :: String
    , image :: Maybe String
    }
    deriving (Generic, Eq, Ord, Show, FromJSON, ToJSON, Binary)

data AtomData = AtomData
    { title :: String
    , domain :: String
    , author :: String
    , posts :: [Post]
    , currentTime :: String
    , atomUrl :: String
    }
    deriving (Generic, ToJSON, Eq, Ord, Show)

buildTags :: [Tag] -> Action ()
buildTags t = void $ forP t writeTag

writeTag :: Tag -> Action ()
writeTag t@Tag{url} = do
    tagTempl <- compileTemplate' "site/templates/tag.html"
    writeFile' (outputFolder <> url -<.> "html") . T.unpack $ substitute tagTempl (toJSON t)

getTags :: [Post] -> Action [Tag]
getTags posts = do
    let tagToPostsSet = M.unionsWith mappend (toMap <$> posts)
        tagToPostsList = fmap S.toList tagToPostsSet
        tagObjects =
            M.foldMapWithKey
                (\tag ps -> [Tag{tag, posts = reverse $ sortByDate ps, url = "/tag/" <> tag}])
                tagToPostsList
    return tagObjects
  where
    toMap :: Post -> M.Map String (S.Set Post)
    toMap p@Post{tags} = M.unionsWith mappend (embed p <$> tags)

    embed :: Post -> String -> M.Map String (S.Set Post)
    embed post tag = M.singleton tag (S.singleton post)

sortByDate :: [Post] -> [Post]
sortByDate = sortBy compareDates
  where
    compareDates = compare `on` (formatDate . date)

-- | given a list of posts this will build a table of contents
buildIndex :: [Post] -> Action ()
buildIndex posts' = do
    indexT <- compileTemplate' "site/templates/index.html"
    let indexInfo = IndexInfo{posts = reverse posts'}
        indexHTML = T.unpack $ substitute indexT (withSiteMeta $ toJSON indexInfo)
    writeFile' (outputFolder </> "index.html") indexHTML

-- | Find and build all posts
buildPosts :: Action [Post]
buildPosts = do
    pPaths <- getDirectoryFiles "." ["site/posts//*.md"]
    let exceptInProgress = filter (not . isPrefixOf "site/posts/_") pPaths
    D.traceShowM exceptInProgress
    forP exceptInProgress buildPost

{- | Load a post, process metadata, write it to output, then return the post object
Detects changes to either post content or template
-}
buildPost :: FilePath -> Action Post
buildPost srcPath = cacheAction ("build" :: T.Text, srcPath) $ do
    liftIO . putStrLn $ "Rebuilding post: " <> srcPath
    postContent <- readFile' srcPath
    -- load post content and metadata as JSON blob
    postData <- markdownToHTML . T.pack $ postContent
    let postUrl = T.pack . dropDirectory1 $ srcPath -<.> "html"
        withPostUrl = _Object . at "url" ?~ String postUrl
    -- Add additional metadata we've been able to compute
    let fullPostData = withSiteMeta . withPostUrl $ postData
    template <- compileTemplate' "site/templates/post.html"
    writeFile' (outputFolder </> T.unpack postUrl) . T.unpack $ substitute template fullPostData
    convert fullPostData

buildPages :: Action [Post]
buildPages = do
    pPaths <- getDirectoryFiles "." ["site/pages//*.md"]
    let exceptInProgress = filter (not . isPrefixOf "site/pages/_") pPaths
    D.traceShowM exceptInProgress
    forP exceptInProgress buildPage

buildPage :: FilePath -> Action Post
buildPage srcPath = cacheAction ("build" :: T.Text, srcPath) $ do
    liftIO . putStrLn $ "Rebuilding page: " <> srcPath
    postContent <- readFile' srcPath
    -- load post content and metadata as JSON blob
    postData <- markdownToHTML . T.pack $ postContent
    let postUrl = T.pack . dropDirectory1 $ srcPath -<.> "html"
        withPostUrl = _Object . at "url" ?~ String postUrl
    -- Add additional metadata we've been able to compute
    let fullPostData = withSiteMeta . withPostUrl $ postData
    template <- compileTemplate' "site/templates/page.html"
    writeFile' (outputFolder </> T.unpack postUrl) . T.unpack $ substitute template fullPostData
    convert fullPostData

-- | Copy all static files from the listed folders to their destination
copyStaticFiles :: Action ()
copyStaticFiles = do
    filepaths <- getDirectoryFiles "./site/" ["images//*", "css//*", "js//*", "content//*"]
    void $
        forP filepaths $ \filepath ->
            copyFileChanged ("site" </> filepath) (outputFolder </> filepath)

formatDate :: String -> String
formatDate humanDate = toIsoDate parsedTime
  where
    parsedTime =
        parseTimeOrError True defaultTimeLocale "%b %e, %Y" humanDate :: UTCTime

rfc3339 :: Maybe String
rfc3339 = Just "%H:%M:SZ"

toIsoDate :: UTCTime -> String
toIsoDate = formatTime defaultTimeLocale (iso8601DateFormat rfc3339)

buildFeed :: [Post] -> Action ()
buildFeed posts = do
    now <- liftIO getCurrentTime
    let atomData =
            AtomData
                { title = siteTitle siteMeta
                , domain = baseUrl siteMeta
                , author = siteAuthor siteMeta
                , posts = mkAtomPost <$> posts
                , currentTime = toIsoDate now
                , atomUrl = "/atom.xml"
                }
    atomTempl <- compileTemplate' "site/templates/atom.xml"
    writeFile' (outputFolder </> "atom.xml") . T.unpack $ substitute atomTempl (toJSON atomData)
  where
    mkAtomPost :: Post -> Post
    mkAtomPost p = p{date = formatDate $ date p}

{- | Specific build rules for the Shake system
  defines workflow to build the website
-}
buildRules :: Action ()
buildRules = do
    allPosts <- sortByDate <$> buildPosts
    allTags <- getTags allPosts
    buildTags allTags
    buildIndex allPosts
    buildFeed allPosts
    _ <- buildPages
    copyStaticFiles

main :: IO ()
main = do
    let shOpts = shakeOptions{shakeVerbosity = Chatty, shakeLintInside = ["\\"]}
    shakeArgsForward shOpts buildRules
