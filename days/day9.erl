-module(day9).
-export([erl_modulo/2, answer/0]).

answer() ->
    {ok, Contents} = file:read_file("input/day9"),
    Trim = fun(Str) -> list_to_integer([C || C <- Str, C >= $0 andalso C =< $9]) end,
    [Players, LastMarble] = string:split(binary_to_list(Contents), "players; last marble is worth"),
    game(1, {[{0, Number} || Number <- lists:seq(1, Trim(Players))], Trim(LastMarble)}, {1, [0], 1, 1}).

game(_, {Players, LastMarble}, {Turn, _, _, _}) when LastMarble + 1 =:= Turn ->
    {Score, _} = lists:max(Players),
    Score;
game(CurrentPlayer, {Players, LastMarble}, {Turn, Circle, Length, CurrentMarble}) when Turn rem 23 =:= 0 ->
    io:format("~p~n", [Turn]),
    ToBeRemoved = erl_modulo(CurrentMarble - 7, Length),
    {Score, CurrentPlayer} = lists:keyfind(CurrentPlayer, 2, Players),
    NewPlayers = lists:keyreplace(CurrentPlayer, 2, Players, {Score + Turn + lists:nth(ToBeRemoved, Circle), CurrentPlayer}),
    {First, Second} = lists:split(ToBeRemoved, Circle),
    NewCircle = lists:droplast(First) ++ Second,
    game(erl_modulo(CurrentPlayer + 1, length(Players)), {NewPlayers, LastMarble}, {Turn + 1, NewCircle, Length - 1, erl_modulo(ToBeRemoved, Length - 1)});
game(CurrentPlayer, {Players, _} = GameInfo, {Turn, Circle, Length, CurrentMarble}) ->
    io:format("~p~n", [Turn]),
    NewCurrent = erl_modulo(CurrentMarble + 2, Length),
    {First, Second} = lists:split(NewCurrent - 1, Circle),
    game(erl_modulo(CurrentPlayer + 1, length(Players)), GameInfo, {Turn + 1, case First of
        [] -> Second ++ [Turn];
        _ -> First ++ [Turn | Second]
    end, Length + 1, NewCurrent}).

erl_modulo(A, B) ->
    case modulo(A, B) of
        0 -> B;
        Else -> Else
    end.

modulo(A, B) when A > 0 ->   
   A rem B;
modulo(A, B) when A < 0 ->   
    K = (-A div B) + 1,
    (A + K * B) rem B;
modulo(0, _) -> 
    0.