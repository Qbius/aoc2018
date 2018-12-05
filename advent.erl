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
    io:fwrite(case lists:all(fun(Res) -> Res =/= false end, lists:map(fun compile/1, filelib:wildcard("helpers/*.erl"))) of
        true -> 
            Filename = "days/day" ++ integer_to_list(DayNumber) ++ ".erl",
            case compile(Filename) of
                false -> 
                    "Couldn't compile " ++ Filename;
                Module ->
                    Begin = os:system_time(second),
                    {Easy, Hard} = Module:answer(), 
                    End = os:system_time(second),
                    io_lib:format("1st part: ~p~n2nd part: ~p~nElapsed time: ~ps~n", [Easy, Hard, End - Begin])
            end;
        false ->
            "Couldn't compile some of the helper modules"
    end),
    done.