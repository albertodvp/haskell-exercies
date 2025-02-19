-- |

import           Data.Deque
import System.Exit (exitFailure)

main = do
  let st = push_front 15 $ push_front 10 $ push_front 5 $ push_front 0 $ empty
      st' = pop_front $ pop_front st
      st'' = push_front 100 st'
      shouldBeTrue = [front st' == Just 5,
                      front st'' == Just 100,
                      isEmpty $ pop_front $ pop_front st']
  case and shouldBeTrue of
    True -> pure ()
    False -> exitFailure


