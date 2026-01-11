{-# LANGUAGE OverloadedStrings #-}
{-# LANGUAGE DeriveGeneric #-}
module Domain.Types where

import GHC.Generics
import Data.Aeson
import Data.Text

-- test type -----------------------------
data LoginReq = LoginReq
  { username :: Text
  , password :: Text
  } deriving (Show, Generic)

instance FromJSON LoginReq
instance ToJSON LoginReq

-- menu type -----------------------------
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
