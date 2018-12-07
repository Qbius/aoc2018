-module(day7).
-export([answer/0]).

answer() ->
    {ok, Contents} = file:read_file("input/day7"),
    Lines = lists:map(fun binary_to_list/1, string:split(Contents, "\n", all)),
    {StepList, StepReqs} = lists:foldl(fun([$S, $t, $e, $p, _Space1 | Rest], {AllSteps, StepReq}) ->
        [[Req], [Step, _Space2, $c, $a, $n, _Space3, $b, $e, $g, $i, $n, $.]] = string:split(Rest, " must be finished before step "),
        {[Req, Step | AllSteps], StepReq#{Step => [Req | maps:get(Step, StepReq, [])]}}
    end, {[], #{}}, Lines),
    {commence_steps(lists:usort(StepList), StepReqs, []), ok}.

commence_steps([], _, Completed) ->
    lists:reverse(Completed);
commence_steps(StepList, StepReqs, Completed) ->
    case first_eligible_step(StepList, StepReqs, Completed) of
        eh ->
            io:format("~p~n~p~n~p~n", [StepList, StepReqs, Completed]);
        Step -> 
            commence_steps(StepList -- [Step], StepReqs, [Step | Completed])
    end.

first_eligible_step([Step | T], StepReqs, Completed) ->
    case lists:all(fun(Req) -> lists:member(Req, Completed) end, maps:get(Step, StepReqs, [])) of
        true -> Step;
        false -> first_eligible_step(T, StepReqs, Completed)
    end;
first_eligible_step([], _, _) ->
    eh.