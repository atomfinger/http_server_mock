-record(response_definition, {
    status :: integer(),
    headers :: list({binary(), binary()}),
    body :: http_server_mock@types:response_body(),
    delay_ms :: gleam@option:option(integer())
}).
