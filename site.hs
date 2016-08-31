{-# LANGUAGE OverloadedStrings #-}

{-

Build script for francois le grand using Hakyll 4.4

Based on Jasper Van der Jeugt's blog <http://jaspervdj.be>, with
minor alterations.

-}

module Main where


--------------------------------------------------------------------------------
import           Control.Applicative ((<$>))
import           Data.Monoid         ((<>), mconcat)
import           Prelude             hiding (id)
import qualified Data.Map            as M
import qualified Text.Pandoc         as Pandoc


--------------------------------------------------------------------------------
import           Hakyll


--------------------------------------------------------------------------------
-- | Entry point
main :: IO ()
main = hakyll $ do
    -- Static files
    match ("images/*" .||. "robots.txt") $ do
        route   idRoute
        compile copyFileCompiler

    match ("docs/td-macros/*tex" .||. "docs/td-macros/*pdf") $ do
        route idRoute
        compile copyFileCompiler
        
    match ("docs/*pdf" .||. "docs/*/*pdf") $ do
        route idRoute
        compile copyFileCompiler

    -- Compress CSS
    match "css/*" $ do
        route idRoute
        compile compressCssCompiler

    -- Copy JS
    match "js/*" $ do
        route idRoute
        compile copyFileCompiler

    -- Copy Fonts
    match "fonts/*" $ do
        route idRoute
        compile copyFileCompiler

    -- Build tags
    -- ~ tags <- buildTags "posts/*" (fromCapture "tags/*.html")

    -- Render each and every post
    -- ~ match "posts/*" $ do
        -- ~ route   $ setExtension ".html"
        -- ~ compile $ do
            -- ~ pandocCompiler
                -- ~ >>= saveSnapshot "content"
                -- ~ >>= loadAndApplyTemplate "templates/post.html" (postCtx tags)
                -- ~ >>= loadAndApplyTemplate "templates/default.html" defaultContext
                -- ~ >>= relativizeUrls
-- ~
    -- ~ -- Post list
    -- ~ create ["posts.html"] $ do
        -- ~ route idRoute
        -- ~ compile $ do
            -- ~ posts <- recentFirst =<< loadAll "posts/*"
            -- ~ let ctx = constField "title" "Posts" <>
                        -- ~ listField "posts" (postCtx tags) (return posts) <>
                        -- ~ defaultContext
            -- ~ makeItem ""
                -- ~ >>= loadAndApplyTemplate "templates/posts.html" ctx
                -- ~ >>= loadAndApplyTemplate "templates/default.html" ctx
                -- ~ >>= relativizeUrls
-- ~
    -- ~ -- Post tags
    -- ~ tagsRules tags $ \tag pattern -> do
        -- ~ let title = "Posts tagged " ++ tag
-- ~
        -- ~ -- Copied from posts, need to refactor
        -- ~ route idRoute
        -- ~ compile $ do
            -- ~ posts <- recentFirst =<< loadAll pattern
            -- ~ let ctx = constField "title" title <>
                        -- ~ listField "posts" (postCtx tags) (return posts) <>
                        -- ~ defaultContext
            -- ~ makeItem ""
                -- ~ >>= loadAndApplyTemplate "templates/posts.html" ctx
                -- ~ >>= loadAndApplyTemplate "templates/default.html" ctx
                -- ~ >>= relativizeUrls

    -- ~ -- Index
    -- ~ match "index.html" $ do
        -- ~ route idRoute
        -- ~ compile $ do
            -- ~ posts <- fmap (take 10) . recentFirst =<< loadAll "posts/*"
            -- ~ let indexContext =
                    -- ~ listField "posts" (postCtx tags) (return posts) <>
                    -- ~ field "tags" (\_ -> renderTagList tags) <>
                    -- ~ defaultContext
-- ~
            -- ~ getResourceBody
                -- ~ >>= applyAsTemplate indexContext
                -- ~ >>= loadAndApplyTemplate "templates/default.html" indexContext
                -- ~ >>= relativizeUrls

    -- Read templates
    match "templates/*" $ compile $ templateCompiler

    -- Render some static pages
    match (fromList ["index.markdown"]) $ do
        route   $ setExtension ".html"
        compile $ pandocCompiler
            >>= loadAndApplyTemplate "templates/home.html" defaultContext
            >>= relativizeUrls

    match (fromList ["cv.markdown", "research.markdown"]) $ do
        route   $ setExtension ".html"
        compile $ 
            pandocCompiler
            >>= applyFilter postFilters
            >>= loadAndApplyTemplate "templates/default.html" defaultContext
            >>= relativizeUrls       

    match (fromList ["teaching.markdown", "misc.markdown"]) $ do
        -- ~ route   $ setExtension ".htm"
        -- ~ compile $ 
            -- ~ pandocCompiler
            -- ~ >>= saveSnapshot "content"
            -- ~ >>= loadAndApplyTemplate "templates/default.html" defaultContext
            -- ~ >>= relativizeUrls
        route   $ setExtension ".html"
        compile $ 
            pandocCompiler
            >>= saveSnapshot "content"
            >>= loadAndApplyTemplate "templates/defaultteaser.html" (teaserField "teaser" "content" <> defaultContext)
            >>= relativizeUrls

    -- Render the 404 page, we don't relativize URLs here.
    match "404.html" $ do
        route idRoute
        compile $ pandocCompiler            
            >>= loadAndApplyTemplate "templates/default.html" defaultContext

    -- ~ -- Render RSS feed
    -- ~ create ["rss.xml"] $ do
        -- ~ route idRoute
        -- ~ compile $ do
            -- ~ loadAllSnapshots "posts/*" "content"
                -- ~ >>= fmap (take 10) . recentFirst
                -- ~ >>= renderAtom feedConfiguration feedCtx

    

-- ~ --------------------------------------------------------------------------------
-- ~ postCtx :: Tags -> Context String
-- ~ postCtx tags = mconcat
    -- ~ [ dateField "date" "%B %e, %Y"
    -- ~ , tagsField "tags" tags
    -- ~ , defaultContext
    -- ~ ]
-- ~ 
-- ~ 
-- ~ --------------------------------------------------------------------------------
-- ~ feedCtx :: Context String
-- ~ feedCtx = mconcat
    -- ~ [ bodyField "description"
    -- ~ , defaultContext
    -- ~ ]




applyFilter strfilter str = return $ (fmap $ strfilter) str
preFilters :: String -> String
preFilters = undefined
postFilters :: String -> String
postFilters = replaceAll "<p>%p[a-zA-Z0-9-]*%" newnaming
  where
    newnaming matched = case M.lookup (drop 4 matched) abbrevP of
                          Nothing -> (drop 4 matched)
                          Just v -> v
abbrevP :: M.Map String String
abbrevP = M.fromList
    [ ("pclass-no-bottom-space%", "<p class=\"no-bottom-space\">")
    , ("pclass-no-top-space%", "<p class=\"no-top-space\">")
    , ("pclass-no-top-space-indent%", "<p class=\"no-top-space indent\">")]
