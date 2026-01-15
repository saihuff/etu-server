{-# LANGUAGE OverloadedStrings #-}
{-# LANGUAGE DeriveGeneric #-}
module Domain.Types.TimeTable where

import GHC.Generics
import Data.Aeson
import Data.Text
import Data.Time.Clock
import Data.Time.LocalTime
import Data.Time.Calendar

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
