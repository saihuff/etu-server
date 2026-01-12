{-# LANGUAGE OverloadedStrings #-}
{-# LANGUAGE DeriveGeneric #-}
module Domain.Types where

import GHC.Generics
import Data.Aeson
import Data.Text
import Data.Time.Clock
import Data.Time.LocalTime

import qualified Domain.Types.Menu as DTM
import qualified Domain.Types.TimeTable as DTTT
import qualified Domain.Types.Train as DTT

data LoginReq = LoginReq
  { username :: Text
  , password :: Text
  } deriving (Show, Generic)

instance FromJSON LoginReq
instance ToJSON LoginReq

data Board = Board
  { time :: UTCTime
  , menu :: DTM.Menu
  , timetable :: DTTT.TimeTable
  , train :: DTT.Train
  } deriving (Show, Generic)

instance FromJSON Board
instance ToJSON Board
