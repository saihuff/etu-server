{-# LANGUAGE OverloadedStrings #-}
{-# LANGUAGE DeriveGeneric #-}
module Domain.Types.Train where

import GHC.Generics
import Data.Aeson
import Data.Text
import Data.Time.Clock
import Data.Time.LocalTime
import qualified Data.ByteString.Lazy
import Database.PostgreSQL.Simple.FromField


-- train type -----------------------------
data DepartureTime = DepartureTime
  { hour :: Int
  , minute :: Int
  } deriving (Show, Generic)

data DepartureTimes = DepartureTimes
  { kanazawa :: [DepartureTime]
  , nanao :: [DepartureTime]
  , toyama :: [DepartureTime]
  } deriving (Show, Generic)

data Train = Train
  { generated_at :: UTCTime
  , destination :: DepartureTimes
  } deriving (Show, Generic)

instance FromJSON DepartureTime
instance FromJSON DepartureTimes
instance FromJSON Train
instance ToJSON DepartureTime
instance ToJSON DepartureTimes
instance ToJSON Train

newtype TrainJSON = TrainJSON DepartureTimes

instance FromJSON TrainJSON where
  parseJSON v = TrainJSON <$> parseJSON v

instance FromField TrainJSON where
  fromField = fromJSONField

type TrainPair = (Int, UTCTime, TrainJSON, Text, UTCTime, UTCTime, Text)

dammyTrain :: Train
dammyTrain = Train
    { generated_at = read "2026-01-12 04:53:23.441233382 UTC"
    , destination = DepartureTimes
                        { kanazawa = [ DepartureTime
                                        { hour = 1
                                        , minute = 10
                                        }
                                     , DepartureTime
                                        { hour = 1
                                        , minute = 15
                                        }
                                     ]
                        , nanao = [ DepartureTime
                                        { hour = 1
                                        , minute = 10
                                        }
                                  , DepartureTime
                                        { hour = 1
                                        , minute = 15
                                        }
                                     ]
                        , toyama = [ DepartureTime
                                        { hour = 1
                                        , minute = 10
                                        }
                                   , DepartureTime
                                        { hour = 1
                                        , minute = 15
                                         }
                                   ]
                        }
    }
