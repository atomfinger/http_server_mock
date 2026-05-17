-module(http_server_mock_erlang).
-compile([no_auto_import, nowarn_unused_vars, nowarn_unused_function, nowarn_nomatch, inline]).
-define(FILEPATH, "src/http_server_mock_erlang.gleam").
-export([server/0]).

-if(?OTP_RELEASE >= 27).
-define(MODULEDOC(Str), -moduledoc(Str)).
-define(DOC(Str), -doc(Str)).
-else.
-define(MODULEDOC(Str), -compile([])).
-define(DOC(Str), -compile([])).
-endif.

-file("src/http_server_mock_erlang.gleam", 14).
?DOC(
    " Returns the Erlang/OTP server adapter.\n"
    "\n"
    " Pass this to `http_server_mock.new/1` to create a mock server backed by an\n"
    " OTP actor and a mist HTTP server:\n"
    "\n"
    " ```gleam\n"
    " let server =\n"
    "   http_server_mock.new(http_server_mock_erlang.server())\n"
    "   |> http_server_mock.start()\n"
    " ```\n"
).
-spec server() -> http_server_mock@server_adapter:server_adapter().
server() ->
    {server_adapter,
        fun http_server_mock@internal@server_impl:start_server/1,
        fun http_server_mock@internal@server_impl:stop_server/1,
        fun http_server_mock@internal@server_impl:add_stub/2,
        fun http_server_mock@internal@server_impl:remove_stub/2,
        fun http_server_mock@internal@server_impl:clear_stubs/1,
        fun http_server_mock@internal@server_impl:get_stubs/1,
        fun http_server_mock@internal@server_impl:get_requests/1,
        fun http_server_mock@internal@server_impl:clear_requests/1}.
