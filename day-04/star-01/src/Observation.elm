module Observation exposing (GuardEvent(..), GuardId, Observation, comparison, debug, diff, from)

import Parser exposing ((|.), (|=), DeadEnd, Parser, end, int, oneOf, succeed, symbol)


type alias GuardId =
    Int


type GuardEvent
    = WakesUp
    | FallsAsleep
    | BeginsShift GuardId


type alias Observation =
    { year : Int
    , month : Int
    , day : Int
    , hour : Int
    , minute : Int
    , event : GuardEvent
    }


from : String -> Result (List DeadEnd) Observation
from line =
    Parser.run observationParser line


debug : Observation -> String
debug observation =
    String.fromInt observation.year
        ++ "-"
        ++ String.fromInt observation.month
        ++ "-"
        ++ String.fromInt observation.day
        ++ " "
        ++ String.fromInt observation.hour
        ++ ":"
        ++ String.fromInt observation.minute
        ++ " -- "
        ++ (case observation.event of
                WakesUp ->
                    "Wakes up!"

                FallsAsleep ->
                    "Falls asleep!"

                BeginsShift id ->
                    "Guard #" ++ String.fromInt id ++ " begins shift"
           )


diff : Observation -> Observation -> Int
diff observation olderObservation =
    List.length (List.range olderObservation.minute (observation.minute - 1))


comparison : Observation -> Observation -> Order
comparison a b =
    compare (toPosix a) (toPosix b)


toPosix : Observation -> Int
toPosix observation =
    -- for simplicity's sake I'm not using a real posix time, I'm instead
    -- definining this as minutes since Jan 1, 0000
    -- (and ignoring leap years etc)
    -- (and ignoring varying numbers of days in a month)
    (observation.year * 365 * 24 * 60)
        + (observation.month * 30 * 24 * 60)
        + (observation.day * 24 * 60)
        + (observation.hour * 60)
        + observation.minute


observationParser : Parser Observation
observationParser =
    succeed Observation
        |. symbol "["
        |= intWithPossibleLeadingZero
        |. symbol "-"
        |= intWithPossibleLeadingZero
        |. symbol "-"
        |= intWithPossibleLeadingZero
        |. symbol " "
        |= intWithPossibleLeadingZero
        |. symbol ":"
        |= intWithPossibleLeadingZero
        |. symbol "] "
        |= guardEventParser
        |. end


intWithPossibleLeadingZero : Parser Int
intWithPossibleLeadingZero =
    oneOf
        [ succeed identity
            |. symbol "0"
            |= int
        , succeed identity
            |= int
        ]


guardEventParser : Parser GuardEvent
guardEventParser =
    oneOf
        [ succeed WakesUp
            |. symbol "wakes up"
        , succeed FallsAsleep
            |. symbol "falls asleep"
        , succeed BeginsShift
            |. symbol "Guard #"
            |= int
            |. symbol " begins shift"
        ]
