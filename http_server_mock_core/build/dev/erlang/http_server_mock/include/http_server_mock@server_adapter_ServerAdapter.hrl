-record(server_adapter, {
    start :: fun((integer()) -> {ok, {integer(), gleam@dynamic:dynamic_()}} |
        {error, binary()}),
    stop :: fun((gleam@dynamic:dynamic_()) -> nil),
    add_stub :: fun((gleam@dynamic:dynamic_(), binary()) -> {ok, binary()} |
        {error, binary()}),
    remove_stub :: fun((gleam@dynamic:dynamic_(), binary()) -> nil),
    clear_stubs :: fun((gleam@dynamic:dynamic_()) -> nil),
    get_stubs :: fun((gleam@dynamic:dynamic_()) -> binary()),
    get_requests :: fun((gleam@dynamic:dynamic_()) -> binary()),
    clear_requests :: fun((gleam@dynamic:dynamic_()) -> nil)
}).
