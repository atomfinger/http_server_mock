-module(http_server_mock@response).
-compile([no_auto_import, nowarn_unused_vars, nowarn_unused_function, nowarn_nomatch, inline]).
-define(FILEPATH, "src/http_server_mock/response.gleam").
-export([new/0, status/2, header/3, body/2, json_body/2, delay/2, ok/0, not_found/0, server_error/0]).

-if(?OTP_RELEASE >= 27).
-define(MODULEDOC(Str), -moduledoc(Str)).
-define(DOC(Str), -doc(Str)).
-else.
-define(MODULEDOC(Str), -compile([])).
-define(DOC(Str), -compile([])).
-endif.

?MODULEDOC(
    " Builder for `ResponseDefinition` — what the server sends back when a stub\n"
    " matches an incoming request.\n"
    "\n"
    " Start with `new()` (or one of the shorthand constructors) and pipe through\n"
    " the functions you need.\n"
    "\n"
    " ```gleam\n"
    " let resp =\n"
    "   response.new()\n"
    "   |> response.status(201)\n"
    "   |> response.header(\"x-request-id\", \"abc123\")\n"
    "   |> response.json_body(\"{\\\"id\\\":1,\\\"status\\\":\\\"created\\\"}\")\n"
    " ```\n"
).

-file("src/http_server_mock/response.gleam", 21).
?DOC(" Returns a new `ResponseDefinition` with status 200, no headers, and no body.\n").
-spec new() -> http_server_mock@types:response_definition().
new() ->
    {response_definition, 200, [], no_body, none}.

-file("src/http_server_mock/response.gleam", 26).
?DOC(" Sets the HTTP status code for the response.\n").
-spec status(http_server_mock@types:response_definition(), integer()) -> http_server_mock@types:response_definition().
status(Response_def, Code) ->
    {response_definition,
        Code,
        erlang:element(3, Response_def),
        erlang:element(4, Response_def),
        erlang:element(5, Response_def)}.

-file("src/http_server_mock/response.gleam", 34).
?DOC(" Adds a response header. Can be called multiple times to add several headers.\n").
-spec header(http_server_mock@types:response_definition(), binary(), binary()) -> http_server_mock@types:response_definition().
header(Response_def, Key, Value) ->
    {response_definition,
        erlang:element(2, Response_def),
        [{Key, Value} | erlang:element(3, Response_def)],
        erlang:element(4, Response_def),
        erlang:element(5, Response_def)}.

-file("src/http_server_mock/response.gleam", 46).
?DOC(" Sets the response body to a plain text string.\n").
-spec body(http_server_mock@types:response_definition(), binary()) -> http_server_mock@types:response_definition().
body(Response_def, Text) ->
    {response_definition,
        erlang:element(2, Response_def),
        erlang:element(3, Response_def),
        {string_body, Text},
        erlang:element(5, Response_def)}.

-file("src/http_server_mock/response.gleam", 55).
?DOC(
    " Sets the response body to a JSON string and automatically adds a\n"
    " `content-type: application/json` header.\n"
).
-spec json_body(http_server_mock@types:response_definition(), binary()) -> http_server_mock@types:response_definition().
json_body(Response_def, Json) ->
    With_content_type = {response_definition,
        erlang:element(2, Response_def),
        [{<<"content-type"/utf8>>, <<"application/json"/utf8>>} |
            erlang:element(3, Response_def)],
        erlang:element(4, Response_def),
        erlang:element(5, Response_def)},
    {response_definition,
        erlang:element(2, With_content_type),
        erlang:element(3, With_content_type),
        {raw_json_body, Json},
        erlang:element(5, With_content_type)}.

-file("src/http_server_mock/response.gleam", 70).
?DOC(
    " Delays the response by `milliseconds` before sending it.\n"
    "\n"
    " Useful for testing timeout handling or slow-network behaviour.\n"
).
-spec delay(http_server_mock@types:response_definition(), integer()) -> http_server_mock@types:response_definition().
delay(Response_def, Milliseconds) ->
    {response_definition,
        erlang:element(2, Response_def),
        erlang:element(3, Response_def),
        erlang:element(4, Response_def),
        {some, Milliseconds}}.

-file("src/http_server_mock/response.gleam", 78).
?DOC(" Returns a `ResponseDefinition` for HTTP 200 OK with no body.\n").
-spec ok() -> http_server_mock@types:response_definition().
ok() ->
    {response_definition, 200, [], no_body, none}.

-file("src/http_server_mock/response.gleam", 83).
?DOC(" Returns a `ResponseDefinition` for HTTP 404 Not Found with no body.\n").
-spec not_found() -> http_server_mock@types:response_definition().
not_found() ->
    {response_definition, 404, [], no_body, none}.

-file("src/http_server_mock/response.gleam", 88).
?DOC(" Returns a `ResponseDefinition` for HTTP 500 Internal Server Error with no body.\n").
-spec server_error() -> http_server_mock@types:response_definition().
server_error() ->
    {response_definition, 500, [], no_body, none}.
