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
           json (x :: MenuPayload)
       post ("raspi" <//> "test") $ do
           mreq <- jsonBody'
           liftIO . print $ (mreq :: MenuPayload)
           json mreq
       get ("api" <//> "board") (json dammyresponse)


dammyresponse :: MenuPayload
dammyresponse = MenuPayload
    {
        generated_at = "2026-01-05T11:21:55+09:00",
        menus = [
            Menu {
                name = "ダミー担々麺",
                date = "2026-01-20",
                price = 500
            },
            Menu {
                name = "ダミー春巻き",
                date = "2026-01-21",
                price = 130
            },
            Menu {
                name = "ダミー親子丼",
                date = "2026-01-22",
                price = 550
            }
        ]
    }
