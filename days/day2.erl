-module(day2).
-export([easy/0, hard/0]).

easy() ->
    {ok, Contents} = file:read_file("input/day2"),
    {TwosTotal, ThreesTotal} = lists:foldl(fun(BinLine, {Twos, Threes}) ->
        Counts = maps:values(char_map(binary_to_list(BinLine))),
        {Twos + case lists:member(2, Counts) of true -> 1; false -> 0 end, Threes + case lists:member(3, Counts) of true -> 1; false -> 0 end}
    end, {0, 0}, string:split(Contents, <<"\n">>, all)),
    TwosTotal * ThreesTotal.

char_map(String) ->
    lists:foldl(fun(C, CharMap) ->
        case CharMap of
            #{C := N} ->
                CharMap#{C => N + 1};
            _ ->
                CharMap#{C => 1}
        end
    end, #{}, String).

hard() ->
    {ok, Contents} = file:read_file("input/day2"),
    {LetterBegins, LetterEnds} = lists:foldl(fun([Begin | _] = Line, {BeginsMap, EndsMap}) ->
        End = lists:last(Line),
        {BeginsMap#{Begin => [Line | maps:get(Begin, BeginsMap, [])]}, EndsMap#{End => [Line | maps:get(End, EndsMap, [])]}}
    end, {#{}, #{}}, [binary_to_list(BinLine) || BinLine <- string:split(Contents, <<"\n">>, all)]),
    find_different_by_one(maps:values(LetterBegins) ++ maps:values(LetterEnds)).

find_different_by_one([List | Rest]) ->
    Result = lists:filter(fun
        (nomatch) -> false;
        (_) -> true
    end, [case different_character_count(Line1, Line2, 0) of
        1 -> {Line1, Line2};
        _ -> nomatch
    end || Line1 <- List, Line2 <- List]),
    case Result of
        [] ->
            find_different_by_one(Rest);
        [{First, Second} | _] ->
            remove_different_character(First, Second, [])
    end.

different_character_count([H | T1], [H | T2], Count) ->
    different_character_count(T1, T2, Count);
different_character_count([_H1 | T1], [_H2 | T2], Count) ->
    different_character_count(T1, T2, Count + 1);
different_character_count([], [], Count) ->
    Count.

remove_different_character([H | T1], [H | T2], Result) ->
    remove_different_character(T1, T2, [H | Result]);
remove_different_character([_H1 | T1], [_H2 | T2], Result) ->
    remove_different_character(T1, T2, Result);
remove_different_character([], [], Result) ->
    lists:reverse(Result).