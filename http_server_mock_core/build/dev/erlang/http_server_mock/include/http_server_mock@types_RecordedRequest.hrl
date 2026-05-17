-record(recorded_request, {
    id :: binary(),
    method :: gleam@http:method(),
    path :: binary(),
    'query' :: gleam@option:option(binary()),
    headers :: gleam@dict:dict(binary(), binary()),
    body :: binary(),
    timestamp_ms :: integer(),
    matched_stub_id :: gleam@option:option(binary())
}).
