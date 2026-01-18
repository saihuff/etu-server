{-# LANGUAGE OverloadedStrings #-}
{-# LANGUAGE DeriveGeneric #-}
{-# LANGUAGE FlexibleInstances, TypeSynonymInstances #-}
module Domain.Types.Menu where

import GHC.Generics
import Data.Aeson
import Data.Text
import Data.Time.Clock
import Data.Time.LocalTime
import Database.PostgreSQL.Simple.ToField
import Database.PostgreSQL.Simple.FromField (FromField, fromField, fromJSONField)

-- menu type

data Menu = Menu
  { name  :: Text
  , date  :: Text
  , price :: Int
  } deriving (Show, Generic)

data MenuPayload = MenuPayload
  { generated_at :: UTCTime
  , menus        :: [Menu]
  } deriving (Show, Generic)

instance FromJSON Menu
instance ToJSON Menu
instance FromJSON MenuPayload
instance ToJSON MenuPayload

dammyMenu :: MenuPayload
dammyMenu = MenuPayload { generated_at = read "2026-01-12 04:53:23.441233382 UTC",
                          menus = [Menu { name = "ダミー担々麺", date = "2026-01-20", price = 500 }
                                  ,Menu { name = "ダミー春巻き", date = "2026-01-21", price = 130 }
                                  ,Menu { name = "ダミー親子丼", date = "2026-01-22", price = 550 }
                                  ]
                        }

type MenuPair = (Int, UTCTime, MenusJSON, Text, UTCTime, UTCTime, Text)

newtype MenusJSON = MenusJSON [Menu]

instance FromJSON MenusJSON where
  parseJSON v = MenusJSON <$> parseJSON v

instance FromField MenusJSON where
  fromField = fromJSONField
