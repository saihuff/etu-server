{-# LANGUAGE OverloadedStrings #-}
{-# LANGUAGE DeriveGeneric #-}
module Domain.Types.Train where

import GHC.Generics
import Data.Aeson
import Data.Text
import Data.Time.Clock
import Data.Time.LocalTime


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
  , destination :: [DepartureTimes]
  } deriving (Show, Generic)

instance FromJSON DepartureTime
instance FromJSON DepartureTimes
instance FromJSON Train
instance ToJSON DepartureTime
instance ToJSON DepartureTimes
instance ToJSON Train
