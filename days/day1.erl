-module(day1).
-export([easy/0, hard/0]).

easy() ->
    {ok, Contents} = file:read_file("input/day1"),
    analize_input(binary_to_list(Contents), 0).
    
analize_input([], Result) ->
    Result;
analize_input(Input, Result) ->
    [[Operator | Number], Rest] = case lists:member($\n, Input) of
        true -> string:split(Input, "\n");
        false -> [Input, []]
    end,
    NewResult = case Operator of
        $+ -> Result + list_to_integer(Number);
        $- -> Result - list_to_integer(Number)
    end,
    analize_input(Rest, NewResult).

hard() ->
    find_duplicate_frequency([], sets:new(), 0).

find_duplicate_frequency([], Found, Frequency) ->
    {ok, Contents} = file:read_file("input/day1"),
    find_duplicate_frequency(binary_to_list(Contents), Found, Frequency);
find_duplicate_frequency(Input, Found, Frequency) ->
    [[Operator | Number], Rest] = case lists:member($\n, Input) of
        true -> string:split(Input, "\n");
        false -> [Input, []]
    end,
    NewFrequency = case Operator of
        $+ -> Frequency + list_to_integer(Number);
        $- -> Frequency - list_to_integer(Number)
    end,
    case sets:is_element(NewFrequency, Found) of
        true ->
            NewFrequency;
        false ->
            find_duplicate_frequency(Rest, sets:add_element(NewFrequency, Found), NewFrequency)
    end.