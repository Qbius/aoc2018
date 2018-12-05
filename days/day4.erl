-module(day4).
-export([answer/0]).

answer() ->
    {ok, Contents} = file:read_file("input/day4"),
    {finalize(process_guard_map(get_guard_map([binary_to_list(Line) || Line <- string:split(Contents, "\r\n", all)]))), ok}.

get_guard_map(Lines) ->
    get_guard_map(lists:sort(lists:map(fun parse_log_line/1, Lines)), no_guard, #{}).
get_guard_map([{Date, Minute, Action} | T], Guard, Map) ->
    case Action of
        NewGuard when is_integer(NewGuard) ->
            get_guard_map(T, NewGuard, Map);
        Act ->
            NewMap = case Guard of
                no_guard -> 
                    Map;
                _ ->
                    ActionMap = maps:get(Guard, Map, #{}),
                    Map#{Guard => ActionMap#{Date => [{Minute, Act} | maps:get(Date, ActionMap, [])]}}
            end,
            get_guard_map(T, Guard, NewMap)
    end;
get_guard_map([], _, Map) ->
    Map.            
            
parse_log_line([$[, Y1, Y2, Y3, Y4, $-, M1, M2, $-, D1, D2, _Space1, _, _, $:, Min1, Min2, $], _Space2 | Rest1]) ->
    {{list_to_integer([Y1, Y2, Y3, Y4]), list_to_integer([M1, M2]), list_to_integer([D1, D2])}, list_to_integer([Min1, Min2]), case Rest1 of
        [$G, $u, $a, $r, $d, _Space3, $# | Rest2] ->
            list_to_integer(lists:nth(1, string:split(Rest2, " ")));
        "falls asleep" ->
            falls;
        "wakes up" ->
            wakes
    end}.

process_guard_map(Map) ->
    X = maps:from_list(lists:map(fun(Key) ->
        ActionMap = maps:get(Key, Map),
        analyze_guard_log(ActionMap, Key)
    end, maps:keys(Map))),
    io:format("~p~n", [X]),
    X.

analyze_guard_log(ActionMap, Guard) ->
    AllMinutes = lists:append([minutes_asleep(lists:sort(maps:get(Key, ActionMap)), awake, []) || Key <- maps:keys(ActionMap)]),
    {length(AllMinutes), {AllMinutes, Guard}}.

minutes_asleep([{Minute, falls} | T], awake, Result) ->
    minutes_asleep(T, asleep, Result ++ lists:seq(Minute, 59));
minutes_asleep([{Minute, wakes} | T], asleep, Result) ->
    minutes_asleep(T, awake, lists:takewhile(fun(I) -> I < Minute end, Result));
minutes_asleep([{_, falls} | T], asleep, Result) ->
    minutes_asleep(T, asleep, Result);
minutes_asleep([{_, wakes} | T], awake, Result) ->
    minutes_asleep(T, awake, Result);
minutes_asleep([], _, Result) ->
    Result.

finalize(FinalMap) ->
    {AllMinutes, Guard} = maps:get(lists:max(maps:keys(FinalMap)), FinalMap),
    Guard * find_most_common(AllMinutes).

find_most_common(List) ->
    OccurenceMap = lists:foldl(fun(Ele, Map) ->
        case Map of
            #{Ele := N} ->
                Map#{Ele => N + 1};
            _ ->
                Map#{Ele => 1}
        end
    end, #{}, List),
    MostOccurences = lists:max(maps:values(OccurenceMap)),
    {Answer, MostOccurences} = lists:nth(1, maps:to_list(maps:filter(fun
        (_, Occur) when Occur =:= MostOccurences -> true;
        (_, _) -> false
    end, OccurenceMap))),
    Answer.