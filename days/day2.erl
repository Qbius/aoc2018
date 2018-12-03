-module(day2).
-export([answer/0]).

answer() ->
    {ok, Contents} = file:read_file("input/day2"),
    Lines = [binary_to_list(BinLine) || BinLine <- string:split(Contents, <<"\n">>, all)],
    {get_checksum(Lines), find_different_by_one_character(Lines)}.

char_map(String) ->
    lists:foldl(fun(C, CharMap) ->
        case CharMap of
            #{C := N} ->
                CharMap#{C => N + 1};
            _ ->
                CharMap#{C => 1}
        end
    end, #{}, String).

get_checksum(Lines) ->
    {TwosTotal, ThreesTotal} = lists:foldl(fun(Line, {Twos, Threes}) ->
        Counts = maps:values(char_map(Line)),
        {Twos + case lists:member(2, Counts) of true -> 1; false -> 0 end, Threes + case lists:member(3, Counts) of true -> 1; false -> 0 end}
    end, {0, 0}, Lines),
    TwosTotal * ThreesTotal.

find_different_by_one_character(Lines) ->    
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