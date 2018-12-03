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
    Lines = [binary_to_list(BinLine) || BinLine <- string:split(Contents, <<"\n">>, all)],
    lists:usort(lists:filtermap(fun
        RemoveDifferentChar({[H | R1], [H | R2], Count, Result}) ->
            RemoveDifferentChar({R1, R2, Count, [H | Result]});
        RemoveDifferentChar({[_H1 | R1], [_H2 | R2], Count, Result}) ->
            RemoveDifferentChar({R1, R2, Count, Result});
        RemoveDifferentChar({[], [], Count, Result}) when (length(Result) + 1) =:= Count ->
            {true, lists:reverse(Result)};
        RemoveDifferentChar({[], [], _Count, _Result}) ->
            false        
    end, [{Line1, Line2, length(Line1), []} || Line1 <- Lines, Line2 <- Lines])).