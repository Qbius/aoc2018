-module(day5).
-export([answer/0]).

answer() ->
    {ok, Contents} = file:read_file("input/day5"),
    Polymer = binary_to_list(Contents),
    {react(Polymer), find_the_meanest(Polymer)}.

react(Polymer) ->
    {Result, State} = react(Polymer, [], same),
    case State of
        altered -> react(Result);
        same -> length(Result)
    end.

react([First, Second | T], Result, _) when abs(First - Second) =:= ($a - $A) ->
    react(T, Result, altered);
react([H | T], Result, State) ->
    react(T, [H | Result], State);
react([], Result, State) ->
    {lists:reverse(Result), State}.

find_the_meanest(Polymer) ->
    lists:nth(1, lists:sort(concurrent:map(fun(Letter) ->
        react([C || C <- Polymer, C =/= Letter andalso C =/= (Letter + $a - $A)])
    end, lists:seq($A, $Z)))).