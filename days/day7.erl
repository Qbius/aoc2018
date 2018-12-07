-module(day7).
-export([answer/0]).

answer() ->
    {ok, Contents} = file:read_file("input/day7"),
    Lines = lists:map(fun binary_to_list/1, string:split(Contents, "\r\n", all)),
    {StepList, StepReqs} = lists:foldl(fun([$S, $t, $e, $p, _Space1 | Rest], {AllSteps, StepReq}) ->
        [[Req], [Step, _Space2, $c, $a, $n, _Space3, $b, $e, $g, $i, $n, $.]] = string:split(Rest, " must be finished before step "),
        {[Req, Step | AllSteps], StepReq#{Step => [Req | maps:get(Step, StepReq, [])]}}
    end, {[], #{}}, Lines),
    {commence_steps(lists:usort(StepList), StepReqs, []), commence_simultaneous_steps(0, lists:usort(StepList), StepReqs, [], lists:duplicate(5, {0, nostep}))}.

commence_steps([], _, Completed) ->
    lists:reverse(Completed);
commence_steps(StepList, StepReqs, Completed) ->
    [Step] = first_n_eligible_steps(1, StepList, StepReqs, Completed),
    commence_steps(StepList -- [Step], StepReqs, [Step | Completed]).

first_n_eligible_steps(0, _, _, _) ->
    [];
first_n_eligible_steps(_, [], _, _) ->
    [];
first_n_eligible_steps(N, [Step | T], StepReqs, Completed) ->
    case lists:all(fun(Req) -> lists:member(Req, Completed) end, maps:get(Step, StepReqs, [])) of
        true -> [Step | first_n_eligible_steps(N - 1, T, StepReqs, Completed)];
        false -> first_n_eligible_steps(N, T, StepReqs, Completed)
    end.

commence_simultaneous_steps(Second, [], _, Completed, _) ->
    {Second, Completed};
commence_simultaneous_steps(Second, StepList, StepReqs, PrevCompleted, Workers) ->
    AvailableWorkers = lists:filter(fun({0, _}) -> true; ({1, _}) -> true; (_) -> false end, Workers),
    Completed = [S || {1, S} <- AvailableWorkers] ++ PrevCompleted,
    NextSteps = first_n_eligible_steps(length(AvailableWorkers), StepList, StepReqs, Completed),
    {ProcessedWorkers, []} = lists:foldl(fun(I, {ProcWorkersResult, Steps}) ->
        {NextStep, Rest} = case Steps of
            [Step | T] -> {{60 + Step - $A, Step}, T};
            [] -> {{0, nostep}, []}
        end,
        case lists:nth(I, Workers) of
            {0, _} -> {[NextStep | ProcWorkersResult], Rest};
            {1, _} -> {[NextStep | ProcWorkersResult], Rest};
            {N, S} -> {[{N - 1, S} | ProcWorkersResult], Rest}
        end
    end, {[], NextSteps}, lists:seq(1, length(Workers))),
    io:format("~p~n", [ProcessedWorkers]),
    commence_simultaneous_steps(Second + 1, StepList -- NextSteps, StepReqs, Completed, lists:reverse(ProcessedWorkers)).