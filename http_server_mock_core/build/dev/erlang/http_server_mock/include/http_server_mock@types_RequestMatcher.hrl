-record(request_matcher, {
    method :: gleam@option:option(gleam@http:method()),
    path :: gleam@option:option(http_server_mock@types:string_matcher()),
    query_params :: list({binary(), http_server_mock@types:string_matcher()}),
    headers :: list({binary(), http_server_mock@types:string_matcher()}),
    body :: http_server_mock@types:body_matcher()
}).
