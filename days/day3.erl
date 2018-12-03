-module(day3).
-export([answer/0]).

answer() ->
    {ok, Contents} = file:read_file("input/day3"),
    Lines = string:split(Contents, <<"\n">>, all),
    ChildrenPids = prepare_collect_overlapped(lists:map(fun(I) ->
        [_, Coords] = string:split(binary_to_list(lists:nth(I, Lines)), <<" @ ">>),
        [Origin, Dimensions] = string:split(Coords, <<": ">>),
        [X, Y] = lists:map(fun list_to_integer/1, string:split(Origin, <<",">>)),
        [Width, Height] = lists:map(fun list_to_integer/1, string:split(Dimensions, <<"x">>)),
        {I, {{X, Y}, {Width, Height}}}
    end, lists:seq(1, length(Lines)))),
    {UniqueOccupiedCoords, OverlappingIDs} = receive_collect_overlapped(ChildrenPids, {[], []}),
    {length(UniqueOccupiedCoords), lists:seq(1, length(Lines)) -- OverlappingIDs}.


prepare_collect_overlapped([{ID1, {{X1, Y1}, {Width1, Height1}} = Dim1} | T]) ->
    Pid = self(),
    [spawn(fun() ->
        {OccupiedCoords, OverlappingIDs} = lists:foldl(fun({ID2, {{X2, Y2}, {Width2, Height2}} = Dim2}, {Result, IDs}) ->
            case do_squares_overlap(Dim1, Dim2) of
                true ->
                    FirstSquare = [{ResX1, ResY1} || ResX1 <- lists:seq(X1 + 1, X1 + Width1), ResY1 <- lists:seq(Y1 + 1, Y1 + Height1)],
                    SecondSquare = [{ResX2, ResY2} || ResX2 <- lists:seq(X2 + 1, X2 + Width2), ResY2 <- lists:seq(Y2 + 1, Y2 + Height2)],
                    {[lists:filter(fun(Dot) ->
                        lists:member(Dot, SecondSquare)
                    end, FirstSquare) | Result], [ID1, ID2 | IDs]};
                false ->
                    {Result, IDs}
            end
        end, {[], []}, T),
        Pid ! {self(), {lists:append(OccupiedCoords), OverlappingIDs}}
    end) | prepare_collect_overlapped(T)];
prepare_collect_overlapped([]) ->
    [].

receive_collect_overlapped([H | T], {Result, Overlapping}) ->
    receive
        {H, {CoordList, OverlappingIDs}} -> 
            receive_collect_overlapped(T, {[CoordList | Result], [OverlappingIDs | Overlapping]})
    end;
receive_collect_overlapped([], {Result, Overlapping}) ->
    {lists:usort(lists:append(Result)), lists:usort(lists:append(Overlapping))}.

do_squares_overlap({{X1, Y1}, {Width1, Height1}}, {{X2, Y2}, {Width2, Height2}}) ->
    {WMin1, WMax1, WMin2, WMax2} = {X1 + 1, X1 + Width1, X2 + 1, X2 + Width2},
    {HMin1, HMax1, HMin2, HMax2} = {Y1 + 1, Y1 + Height1, Y2 + 1, Y2 + Height2},
    WMax1 >= WMin2 andalso WMin1 =< WMax2 andalso HMax1 >= HMin2 andalso HMin1 =< HMax2.