-record(stub, {
    id :: binary(),
    priority :: integer(),
    matcher :: http_server_mock@types:request_matcher(),
    response :: http_server_mock@types:response_definition(),
    scenario :: gleam@option:option(http_server_mock@types:scenario_state())
}).
