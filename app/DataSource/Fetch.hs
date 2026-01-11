
module DataSource.Fetch where

import Web.Spock
import Web.Spock.Config

import GHC.Generics
import Data.Aeson
import Control.Monad.Trans
import Data.Monoid
import Data.IORef
import qualified Data.Text as T
import qualified Data.Text.Encoding as TE
import qualified Data.ByteString.Lazy as BLS
import Network.HTTP.Client
import Network.HTTP.Client.TLS (tlsManagerSettings)

import Domain.Types

fetchJSON :: FromJSON a => String -> IO a
fetchJSON url = do
  manager <- newManager tlsManagerSettings
  req     <- parseRequest url
  res     <- httpLbs req manager
  case eitherDecode (responseBody res) of
    Left err -> fail err
    Right v  -> pure v
