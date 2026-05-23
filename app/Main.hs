{-# LANGUAGE OverloadedStrings #-}
{-# LANGUAGE DeriveGeneric #-}
module Main (main) where

import Web.Spock
import Web.Spock.Config

import GHC.Generics
import Data.Aeson (FromJSON)
import Control.Monad.Trans
import Data.Monoid
import Data.IORef
import qualified Data.Text as T
import qualified Data.Text.Encoding as TE
import Database.PostgreSQL.Simple
import Data.Maybe
import System.Environment (lookupEnv)

import Domain.Types
import qualified Domain.Types.Menu as DTM
import qualified Domain.Types.TimeTable as DTTT
import qualified Domain.Types.Train as DTT
import Domain.Transform
import DataSource.Fetch
import Data.Time (getCurrentTime)
import DataSource.Fetch (latestRecordFromMenuPayload)

data PortsInfo = PortsInfo {ohara :: Int, matsumoto :: Int, nakada :: Int}

data MySession = EmptySession
data MyAppState = DummyAppState (IORef Int)

data AppState = AppState {dbConn :: Connection, extInfo :: PortsInfo}

main :: IO ()
main =
    do ref <- newIORef 0
       connInfo <- getConnInfo
       extInfo' <- getExtInfo
       conn <- connect connInfo
       let appState = AppState {dbConn = conn, extInfo = extInfo'}
       startPolling conn
       spockCfg <- defaultSpockCfg EmptySession PCNoDatabase appState
       runSpock 8080 (spock spockCfg app)

app :: SpockM () MySession AppState ()
app =
    do get root $ text "Hello World!"
       post "test" $ do
           mreq <- jsonBody'
           liftIO . print $ (mreq :: LoginReq)
           text "ok"
       get ("api" <//> "v1" <//> "board") $ do
           state <- getState
           tt <- liftIO $ latestRecordFromTimeTablePayload (dbConn state)
           mn <- liftIO $ latestRecordFromMenuPayload (dbConn state)
           tn <- liftIO $ latestRecordFromTrainPayload (dbConn state)
           time <- liftIO $ getCurrentTime
           json $ mergeData time mn tt tn
       post ("api" <//> "v1" <//> "cafe") $ do
           jsonreq <- jsonBody'
           state <- getState
           liftIO $ saveMenuPayload (dbConn state) jsonreq
           text "ok"
       get ("test" <//> "timetable") $ do
           state <- getState
           liftIO $ saveTimeTablePayLoad (dbConn state) dammytime
       get ("test" <//> "timetabletest") $ do
           state <- getState
           tt <- liftIO $ latestRecordFromTimeTablePayload (dbConn state)
           json  tt
       get ("test" <//> "cafetest") $ do
           state <- getState
           liftIO $ saveMenuPayload (dbConn state) dammyresponse
       get ("test" <//> "dbfetchtest") $ do
           state <- getState
           resp <- liftIO $ latestRecordFromMenuPayload (dbConn state)
           json resp
       get ("test" <//> "traintest") $ do
           state <- getState
           t <- liftIO $ latestRecordFromTrainPayload (dbConn state)
           json t
       get ("test" <//> "dbfetchtest2") $ do
           state <- getState
           resp <- liftIO $ latestRecordFromTimeTablePayload (dbConn state)
           json resp
       get ("test" <//> "outfetchtest") $ do
           state <- getState
           let fetchPort = ohara $ extInfo state
           js <- liftIO $ (fetchJSON ("http://localhost:" ++ show fetchPort ++ "/api/test") :: IO DTTT.TimeTables)
           json js
       get ("test" <//> "dammyadd") $ do
           state <- getState
           liftIO $ saveMenuPayload (dbConn state) dammyresponse
           liftIO $ saveTimeTablePayLoad (dbConn state) dammytime
           liftIO $ saveTrainPayLoad (dbConn state) dammytrain
           time <- liftIO $ getCurrentTime
           json $ mergeData time dammyresponse dammytime dammytrain
       get "dammyadd" $ do
           state <- getState
           let fetchPort = nakada $ extInfo state
           dammy <- liftIO $ fetchJSON ("http://localhost:" ++ show fetchPort ++ "/api/test2")
           liftIO $ saveTrainPayLoad (dbConn state) dammy
       get "traindammy" $ json dammytrain
       

getConnInfo :: IO ConnectInfo
getConnInfo = do
  host <- fromMaybe "localhost" <$> lookupEnv "DB_HOST"
  putStrLn $ "DEBUG DB_HOST=" ++ show host
  port <- maybe 5432 read <$> lookupEnv "DB_PORT"
  putStrLn $ "DEBUG DB_PORT=" ++ show port
  user <- fromMaybe "postgres" <$> lookupEnv "DB_USER"
  putStrLn $ "DEBUG DB_USER=" ++ show user
  pass <- fromMaybe "" <$> lookupEnv "DB_PASS"
  putStrLn $ "DEBUG DB_PASS=" ++ show pass
  db   <- fromMaybe "postgres" <$> lookupEnv "DB_NAME"
  putStrLn $ "DEBUG DB_NAME=" ++ show db

  pure defaultConnectInfo
    { connectHost     = host
    , connectPort     = port
    , connectUser     = user
    , connectPassword = pass
    , connectDatabase = db
    }

getExtInfo :: IO PortsInfo
getExtInfo = do
    oharaPort <- maybe 8080 read <$> lookupEnv "OHARA_PORT"
    putStrLn $ "DEBUG OHARA_PORT=" ++ show oharaPort
    matsumotoPort <- maybe 8081 read <$> lookupEnv "MATSUMOTO_PORT"
    putStrLn $ "DEBUG MATSUMOTO_PORT=" ++ show matsumotoPort
    nakadaPort <- maybe 8083 read <$> lookupEnv "NAKADA_PORT"
    putStrLn $ "DEBUG NAKADA_PORT=" ++ show nakadaPort

    pure $ PortsInfo
        { ohara = oharaPort
        , matsumoto = matsumotoPort
        , nakada = nakadaPort
        }


dammyresponse :: DTM.MenuPayload
dammyresponse = DTM.dammyMenu

dammytime :: DTTT.TimeTables
dammytime = DTTT.dammyTimeTable

dammytrain :: DTT.Train
dammytrain = DTT.dammyTrain
