-module(day6).
-export([answer/0]).

answer() ->
    {ok, Contents} = file:read_file("input/day6"),
    {Xs, Ys} = prepare_lists(string:split(Contents, "\r\n", all), [], []),
    Coords = {lists:min(Xs), lists:min(Ys), lists:max(Xs), lists:max(Xs)},
    PlacesList = lists:zip(lists:seq($A, $A + length(Xs) - 1), lists:zip(Xs, Ys)),
    visualize(Coords, PlacesList),
    AreasMap = field(Coords, PlacesList),
    {find_largest_finite_area(AreasMap, Coords), proximity_less_than(Coords, PlacesList, 10000)}.

prepare_lists([Line | T], Xs, Ys) ->
    [X, Y] = string:split(binary_to_list(Line), ", "),
    prepare_lists(T, [list_to_integer(X) | Xs], [list_to_integer(Y) | Ys]);
prepare_lists([], Xs, Ys) ->
    {Xs, Ys}.

field({XMin, YMin, XMax, YMax}, Places) ->
    IDToPoint = concurrent:map(fun({X, Y}) ->
        ManhattanDistances = [{abs(X - PlaceX) + abs(Y - PlaceY), ID} || {ID, {PlaceX, PlaceY}} <- Places],
        {Distance, ClosestID} = lists:min(ManhattanDistances),
        {case lists:filter(fun({Dis, _}) when Dis =:= Distance -> true; (_) -> false end, ManhattanDistances) of
            [{Distance, ClosestID}] -> ClosestID;
            _ -> $0
        end, {X, Y}}
    end, [{X, Y} || Y <- lists:seq(YMin, YMax), X <- lists:seq(XMin, XMax)]),
    lists:foldl(fun({ID, Point}, ResultMap) ->
        ResultMap#{ID => [Point | maps:get(ID, ResultMap, [])]}
    end, #{}, IDToPoint).

find_largest_finite_area(AreasMap, {XMin, YMin, XMax, YMax}) ->
    OnlyFinites = maps:filter(fun
        ($0, _) ->
            false;
        (_, Points) ->
            lists:all(fun
                ({X, Y}) when X =/= XMin andalso X =/= XMax andalso Y =/= YMin andalso Y =/= YMax -> true;
                (_) -> false            
            end, Points)
    end, AreasMap),
    {Area, _MaxID} = lists:max(lists:map(fun(IDKey) ->
        {length(maps:get(IDKey, OnlyFinites)), IDKey}
    end, maps:keys(OnlyFinites))),
    Area.

visualize({XMin, YMin, XMax, YMax}, Places) ->
    IDsField = concurrent:map(fun(PointsLine) ->
        concurrent:map(fun({X, Y}) ->
            ManhattanDistances = [{abs(X - PlaceX) + abs(Y - PlaceY), ID} || {ID, {PlaceX, PlaceY}} <- Places],
            {Distance, ClosestID} = lists:min(ManhattanDistances),
            case lists:filter(fun({Dis, _}) when Dis =:= Distance -> true; (_) -> false end, ManhattanDistances) of
                [{Distance, ClosestID}] -> ClosestID;
                _ -> $0
            end
        end, PointsLine)
    end, [[{X, Y} || X <- lists:seq(XMin, XMax)] || Y <- lists:seq(YMin, YMax)]),
    file:write_file("special/day6", list_to_binary(string:join(IDsField, "\n"))).

proximity_less_than({XMin, YMin, XMax, YMax}, Places, Proximity) ->
    length(lists:filter(fun({X, Y}) ->
        (lists:foldl(fun({_, {PlaceX, PlaceY}}, Sum) ->
            Sum + abs(X - PlaceX) + abs(Y - PlaceY)
       end, 0, Places)) < Proximity
    end, [{A, B} || B <- lists:seq(YMin, YMax), A <- lists:seq(XMin, XMax)])).