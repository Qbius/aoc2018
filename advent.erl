-module(advent).
-export([start/0]).

get_last_day() ->
    lists:nth(1, lists:reverse(lists:sort(filelib:wildcard("days/day*.erl")))).

compile(Filename) ->
    case compile:file(Filename) of
        {ok, Module} ->
            code:purge(Module),
            code:load_file(Module),
            Module;
        {error, _Errors} ->
            false
    end.

start() ->
    Filename = get_last_day(),
    io:fwrite(case compile(Filename) of
        false -> "Couldn't compile " ++ Filename;
        Module -> io_lib:format("1st part: ~p~n2nd part: ~p~n", [Module:easy(), Module:hard()])
    end).