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
import DataSource.Fetch

data MySession = EmptySession
data MyAppState = DummyAppState (IORef Int)

data AppState = AppState {dbConn :: Connection}

main :: IO ()
main =
    do ref <- newIORef 0
       connInfo <- getConnInfo
       conn <- connect connInfo
       let appState = AppState conn
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
       get ("api" <//> "v1" <//> "board") (json dammyresponse)
       post ("api" <//> "v1" <//> "cafe") $ do
           jsonreq <- jsonBody'
           state <- getState
           liftIO $ saveMenuPayload (dbConn state) jsonreq
           text "ok"

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
dammyresponse = DTM.MenuPayload
    {
        DTM.generated_at = read "2026-01-12 04:53:23.441233382 UTC",
        DTM.menus = [
            DTM.Menu {
                DTM.name = "ダミー担々麺",
                DTM.date = "2026-01-20",
                DTM.price = 500
            },
            DTM.Menu {
                DTM.name = "ダミー春巻き",
                DTM.date = "2026-01-21",
                DTM.price = 130
            },
            DTM.Menu {
                DTM.name = "ダミー親子丼",
                DTM.date = "2026-01-22",
                DTM.price = 550
            }
        ]
    }
