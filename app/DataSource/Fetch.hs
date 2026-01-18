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
import Database.PostgreSQL.Simple.FromField
import Data.Time.Clock
import Control.Concurrent (forkIO, threadDelay)

import Domain.Types
import qualified Domain.Types.Menu as DTM
import qualified Domain.Types.TimeTable as DTTT
import qualified Domain.Types.Train as DTT
import Config

data Table = MENU_PAYLOAD | TIMETABLE_PAYLOAD | TRAIN_PAYLOAD
    deriving (Eq, Show)



oneMinute :: Int
oneMinute = 60 * 1000 * 1000  -- microseconds

startPolling :: Connection -> IO ()
startPolling conn = do
  _ <- forkIO loop
  pure ()
  where
    loop = do
      res1 <- fetchJSON ohara
      saveTimeTablePayLoad conn res1
      threadDelay oneMinute
      loop


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
    let q = "INSERT INTO menu_payloads (generated_at, menus, status, fetched_at, updated_at, source) VALUES (?, ?, ?, ?, ?, ?)"
    execute conn q (DTM.generated_at req, toJSONField (DTM.menus req), "ok" :: String, time, time, "matsumoto" :: String)
    return ()

saveTimeTablePayLoad :: Connection -> DTTT.TimeTables -> IO ()
saveTimeTablePayLoad conn req = do
    time <- getCurrentTime
    let q = "INSERT INTO timetable_payloads (generated_at, main_timetable, status, fetched_at, updated_at, source) VALUES (?, ?, ?, ?, ?, ?)"
    execute conn q (DTTT.generated_at req, toJSONField (DTTT.main_timetable req), "ok" :: String, time, time, "ohara" :: String)
    return ()

saveTrainPayLoad :: Connection -> DTT.Train -> IO ()
saveTrainPayLoad conn req = do
    time <- getCurrentTime
    let q = "INSERT INTO train_payloads (generated_at, destination, status, fetched_at, updated_at, source) VALUES (?, ?, ?, ?, ?, ?)"
    execute conn q (DTT.generated_at req, toJSON (DTT.destination req), "ok" :: String, time, time, "dammy" :: String)
    return ()

latestRecordFromMenuPayload :: Connection -> IO DTM.MenuPayload
latestRecordFromMenuPayload conn = do
    time <- getCurrentTime
    let q1 = "select max(updated_at) from menu_payloads"
        q2 = "select * from menu_payloads where (updated_at = ?);"
    latestTime <- Prelude.head <$> (query conn q1 () :: IO [Only UTCTime])
    (id, generatedat, DTM.MenusJSON menus', status, fetchedat, updatedat, source) <- Prelude.head <$> (query conn q2 latestTime :: IO [DTM.MenuPair])
    return $ DTM.MenuPayload { DTM.generated_at = generatedat, DTM.menus = menus' }

latestRecordFromTimeTablePayload :: Connection -> IO DTTT.TimeTables
latestRecordFromTimeTablePayload conn = do
    time <- getCurrentTime
    let q1 = "select max(updated_at) from timetable_payloads"
        q2 = "select * from timetable_payloads where (updated_at = ?);"
    latestTime <- Prelude.head <$> (query conn q1 () :: IO [Only UTCTime])
    (id, generatedat, DTTT.TimeTableJSON timetables, status, fetchedat, updatedat, source) <- Prelude.head <$> (query conn q2 latestTime :: IO [DTTT.TimeTablePair])
    return $ DTTT.TimeTables { DTTT.generated_at = generatedat, DTTT.main_timetable = timetables }

latestRecordFromTrainPayload :: Connection -> IO DTT.Train
latestRecordFromTrainPayload conn = do
    time <- getCurrentTime
    let q1 = "select max(updated_at) from train_payloads"
        q2 = "select * from train_payloads where (updated_at = ?);"
    latestTime <- Prelude.head <$> (query conn q1 () :: IO [Only UTCTime])
    (id, generatedat, DTT.TrainJSON traindata, status, fetchedat, updatedat, source) <- Prelude.head <$> (query conn q2 latestTime :: IO [DTT.TrainPair])
    return $ DTT.Train { DTT.generated_at = generatedat, DTT.destination = traindata}
