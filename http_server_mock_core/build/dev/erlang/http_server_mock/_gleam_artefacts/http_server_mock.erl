-module(http_server_mock).
-compile([no_auto_import, nowarn_unused_vars, nowarn_unused_function, nowarn_nomatch, inline]).
-define(FILEPATH, "src/http_server_mock.gleam").
-export([new/1, with_port/2, start/1, stop/1, base_url/1, add_stub/2, with_stub/2, remove_stub/2, reset_stubs/1, recorded_requests/1, reset_requests/1, reset/1, unmatched_requests/1]).

-if(?OTP_RELEASE >= 27).
-define(MODULEDOC(Str), -moduledoc(Str)).
-define(DOC(Str), -doc(Str)).
-else.
-define(MODULEDOC(Str), -compile([])).
-define(DOC(Str), -compile([])).
-endif.

?MODULEDOC(
    " Start a mock HTTP server, register stubs that describe how it should respond\n"
    " to incoming requests, make real HTTP calls against it from your tests, then\n"
    " inspect the recorded call history to verify what happened.\n"
    "\n"
    " Pass a runtime adapter from `http_server_mock_erlang` or `http_server_mock_js`\n"
    " to `new/1` to select the underlying server implementation.\n"
    "\n"
    " ```gleam\n"
    " import gleam/http\n"
    " import http_server_mock\n"
    " import http_server_mock_erlang  // or http_server_mock_js\n"
    " import http_server_mock/matcher\n"
    " import http_server_mock/response\n"
    " import http_server_mock/stub_builder\n"
    " import http_server_mock/verify\n"
    "\n"
    " pub fn my_test() {\n"
    "   let server =\n"
    "     http_server_mock.new(http_server_mock_erlang.server())\n"
    "     |> http_server_mock.start()\n"
    "     |> http_server_mock.with_stub(\n"
    "       stub_builder.new()\n"
    "       |> stub_builder.matching(matcher.new() |> matcher.method(http.Get) |> matcher.path(\"/ping\"))\n"
    "       |> stub_builder.responding_with(response.ok())\n"
    "       |> stub_builder.build(),\n"
    "     )\n"
    "\n"
    "   // ... make HTTP requests to http_server_mock.base_url(server) ...\n"
    "\n"
    "   verify.called_times(server, matcher.new() |> matcher.path(\"/ping\"), 1)\n"
    "   http_server_mock.stop(server)\n"
    " }\n"
    " ```\n"
).

-file("src/http_server_mock.gleam", 70).
?DOC(
    " Creates a new server with default configuration (random free port).\n"
    "\n"
    " Pass the adapter from your runtime package — `http_server_mock_erlang.server()`\n"
    " or `http_server_mock_js.server()` — then chain `start` to launch.\n"
    "\n"
    " ```gleam\n"
    " let server =\n"
    "   http_server_mock.new(http_server_mock_erlang.server())\n"
    "   |> http_server_mock.start()\n"
    " ```\n"
).
-spec new(http_server_mock@server_adapter:server_adapter()) -> http_server_mock@internal@server:mock_server(http_server_mock@internal@server:not_started()).
new(Adapter) ->
    http_server_mock@internal@server:new(Adapter).

-file("src/http_server_mock.gleam", 78).
?DOC(
    " Overrides the port the server will bind to when started.\n"
    "\n"
    " Prefer the default (port 0) in tests so servers never conflict with each\n"
    " other or with other processes on the machine.\n"
).
-spec with_port(
    http_server_mock@internal@server:mock_server(http_server_mock@internal@server:not_started()),
    integer()
) -> http_server_mock@internal@server:mock_server(http_server_mock@internal@server:not_started()).
with_port(Mock_server, Port) ->
    http_server_mock@internal@server:with_port(Mock_server, Port).

-file("src/http_server_mock.gleam", 91).
?DOC(
    " Starts the mock HTTP server.\n"
    "\n"
    " Panics if the server could not be started (for example, if the requested\n"
    " port is already in use).\n"
    "\n"
    " Call `stop` when the server is no longer needed.\n"
).
-spec start(
    http_server_mock@internal@server:mock_server(http_server_mock@internal@server:not_started())
) -> http_server_mock@internal@server:mock_server(http_server_mock@internal@server:started()).
start(Mock_server) ->
    case http_server_mock@internal@server:start(Mock_server) of
        {ok, Started} ->
            Started;

        {error, Reason} ->
            erlang:error(#{gleam_error => panic,
                    message => (<<"Failed to start mock server: "/utf8,
                        Reason/binary>>),
                    file => <<?FILEPATH/utf8>>,
                    module => <<"http_server_mock"/utf8>>,
                    function => <<"start"/utf8>>,
                    line => 94})
    end.

-file("src/http_server_mock.gleam", 102).
?DOC(
    " Stops the mock server and releases the port it was bound to.\n"
    "\n"
    " The returned `MockServer(Stopped)` cannot be passed to any function that\n"
    " requires a running server, making accidental post-stop use a compile error.\n"
).
-spec stop(
    http_server_mock@internal@server:mock_server(http_server_mock@internal@server:started())
) -> http_server_mock@internal@server:mock_server(http_server_mock@internal@server:stopped()).
stop(Mock_server) ->
    http_server_mock@internal@server:stop(Mock_server).

-file("src/http_server_mock.gleam", 109).
?DOC(
    " Returns the base URL of the mock server, e.g. `\"http://localhost:54321\"`.\n"
    "\n"
    " Append your path to this when constructing request URLs in tests.\n"
).
-spec base_url(
    http_server_mock@internal@server:mock_server(http_server_mock@internal@server:started())
) -> binary().
base_url(Mock_server) ->
    http_server_mock@internal@server:base_url(Mock_server).

-file("src/http_server_mock.gleam", 120).
?DOC(
    " Registers a stub with the server.\n"
    "\n"
    " Build a `Stub` using `stub_builder.new() |> stub_builder.matching(...) |> stub_builder.responding_with(...) |> stub_builder.build()`,\n"
    " or construct one directly from `http_server_mock/types.{Stub}`.\n"
    "\n"
    " Returns `Ok(Nil)` on success, or `Error(reason)` if the stub could not be\n"
    " registered.\n"
).
-spec add_stub(
    http_server_mock@internal@server:mock_server(http_server_mock@internal@server:started()),
    http_server_mock@types:stub()
) -> {ok, nil} | {error, binary()}.
add_stub(Mock_server, Stub) ->
    case http_server_mock@internal@server:register(Mock_server, Stub) of
        {ok, _} ->
            {ok, nil};

        {error, Reason} ->
            {error, Reason}
    end.

-file("src/http_server_mock.gleam", 147).
?DOC(
    " Registers a stub with the server and returns the server for chaining.\n"
    "\n"
    " Build a `Stub` with `stub_builder` and pass it in:\n"
    "\n"
    " ```gleam\n"
    " let server =\n"
    "   http_server_mock.new()\n"
    "   |> http_server_mock.start()\n"
    "   |> http_server_mock.with_stub(\n"
    "     stub_builder.new()\n"
    "     |> stub_builder.matching(matcher.new() |> matcher.path(\"/ping\"))\n"
    "     |> stub_builder.responding_with(response.ok())\n"
    "     |> stub_builder.build(),\n"
    "   )\n"
    " ```\n"
    "\n"
    " Panics on registration failure. Use `add_stub` if you need to handle the error.\n"
).
-spec with_stub(
    http_server_mock@internal@server:mock_server(http_server_mock@internal@server:started()),
    http_server_mock@types:stub()
) -> http_server_mock@internal@server:mock_server(http_server_mock@internal@server:started()).
with_stub(Mock_server, Stub) ->
    case http_server_mock@internal@server:register(Mock_server, Stub) of
        {ok, _} ->
            Mock_server;

        {error, Reason} ->
            erlang:error(#{gleam_error => panic,
                    message => (<<"Failed to register stub: "/utf8,
                        Reason/binary>>),
                    file => <<?FILEPATH/utf8>>,
                    module => <<"http_server_mock"/utf8>>,
                    function => <<"with_stub"/utf8>>,
                    line => 153})
    end.

-file("src/http_server_mock.gleam", 160).
?DOC(
    " Removes the stub with the given ID from the server.\n"
    "\n"
    " Has no effect if no stub with that ID exists.\n"
).
-spec remove_stub(
    http_server_mock@internal@server:mock_server(http_server_mock@internal@server:started()),
    binary()
) -> nil.
remove_stub(Mock_server, Id) ->
    http_server_mock@internal@server:remove_stub(Mock_server, Id).

-file("src/http_server_mock.gleam", 167).
?DOC(
    " Removes all registered stubs from the server.\n"
    "\n"
    " Requests made after this call will return 404 until new stubs are registered.\n"
).
-spec reset_stubs(
    http_server_mock@internal@server:mock_server(http_server_mock@internal@server:started())
) -> nil.
reset_stubs(Mock_server) ->
    http_server_mock@internal@server:reset_stubs(Mock_server).

-file("src/http_server_mock.gleam", 176).
?DOC(
    " Returns all requests the server has received since it started (or since the\n"
    " last call to `reset_requests` or `reset`).\n"
    "\n"
    " Each `RecordedRequest` includes the method, path, query string, headers,\n"
    " body, timestamp, and the ID of the stub that matched it (if any).\n"
).
-spec recorded_requests(
    http_server_mock@internal@server:mock_server(http_server_mock@internal@server:started())
) -> {ok, list(http_server_mock@types:recorded_request())} | {error, binary()}.
recorded_requests(Mock_server) ->
    http_server_mock@internal@server:recorded_requests(Mock_server).

-file("src/http_server_mock.gleam", 186).
?DOC(
    " Clears the server's recorded request history.\n"
    "\n"
    " Useful when you want to assert on requests made during a specific part of a\n"
    " test without including earlier setup requests in the count.\n"
).
-spec reset_requests(
    http_server_mock@internal@server:mock_server(http_server_mock@internal@server:started())
) -> nil.
reset_requests(Mock_server) ->
    http_server_mock@internal@server:reset_requests(Mock_server).

-file("src/http_server_mock.gleam", 191).
?DOC(" Removes all stubs and clears the recorded request history in one call.\n").
-spec reset(
    http_server_mock@internal@server:mock_server(http_server_mock@internal@server:started())
) -> nil.
reset(Mock_server) ->
    http_server_mock@internal@server:reset(Mock_server).

-file("src/http_server_mock.gleam", 203).
?DOC(
    " Returns all requests the server received that did not match any registered stub.\n"
    "\n"
    " Useful for diagnosing test failures: if a request you expected to be handled\n"
    " shows up here, it means no stub matched it — check the matcher configuration.\n"
    "\n"
    " Each `RecordedRequest` includes the method, path, query string, headers,\n"
    " body, and timestamp. The `matched_stub_id` field will always be `None` for\n"
    " these requests.\n"
).
-spec unmatched_requests(
    http_server_mock@internal@server:mock_server(http_server_mock@internal@server:started())
) -> {ok, list(http_server_mock@types:recorded_request())} | {error, binary()}.
unmatched_requests(Mock_server) ->
    case http_server_mock@internal@server:recorded_requests(Mock_server) of
        {ok, Requests} ->
            {ok,
                gleam@list:filter(
                    Requests,
                    fun(Req) -> erlang:element(9, Req) =:= none end
                )};

        {error, Reason} ->
            {error, Reason}
    end.
