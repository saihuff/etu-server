{-# LANGUAGE OverloadedStrings #-}
{-# LANGUAGE DeriveGeneric #-}
{-# LANGUAGE TypeFamilies #-}
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
import Database.PostgreSQL.Simple
import Database.PostgreSQL.Simple.ToField
import Data.Time.Clock

import Domain.Types
import qualified Domain.Types.Menu as DTM

fetchJSON :: FromJSON a => String -> IO a
fetchJSON url = do
  manager <- newManager tlsManagerSettings
  req     <- parseRequest url
  res     <- httpLbs req manager
  case eitherDecode (responseBody res) of
    Left err -> fail err
    Right v  -> pure v

saveMenuPayload :: Connection -> DTM.MenuPayload -> IO ()
saveMenuPayload conn req = do
    time <- getCurrentTime
    let q1 = "INSERT INTO menu_payloads (generated_at, menus, status, fetched_at, updated_at, source) VALUES (?, ?, ?, ?, ?, ?)"
    execute conn q1 (DTM.generated_at req, toJSONField (DTM.menus req), "ok" :: String, time, time, "matsumoto" :: String)
    return ()
