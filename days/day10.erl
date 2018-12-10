-module(day10).
-export([answer/0]).

answer() ->
    {ok, Contents} = file:read_file("input/day10"),
    PointsToVelocity = lists:map(fun(BinLine) ->
        [[$p, $o, $s, $i, $t, $i, $o, $n, $=, $< | InitialPos], [Space, $v, $e, $l, $o, $c, $i, $t, $y, $=, $< | Vel]] = string:split(binary_to_list(BinLine), ">"),
        [XStr, YStr] = string:split(lists:filter(fun(C) -> C =/= Space end, InitialPos), ","),
        [VelXStr, VelYStr] = string:split(lists:filter(fun(C) -> C =/= Space andalso C =/= $> end, Vel), ","),
        {{list_to_integer(XStr), list_to_integer(YStr)}, {list_to_integer(VelXStr), list_to_integer(VelYStr)}}
    end, string:split(Contents, "\r\n", all)),
    process_until_in_proximity(0, PointsToVelocity).

process_until_in_proximity(Seconds, PointsToVelocity) ->
    {Xs, Ys} = lists:foldl(fun({{TheX, TheY}, _}, {XsResult, YsResult}) ->
        {[TheX | XsResult], [TheY | YsResult]}
    end, {[], []}, PointsToVelocity),
    case {lists:max(Xs) - lists:min(Xs), lists:max(Ys) - lists:min(Ys)} of
        {Horizontal, Vertical} when Horizontal < 65 andalso Vertical < 65 ->
            {draw(Xs, Ys, [{X, Y} || {{X, Y}, _} <- PointsToVelocity]), Seconds};
        _ ->
            process_until_in_proximity(Seconds + 1, [{{X + VelX, Y + VelY}, {VelX, VelY}} || {{X, Y}, {VelX, VelY}} <- PointsToVelocity])
    end.

draw(Xs, Ys, Points) ->
    Picture = [[case lists:member({X, Y}, Points) of
        true -> $#;
        false -> $*
    end || X <- lists:seq(lists:min(Xs), lists:max(Xs))] || Y <- lists:seq(lists:min(Ys), lists:max(Ys))],
    file:write_file("special/day10", list_to_binary(string:join(Picture, "\n"))).