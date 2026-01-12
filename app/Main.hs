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

import Domain.Types
import qualified Domain.Types.Menu as DTM
import qualified Domain.Types.TimeTable as DTTT
import qualified Domain.Types.Train as DTT
import DataSource.Fetch

data MySession = EmptySession
data MyAppState = DummyAppState (IORef Int)

main :: IO ()
main =
    do ref <- newIORef 0
       spockCfg <- defaultSpockCfg EmptySession PCNoDatabase (DummyAppState ref)
       runSpock 8080 (spock spockCfg app)

app :: SpockM () MySession MyAppState ()
app =
    do get root $
           text "Hello World!"
       get ("hello" <//> var) $ \name ->
           do (DummyAppState ref) <- getState
              visitorNumber <- liftIO $ atomicModifyIORef' ref $ \i -> (i+1, i+1)
              text ("Hello " <> name <> ", you are visitor number " <> T.pack (show visitorNumber))
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


dammyresponse :: DTM.MenuPayload
dammyresponse = DTM.MenuPayload
    {
        DTM.generated_at = "2026-01-05T11:21:55+09:00",
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
