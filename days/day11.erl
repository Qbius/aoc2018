-module(day11).
-export([answer/0]).

input() -> 18.

answer() ->
    PowerLevelsGrid = concurrent:map(fun(List) ->
        concurrent:map(fun({X, Y}) ->
            case ((X + 10) * Y + input()) * (X + 10) of
                N when N > 99 ->
                    lists:nth(3, lists:reverse(integer_to_list(N))) - $0;
                _ ->
                    0
            end - 5 % award for the most confusing line of the day
        end, List)
    end, [[{A, B} || A <- lists:seq(1, 300)] || B <- lists:seq(1, 300)]),
    _SumLists = zip_horizontal_lists(concurrent:map(fun(List) -> three_sum(List, []) end, PowerLevelsGrid), []).

three_sum([A, B, C | _] = [_ | T], Result) ->
    three_sum(T, [A + B + C | Result]);
three_sum(_, Result) ->
    lists:reverse(Result).

zip_horizontal_lists([A, B, C | _] = [_ | T], Result) ->
    zip_horizontal_lists(T, [lists:zip3(A, B, C) | Result]);
zip_horizontal_lists(_, Result) ->
    lists:reverse(Result).