-- | Settings are centralized, as much as possible, into this file. This
-- includes database connection settings, static file locations, etc.
-- In addition, you can configure a number of different aspects of Yesod
-- by overriding methods in the Yesod typeclass. That instance is
-- declared in the Difftimeline.hs file.
module Settings
    ( widgetFile
    , staticRoot
    , staticDir
    , Extra (..)
    , parseExtra
    ) where

import Prelude
import Language.Haskell.TH.Syntax
import Yesod.Default.Config
import qualified Yesod.Default.Util
import Data.Text (Text)
import Data.Yaml
import Control.Applicative

-- | The location of static files on your system. This is a file system
-- path. The default value works properly with your scaffolded site.
staticDir :: FilePath
staticDir = "static-content"

-- | The base URL for your static files. As you can see by the default
-- value, this can simply be "static" appended to your application root.
-- A powerful optimization can be serving static files from a separate
-- domain name. This allows you to use a web server optimized for static
-- files, more easily set expires and cache values, and avoid possibly
-- costly transference of cookies on static files. For more information,
-- please see:
--   http://code.google.com/speed/page-speed/docs/request.html#ServeFromCookielessDomain
--
-- If you change the resource pattern for StaticR in Difftimeline.hs, you will
-- have to make a corresponding change here.
--
-- To see how this value is used, see urlRenderOverride in Difftimeline.hs
staticRoot :: AppConfig DefaultEnv a ->  Text
staticRoot _conf = ("" :: Text)

widgetFile :: String -> Q Exp
#if DEVELOPMENT
widgetFile = Yesod.Default.Util.widgetFileReload
#else
widgetFile = Yesod.Default.Util.widgetFileNoReload
#endif

data Extra = Extra
    { extraCopyright :: Text
    , extraAnalytics :: Maybe Text -- ^ Google Analytics
    }

parseExtra :: DefaultEnv -> Object -> Parser Extra
parseExtra _ o = Extra
    <$> o .:  "copyright"
    <*> o .:? "analytics"

