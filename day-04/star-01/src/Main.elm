module Main exposing (main, update, view)

import Browser
import Dict exposing (Dict)
import Html exposing (div, h2, h3, hr, li, text, ul)
import Input exposing (input)
import Observation exposing (GuardEvent(..), GuardId, Observation)


type Problem
    = UnparsableLine


type alias MinutesAsleep =
    Int


type alias MinuteOfHour =
    Int


type alias AsleepHowManyTimes =
    Int


type alias Counter =
    { guardSleepDurations : Dict GuardId MinutesAsleep
    , currentGuardId : Maybe GuardId
    , previousObservation : Maybe Observation
    }


type alias MinutesTicker =
    { ticker : Dict MinuteOfHour AsleepHowManyTimes
    , currentGuardId : Maybe GuardId
    , previousObservation : Maybe Observation
    }


main =
    Browser.sandbox { init = 0, update = update, view = view }


update msg model =
    model


view model =
    div []
        [ h2 []
            [ text "Sleepiest guard's sleepiest minute to follow" ]
        , div
            []
            [ case observations of
                Ok list ->
                    case sleepiestGuard of
                        Just guard ->
                            let
                                fafa =
                                    asleepMinutesFor (Tuple.first guard) list

                                foofoo =
                                    Debug.log "mins" fafa
                            in
                            text "TK"

                        Nothing ->
                            text "No sleepiest guard??"

                Err e ->
                    case e of
                        UnparsableLine ->
                            text "Could not parse a line..."
            ]

        -- [ case sleepiestGuard of
        --     Just guard ->
        --         let
        --             fafa =
        --                 asleepMinutesFor (Tuple.first guard) observations
        --
        --             foofoo =
        --                 Debug.log "mins" fafa
        --         in
        --         text "TK"
        --
        --     Nothing ->
        --         text "No sleepiest guard??"
        -- ]
        , hr [] []
        , h2 [] [ text "Sleepiest guard to follow" ]
        , h3 []
            [ case sleepiestGuard of
                Just guard ->
                    viewGuard guard

                Nothing ->
                    text "No sleepiest guard???"
            ]
        , hr [] []
        , h2 [] [ text "Guards and their sleep times, ordered, to follow" ]
        , div []
            [ viewSleepCount sleepCounts ]
        , hr [] []
        , h2 [] [ text "Sorted observations to follow" ]
        , case observations of
            Ok list ->
                ul [] (List.map viewObservation list)

            Err e ->
                case e of
                    UnparsableLine ->
                        text "Could not parse a line..."
        ]


sleepiestGuard : Maybe ( GuardId, MinutesAsleep )
sleepiestGuard =
    case sleepCounts of
        Ok counts ->
            List.head counts

        Err e ->
            Nothing


viewSleepCount : Result Problem (List ( GuardId, MinutesAsleep )) -> Html.Html msg
viewSleepCount result =
    case result of
        Ok counter ->
            ul [] (List.map viewSingleSleepCount counter)

        Err e ->
            text "Counter not ok"


viewSingleSleepCount : ( GuardId, MinutesAsleep ) -> Html.Html msg
viewSingleSleepCount d =
    li [] [ viewGuard d ]


viewGuard : ( GuardId, MinutesAsleep ) -> Html.Html msg
viewGuard guard =
    text
        ("Guard #"
            ++ String.fromInt (Tuple.first guard)
            ++ " - "
            ++ String.fromInt (Tuple.second guard)
            ++ " minutes asleep"
        )


sleepCounts : Result Problem (List ( GuardId, MinutesAsleep ))
sleepCounts =
    observations |> Result.map countSleeps


asleepMinutesFor : GuardId -> List Observation -> List ( MinuteOfHour, AsleepHowManyTimes )
asleepMinutesFor guardId list =
    List.foldl (tickMinutesOfHourAsleep guardId) newMinutesOfHourTicker list
        |> .ticker
        |> Dict.toList
        |> List.sortWith sortMinutesAsleepDesc


sortMinutesAsleepDesc : ( MinuteOfHour, AsleepHowManyTimes ) -> ( MinuteOfHour, AsleepHowManyTimes ) -> Order
sortMinutesAsleepDesc a b =
    compare (Tuple.second b) (Tuple.second a)


tickMinutesOfHourAsleep : GuardId -> Observation -> MinutesTicker -> MinutesTicker
tickMinutesOfHourAsleep guardId observation ticker =
    case observation.event of
        WakesUp ->
            let
                updatedTicker =
                    case ticker.currentGuardId of
                        Just id ->
                            if id == guardId then
                                tickAllMinutesBetween ticker.previousObservation observation ticker.ticker

                            else
                                -- don't track this one
                                ticker.ticker

                        Nothing ->
                            let
                                a =
                                    Debug.log "WTF" "WTF"
                            in
                            -- this should never happen but still...
                            ticker.ticker
            in
            { ticker
                | previousObservation = Just observation
                , ticker = updatedTicker
            }

        FallsAsleep ->
            { ticker
                | previousObservation = Just observation
            }

        BeginsShift newGuardId ->
            { ticker
                | currentGuardId = Just newGuardId
                , previousObservation = Just observation
            }


tickAllMinutesBetween : Maybe Observation -> Observation -> Dict MinuteOfHour AsleepHowManyTimes -> Dict MinuteOfHour AsleepHowManyTimes
tickAllMinutesBetween maybePreviousObservation observation ticker =
    case maybePreviousObservation of
        Just previousObservation ->
            let
                startingMinute =
                    previousObservation.minute

                endingMinute =
                    observation.minute - 1

                foofoo =
                    Debug.log "---" "---"

                range =
                    Debug.log "ticking range" (List.range startingMinute endingMinute)

                fafa =
                    Debug.log "related to observation " (Observation.debug observation)
            in
            List.foldl tickMinute ticker range

        Nothing ->
            let
                a =
                    Debug.log "WTF2" "WTF2"
            in
            -- shouldn't be possible but shrug
            ticker


tickMinute : MinuteOfHour -> Dict MinuteOfHour AsleepHowManyTimes -> Dict MinuteOfHour AsleepHowManyTimes
tickMinute minuteOfHourToTick ticker =
    Dict.update minuteOfHourToTick increment ticker


increment : Maybe AsleepHowManyTimes -> Maybe AsleepHowManyTimes
increment maybePreviousAmount =
    case maybePreviousAmount of
        Just previousAmount ->
            Just (previousAmount + 1)

        Nothing ->
            Just 1


newMinutesOfHourTicker : MinutesTicker
newMinutesOfHourTicker =
    { ticker = Dict.empty
    , currentGuardId = Nothing
    , previousObservation = Nothing
    }


countSleeps : List Observation -> List ( GuardId, MinutesAsleep )
countSleeps list =
    List.foldl countObservation newCounter list
        |> .guardSleepDurations
        |> Dict.toList
        |> List.sortWith sortSleepCountsDesc


sortSleepCountsDesc : ( GuardId, MinutesAsleep ) -> ( GuardId, MinutesAsleep ) -> Order
sortSleepCountsDesc a b =
    compare (Tuple.second b) (Tuple.second a)


newCounter : Counter
newCounter =
    { guardSleepDurations = Dict.empty
    , currentGuardId = Nothing
    , previousObservation = Nothing
    }


countObservation : Observation -> Counter -> Counter
countObservation observation counter =
    case observation.event of
        WakesUp ->
            let
                timeAsleep =
                    case counter.previousObservation of
                        Just previousObservation ->
                            Observation.diff observation previousObservation

                        Nothing ->
                            -- this should never happen... but not sure how
                            -- to make this function return a Result so I'm
                            -- just introducing some weird behavior instead
                            0

                updatedGuardSleepDurations =
                    case counter.currentGuardId of
                        Just id ->
                            Dict.update id (addToSleepCount timeAsleep) counter.guardSleepDurations

                        Nothing ->
                            -- this should never happen... but not sure how
                            -- to make this function return a Result so I'm
                            -- just introducing some weird behavior instead
                            counter.guardSleepDurations
            in
            { counter
                | previousObservation = Just observation
                , guardSleepDurations = updatedGuardSleepDurations
            }

        FallsAsleep ->
            { counter
                | previousObservation = Just observation
            }

        BeginsShift guardId ->
            { counter
                | currentGuardId = Just guardId
                , previousObservation = Just observation
            }


addToSleepCount : Int -> Maybe Int -> Maybe Int
addToSleepCount amountToAdd maybePreviousAmount =
    case maybePreviousAmount of
        Just previousAmount ->
            Just (previousAmount + amountToAdd)

        Nothing ->
            Just amountToAdd


viewObservation : Observation -> Html.Html msg
viewObservation observation =
    li [] [ text (Observation.debug observation) ]


observations : Result Problem (List Observation)
observations =
    List.map Observation.from (String.lines input)
        |> ensureAllPresent
        |> Result.map sortObservations


ensureAllPresent : List (Result e Observation) -> Result Problem (List Observation)
ensureAllPresent list =
    if List.any isErr list then
        Err UnparsableLine

    else
        Ok (List.filterMap Result.toMaybe list)


isErr : Result a b -> Bool
isErr result =
    case result of
        Ok _ ->
            False

        Err _ ->
            True


sortObservations : List Observation -> List Observation
sortObservations list =
    List.sortWith Observation.comparison list
