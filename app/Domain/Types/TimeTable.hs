{-# LANGUAGE OverloadedStrings #-}
{-# LANGUAGE DeriveGeneric #-}
module Domain.Types.TimeTable where

import GHC.Generics
import Data.Aeson
import Data.Text
import Data.Time.Clock
import Data.Time.LocalTime
import Data.Time.Calendar
import Database.PostgreSQL.Simple.FromField (FromField, fromJSONField, fromField)

data Subject = Subject
  { period :: Int
  , subject :: Text
  } deriving (Show, Generic)

data TimeTable = TimeTable
  { subjects :: [Subject]
  , date :: Day
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

newtype TimeTableJSON = TimeTableJSON [TimeTable]

instance FromJSON TimeTableJSON where
  parseJSON v = TimeTableJSON <$> parseJSON v

instance FromField TimeTableJSON where
  fromField = fromJSONField


type TimeTablePair = (Int, UTCTime, TimeTableJSON, Text, UTCTime, UTCTime, Text)

dammyTimeTable :: TimeTables
dammyTimeTable = TimeTables
    { generated_at = read "2026-01-12 04:53:23.441233382 UTC"
    , main_timetable = [TimeTable { subjects = [Subject { period = 1
                                                        , subject = "japanese" 
                                                        }
                                               ]
                                  , date = read "2026-01-16" 
                                  }
                       ]
    }
