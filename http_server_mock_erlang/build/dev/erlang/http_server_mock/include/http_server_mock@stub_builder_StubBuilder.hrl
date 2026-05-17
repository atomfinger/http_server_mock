-record(stub_builder, {
    matcher :: gleam@option:option(http_server_mock@types:request_matcher()),
    response :: gleam@option:option(http_server_mock@types:response_definition()),
    id :: gleam@option:option(binary()),
    priority :: integer(),
    scenario :: gleam@option:option(http_server_mock@types:scenario_state())
}).
