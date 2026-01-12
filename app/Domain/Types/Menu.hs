{-# LANGUAGE OverloadedStrings #-}
{-# LANGUAGE DeriveGeneric #-}
module Domain.Types.Menu where

import GHC.Generics
import Data.Aeson
import Data.Text
import Data.Time.Clock
import Data.Time.LocalTime

-- menu type

data Menu = Menu
  { name  :: Text
  , date  :: Text
  , price :: Int
  } deriving (Show, Generic)

data MenuPayload = MenuPayload
  { generated_at :: Text
  , menus        :: [Menu]
  } deriving (Show, Generic)

instance FromJSON Menu
instance ToJSON Menu
instance FromJSON MenuPayload
instance ToJSON MenuPayload
