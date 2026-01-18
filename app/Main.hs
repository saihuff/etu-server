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

data MySession = EmptySession
data MyAppState = DummyAppState (IORef Int)

data AppState = AppState {dbConn :: Connection}

main :: IO ()
main =
    do ref <- newIORef 0
       connInfo <- getConnInfo
       conn <- connect connInfo
       let appState = AppState conn
       startPolling conn
       spockCfg <- defaultSpockCfg EmptySession PCNoDatabase appState
       runSpock 8080 (spock spockCfg app)

app :: SpockM () MySession AppState ()
app =
    do get root $
           text "Hello World!"
               {-get ("hello" <//> var) $ \name ->
           do (DummyAppState ref) <- getState
              visitorNumber <- liftIO $ atomicModifyIORef' ref $ \i -> (i+1, i+1)
              text ("Hello " <> name <> ", you are visitor number " <> T.pack (show visitorNumber))-}
       post "test" $ do
           mreq <- jsonBody'
           liftIO . print $ (mreq :: LoginReq)
           text "ok"
       get "raspi" $ do
           x <- liftIO $ fetchJSON "http://[2600:1900:4001:79b::]:5000/menu_get"
           json (x :: DTM.MenuPayload)
       post ("raspi" <//> "test") $ do
           mreq <- jsonBody'
           liftIO . print $ (mreq :: DTM.MenuPayload)
           json mreq
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
       get ("test" <//> "dbfetchtest2") $ do
           state <- getState
           resp <- liftIO $ latestRecordFromTimeTablePayload (dbConn state)
           json resp
       get ("test" <//> "outfetchtest") $ do
           js <- liftIO $ (fetchJSON "http://172.21.54.165:5000/api/test" :: IO DTTT.TimeTables)
           json js
       get "dammyadd" $ do
           state <- getState
           liftIO $ saveTrainPayLoad (dbConn state) dammytrain
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

dammyresponse :: DTM.MenuPayload
dammyresponse = DTM.dammyMenu

dammytime :: DTTT.TimeTables
dammytime = DTTT.dammyTimeTable

dammytrain :: DTT.Train
dammytrain = DTT.dammyTrain
