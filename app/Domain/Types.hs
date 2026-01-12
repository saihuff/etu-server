{-# LANGUAGE OverloadedStrings #-}
{-# LANGUAGE DeriveGeneric #-}
module Domain.Types where

import GHC.Generics
import Data.Aeson
import Data.Text
import Data.Time.Clock
import Data.Time.LocalTime

data LoginReq = LoginReq
  { username :: Text
  , password :: Text
  } deriving (Show, Generic)

instance FromJSON LoginReq
instance ToJSON LoginReq
