-module(ebt_task).

-compile({parse_transform, do}).

-export([perform/4]).

-callback(perform(atom(), file:name(), ebt_config:config()) -> error_m:monad(any())).

-spec(perform(atom(), [atom()], file:name(), ebt_config:config()) ->
    error_m:monad([atom()])).
perform(Level, Targets, Dir, Config) ->
    perform(Level, Targets, Dir, Config, []).

perform(_Level, [], _Dir, _Config, Acc) -> {ok, Acc};
perform(Level, [Target | Targets], Dir, Config, Acc) ->
    case lists:member(Target, Acc) of
        true ->
            io:format("~p => ~s at ~s already done~n", [Level, Target, Dir]),
            perform(Level, Targets, Dir, Config, Acc);
        false ->
            io:format("~p => ~s at ~s~n", [Level, Target, Dir]),
            do([error_m ||
                {Module, Depends} <- ebt_target_mapping:get(Target, Config),
                DoneTargets <- perform(Level, Depends, Dir, Config, Acc),
                io:format("~s:~n", [Target]),
                ebt:load_libraries(Config),
                Module:perform(Target, Dir, Config),
                perform(Level, Targets, Dir, Config, [Target | Acc] ++ DoneTargets)
            ])
    end.
