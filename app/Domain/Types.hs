{-# LANGUAGE OverloadedStrings #-}
{-# LANGUAGE DeriveGeneric #-}
module Domain.Types where

import GHC.Generics
import Data.Aeson
import Data.Text
import Data.Time.Clock
import Data.Time.LocalTime
import Data.Time.Calendar

import qualified Domain.Types.Menu as DTM
import qualified Domain.Types.TimeTable as DTTT
import qualified Domain.Types.Train as DTT

-----------------------------------------------
data LoginReq = LoginReq
  { username :: Text
  , password :: Text
  } deriving (Show, Generic)

instance FromJSON LoginReq
instance ToJSON LoginReq
-----------------------------------------------
    --main Types

data Meta' = Meta'
  { fetchedAt :: UTCTime
  , updatedAt :: UTCTime
  , source :: Text
  } deriving (Show, Generic)

instance ToJSON Meta'

data WithMeta a = WithMeta
  { meta :: Meta'
  , value :: a
  } deriving (Show, Generic)


data WithStatus a
  = Available a
  | Stale a NominalDiffTime
  | Unavailable
  deriving (Show, Generic)

instance ToJSON a => ToJSON (WithStatus a)
instance ToJSON a => ToJSON (WithMeta a)

data Board = Board
  { boardTimeb :: UTCTime
  , menub :: WithStatus (WithMeta DTM.MenuPayload)
  , timetableb :: WithStatus (WithMeta DTTT.TimeTables)
  , trainb :: WithStatus (WithMeta DTT.Train)
  } deriving (Show, Generic)

instance ToJSON Board


data TestBoard = TestBoard
  { generated_at :: UTCTime
  , cafe :: DTM.MenuPayload
  , timetable :: DTTT.TimeTables
  , train :: DTT.Train
  } deriving (Show, Generic)

instance ToJSON TestBoard
