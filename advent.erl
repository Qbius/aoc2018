-module(advent).
-export([get/1]).

compile(Filename) ->
    case compile:file(Filename) of
        {ok, Module} ->
            code:purge(Module),
            code:load_file(Module),
            Module;
        error ->
            false
    end.

get(DayNumber) ->
    Filename = "days/day" ++ integer_to_list(DayNumber) ++ ".erl",
    case compile(Filename) of
        false -> 
            "Couldn't compile " ++ Filename;
        Module ->
            {Easy, Hard} = Module:answer(), 
            io_lib:format("1st part: ~p~n2nd part: ~p~n", [Easy, Hard])
    end.