module Domain.Transform where


import Domain.Types
import qualified Domain.Types.TimeTable as DTTT
import qualified Domain.Types.Menu as DTM
import qualified Domain.Types.Train as DTT
import Data.Time

mergeData :: UTCTime -> DTM.MenuPayload -> DTTT.TimeTables -> DTT.Train -> TestBoard
mergeData time mn tt tn = TestBoard { generated_at = time,
                                      cafe = mn,
                                      timetable = tt,
                                      train = tn
                                    }
