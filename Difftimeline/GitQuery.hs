module Difftimeline.GitQuery where

import Control.Applicative
import Control.Monad.IO.Class( liftIO )
import Control.Monad.Trans.Maybe( MaybeT, runMaybeT  )

import qualified Data.ByteString as B
import Data.List( find )
import Data.Maybe( fromJust )
import qualified Data.Text as T
import Data.Text.Encoding( decodeUtf8 )

import Data.Git.Repository( Git, findObject )
import Data.Git.Object( GitObject(..), CommitInfo( .. ) )
import Data.Git.Ref( Ref, fromHexString )

import Difftimeline.Diff

data CommitPath = CommitPath
    { pathCommitRef     :: Ref
    , pathParentRef     :: Ref
    , pathMessage       :: T.Text
    }

maybeIO :: IO (Maybe a) -> MaybeT IO a
maybeIO a = do
    mayrez <- liftIO a
    case mayrez of
        Nothing -> fail undefined
        Just j  -> return j


findFirstCommit :: Git              -- ^ Repository
                -> [B.ByteString]   -- ^ Path
                -> Ref              -- ^ Ref of the element in the path
                -> Ref              -- ^ First commit ref
                -> IO (CommitInfo, [CommitPath])
findFirstCommit repository path currentFileRef firstCommit =
  fromJust <$> (runMaybeT $ inner undefined firstCommit)
    where getObj = maybeIO . accessObject repository
  
          inner prevCommit currentCommit = do
            (Commit info) <- getObj currentCommit
            t@(Tree _)    <- getObj $ commitTreeish info
            commitFileRef <- maybeIO $ findInTree repository path t
       
            if commitFileRef /= currentFileRef
               then return (prevCommit, [])
               else do
               	(obj, commitPathRest) <- inner info $ commitParents info !! 0
               	return (obj, CommitPath {
                        pathCommitRef = currentCommit,
                        pathParentRef = (commitParents info) !! 0,
                        pathMessage = decodeUtf8 $ commitMessage info
                    } : commitPathRest)
      
accessObject :: Git -> Ref -> IO (Maybe GitObject)
accessObject g r = findObject g r True

-- | Given a Tree object, try to find a path in it.
-- This function should not call error
findInTree :: Git -> [B.ByteString] -> GitObject -> IO (Maybe Ref)
findInTree git pathes = inner pathes . Just
    where inner _                Nothing = return Nothing
          inner []                     _ = return Nothing
          inner [lp]   (Just (Tree lst)) = return $ findVal lp lst
          inner (x:xs) (Just (Tree lst)) = case findVal x lst of
                    Nothing -> return Nothing
                    Just r  -> accessObject git r >>= inner xs
          inner _ _                      = return Nothing

          extractRef (_, _, ref) = ref
          findVal v lst = extractRef <$> find (\(_, n, _) -> v == n) lst

{-findParentFile :: Git -> String -> String -> FilePath -> IO [Int]-}
{-findParentFile repository lastFileStrSha commitStrSha path = inner-}
  {-where prevFileSha = fromHexString lastFileStrSha-}
        {-prevCommit = fromHexString commitStrSha-}

        {-inner = do -}
            {-commit <- accessObject repository prevCommit-}


data ParentFile = ParentFile
    { fileData    :: T.Text
    , fileRef     :: Ref
    , parentRef   :: Ref
    , fileMessage :: T.Text
    , commitRef   :: Ref
    , commitPath  :: [CommitPath]
    , fileDiff    :: [DiffCommand]
    }
