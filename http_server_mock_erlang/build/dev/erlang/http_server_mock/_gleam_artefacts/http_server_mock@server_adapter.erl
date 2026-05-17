-module(http_server_mock@server_adapter).
-compile([no_auto_import, nowarn_unused_vars, nowarn_unused_function, nowarn_nomatch, inline]).
-define(FILEPATH, "src/http_server_mock/server_adapter.gleam").
-export_type([server_adapter/0]).

-type server_adapter() :: {server_adapter,
        fun((integer()) -> {ok, {integer(), gleam@dynamic:dynamic_()}} |
            {error, binary()}),
        fun((gleam@dynamic:dynamic_()) -> nil),
        fun((gleam@dynamic:dynamic_(), binary()) -> {ok, binary()} |
            {error, binary()}),
        fun((gleam@dynamic:dynamic_(), binary()) -> nil),
        fun((gleam@dynamic:dynamic_()) -> nil),
        fun((gleam@dynamic:dynamic_()) -> binary()),
        fun((gleam@dynamic:dynamic_()) -> binary()),
        fun((gleam@dynamic:dynamic_()) -> nil)}.


