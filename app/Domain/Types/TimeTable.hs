{-# LANGUAGE OverloadedStrings #-}
{-# LANGUAGE DeriveGeneric #-}
module Domain.Types.TimeTable where

import GHC.Generics
import Data.Aeson
import Data.Text
import Data.Time.Clock
import Data.Time.LocalTime

data Subject = Subject
  { period :: Int
  , subject :: Text
  } deriving (Show, Generic)

data TimeTable = TimeTable
  { subjects :: [Subject]
  , date :: Text
  } deriving (Show, Generic)

data TimeTables = TimeTables
  { generated_at :: UTCTime
  , main_timetable :: [TimeTable]
  } deriving (Show, Generic)

instance FromJSON Subject
instance FromJSON TimeTable
instance FromJSON TimeTables
instance ToJSON Subject
instance ToJSON TimeTable
instance ToJSON TimeTables
