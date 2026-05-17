-record(mock_server_started, {
    port :: integer(),
    handle :: gleam@dynamic:dynamic_(),
    adapter :: http_server_mock@server_adapter:server_adapter()
}).
