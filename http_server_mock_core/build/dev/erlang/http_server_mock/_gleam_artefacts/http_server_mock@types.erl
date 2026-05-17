-module(http_server_mock@types).
-compile([no_auto_import, nowarn_unused_vars, nowarn_unused_function, nowarn_nomatch, inline]).
-define(FILEPATH, "src/http_server_mock/types.gleam").
-export_type([string_matcher/0, body_matcher/0, request_matcher/0, response_body/0, response_definition/0, scenario_state/0, stub/0, recorded_request/0]).

-if(?OTP_RELEASE >= 27).
-define(MODULEDOC(Str), -moduledoc(Str)).
-define(DOC(Str), -doc(Str)).
-else.
-define(MODULEDOC(Str), -compile([])).
-define(DOC(Str), -compile([])).
-endif.

?MODULEDOC(
    " Core data types shared across all modules.\n"
    "\n"
    " Most of these types are produced by the builder modules (`matcher`,\n"
    " `response`, `stub`) and consumed by the server or `verify`. You generally\n"
    " interact with them through those builders rather than constructing them\n"
    " directly.\n"
).

-type string_matcher() :: {exact, binary()} |
    {contains, binary()} |
    {prefix, binary()} |
    {suffix, binary()} |
    any_string.

-type body_matcher() :: any_body |
    {exact_body, binary()} |
    {contains_body, binary()} |
    {json_body, binary()}.

-type request_matcher() :: {request_matcher,
        gleam@option:option(gleam@http:method()),
        gleam@option:option(string_matcher()),
        list({binary(), string_matcher()}),
        list({binary(), string_matcher()}),
        body_matcher()}.

-type response_body() :: {string_body, binary()} |
    {raw_json_body, binary()} |
    {bytes_body, bitstring()} |
    no_body.

-type response_definition() :: {response_definition,
        integer(),
        list({binary(), binary()}),
        response_body(),
        gleam@option:option(integer())}.

-type scenario_state() :: {scenario_state,
        binary(),
        gleam@option:option(binary()),
        gleam@option:option(binary())}.

-type stub() :: {stub,
        binary(),
        integer(),
        request_matcher(),
        response_definition(),
        gleam@option:option(scenario_state())}.

-type recorded_request() :: {recorded_request,
        binary(),
        gleam@http:method(),
        binary(),
        gleam@option:option(binary()),
        gleam@dict:dict(binary(), binary()),
        binary(),
        integer(),
        gleam@option:option(binary())}.


