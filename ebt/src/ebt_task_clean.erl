-module(ebt_task_clean).

-compile({parse_transform, do}).
-behaviour(ebt_task).

-export([perform/3]).

perform(_Dir, Config, Defaults) ->
    do([ error_m ||
        delete(ebt_config:production_outdir(Config, Defaults)),
        delete(ebt_config:dist_outdir(Config, Defaults)),
        delete(ebt_config:test_outdir(Config, Defaults))
    ]).

delete({ok, Dir}) ->
    io:format("delete ~s~n", [Dir]),
    strikead_file:delete(Dir);
delete(E) -> E.