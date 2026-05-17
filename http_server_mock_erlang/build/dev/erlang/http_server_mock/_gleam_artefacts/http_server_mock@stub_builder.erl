-module(http_server_mock@stub_builder).
-compile([no_auto_import, nowarn_unused_vars, nowarn_unused_function, nowarn_nomatch, inline]).
-define(FILEPATH, "src/http_server_mock/stub_builder.gleam").
-export([new/0, matching/2, responding_with/2, with_id/2, with_priority/2, in_scenario/2, when_state_is/2, then_transition_to/2, build/1]).
-export_type([with_matcher/0, without_matcher/0, with_response/0, without_response/0, stub_builder/2]).

-if(?OTP_RELEASE >= 27).
-define(MODULEDOC(Str), -moduledoc(Str)).
-define(DOC(Str), -doc(Str)).
-else.
-define(MODULEDOC(Str), -compile([])).
-define(DOC(Str), -compile([])).
-endif.

-type with_matcher() :: any().

-type without_matcher() :: any().

-type with_response() :: any().

-type without_response() :: any().

-opaque stub_builder(KQH, KQI) :: {stub_builder,
        gleam@option:option(http_server_mock@types:request_matcher()),
        gleam@option:option(http_server_mock@types:response_definition()),
        gleam@option:option(binary()),
        integer(),
        gleam@option:option(http_server_mock@types:scenario_state())} |
    {gleam_phantom, KQH, KQI}.

-file("src/http_server_mock/stub_builder.gleam", 41).
?DOC(" Creates an empty stub builder with no matcher or response set.\n").
-spec new() -> stub_builder(without_matcher(), without_response()).
new() ->
    {stub_builder, none, none, none, 5, none}.

-file("src/http_server_mock/stub_builder.gleam", 52).
?DOC(" Sets the request matcher, transitioning the builder to `WithMatcher`.\n").
-spec matching(
    stub_builder(any(), KQM),
    http_server_mock@types:request_matcher()
) -> stub_builder(with_matcher(), KQM).
matching(Builder, Request_matcher) ->
    {stub_builder,
        {some, Request_matcher},
        erlang:element(3, Builder),
        erlang:element(4, Builder),
        erlang:element(5, Builder),
        erlang:element(6, Builder)}.

-file("src/http_server_mock/stub_builder.gleam", 60).
?DOC(" Sets the response definition, transitioning the builder to `WithResponse`.\n").
-spec responding_with(
    stub_builder(KQR, any()),
    http_server_mock@types:response_definition()
) -> stub_builder(KQR, with_response()).
responding_with(Builder, Response_def) ->
    {stub_builder,
        erlang:element(2, Builder),
        {some, Response_def},
        erlang:element(4, Builder),
        erlang:element(5, Builder),
        erlang:element(6, Builder)}.

-file("src/http_server_mock/stub_builder.gleam", 71).
?DOC(
    " Assigns a custom ID to this stub.\n"
    "\n"
    " IDs are used with `remove_stub` to unregister a specific stub. If not set,\n"
    " a unique ID is generated automatically.\n"
).
-spec with_id(stub_builder(KQX, KQY), binary()) -> stub_builder(KQX, KQY).
with_id(Builder, Id) ->
    {stub_builder,
        erlang:element(2, Builder),
        erlang:element(3, Builder),
        {some, Id},
        erlang:element(5, Builder),
        erlang:element(6, Builder)}.

-file("src/http_server_mock/stub_builder.gleam", 81).
?DOC(
    " Sets the priority for this stub.\n"
    "\n"
    " Lower values win when multiple stubs match a request. Defaults to `5`.\n"
).
-spec with_priority(stub_builder(KRD, KRE), integer()) -> stub_builder(KRD, KRE).
with_priority(Builder, Priority) ->
    {stub_builder,
        erlang:element(2, Builder),
        erlang:element(3, Builder),
        erlang:element(4, Builder),
        Priority,
        erlang:element(6, Builder)}.

-file("src/http_server_mock/stub_builder.gleam", 92).
?DOC(
    " Places this stub inside the named scenario.\n"
    "\n"
    " Scenarios allow a sequence of stubs to fire in order: the first time the\n"
    " matcher fires it transitions state; subsequent calls match the next stub.\n"
).
-spec in_scenario(stub_builder(KRJ, KRK), binary()) -> stub_builder(KRJ, KRK).
in_scenario(Builder, Name) ->
    Scenario = case erlang:element(6, Builder) of
        none ->
            {scenario_state, Name, none, none};

        {some, Existing} ->
            {scenario_state,
                Name,
                erlang:element(3, Existing),
                erlang:element(4, Existing)}
    end,
    {stub_builder,
        erlang:element(2, Builder),
        erlang:element(3, Builder),
        erlang:element(4, Builder),
        erlang:element(5, Builder),
        {some, Scenario}}.

-file("src/http_server_mock/stub_builder.gleam", 104).
?DOC(" Makes this stub only fire when the scenario is in the given state.\n").
-spec when_state_is(stub_builder(KRP, KRQ), binary()) -> stub_builder(KRP, KRQ).
when_state_is(Builder, State) ->
    Scenario = case erlang:element(6, Builder) of
        none ->
            {scenario_state, <<""/utf8>>, {some, State}, none};

        {some, Existing} ->
            {scenario_state,
                erlang:element(2, Existing),
                {some, State},
                erlang:element(4, Existing)}
    end,
    {stub_builder,
        erlang:element(2, Builder),
        erlang:element(3, Builder),
        erlang:element(4, Builder),
        erlang:element(5, Builder),
        {some, Scenario}}.

-file("src/http_server_mock/stub_builder.gleam", 117).
?DOC(" Transitions the scenario to the given state after this stub fires.\n").
-spec then_transition_to(stub_builder(KRV, KRW), binary()) -> stub_builder(KRV, KRW).
then_transition_to(Builder, New_state) ->
    Scenario = case erlang:element(6, Builder) of
        none ->
            {scenario_state, <<""/utf8>>, none, {some, New_state}};

        {some, Existing} ->
            {scenario_state,
                erlang:element(2, Existing),
                erlang:element(3, Existing),
                {some, New_state}}
    end,
    {stub_builder,
        erlang:element(2, Builder),
        erlang:element(3, Builder),
        erlang:element(4, Builder),
        erlang:element(5, Builder),
        {some, Scenario}}.

-file("src/http_server_mock/stub_builder.gleam", 153).
-spec generate_id() -> binary().
generate_id() ->
    <<"stub_"/utf8, (erlang:integer_to_binary(erlang:unique_integer()))/binary>>.

-file("src/http_server_mock/stub_builder.gleam", 135).
?DOC(
    " Builds the concrete `Stub` from this builder.\n"
    "\n"
    " Only callable when both `matching` and `responding_with` have been called —\n"
    " the phantom types enforce this at compile time.\n"
    "\n"
    " Pass the result to `http_server_mock.with_stub` or `http_server_mock.add_stub`.\n"
).
-spec build(stub_builder(with_matcher(), with_response())) -> http_server_mock@types:stub().
build(Builder) ->
    Matcher@1 = case erlang:element(2, Builder) of
        {some, Matcher} -> Matcher;
        _assert_fail ->
            erlang:error(#{gleam_error => let_assert,
                        message => <<"Pattern match failed, no pattern matched the value."/utf8>>,
                        file => <<?FILEPATH/utf8>>,
                        module => <<"http_server_mock/stub_builder"/utf8>>,
                        function => <<"build"/utf8>>,
                        line => 136,
                        value => _assert_fail,
                        start => 4800,
                        'end' => 4842,
                        pattern_start => 4811,
                        pattern_end => 4824})
    end,
    Response@1 = case erlang:element(3, Builder) of
        {some, Response} -> Response;
        _assert_fail@1 ->
            erlang:error(#{gleam_error => let_assert,
                        message => <<"Pattern match failed, no pattern matched the value."/utf8>>,
                        file => <<?FILEPATH/utf8>>,
                        module => <<"http_server_mock/stub_builder"/utf8>>,
                        function => <<"build"/utf8>>,
                        line => 137,
                        value => _assert_fail@1,
                        start => 4845,
                        'end' => 4889,
                        pattern_start => 4856,
                        pattern_end => 4870})
    end,
    Id@1 = case erlang:element(4, Builder) of
        {some, Id} ->
            Id;

        none ->
            generate_id()
    end,
    {stub,
        Id@1,
        erlang:element(5, Builder),
        Matcher@1,
        Response@1,
        erlang:element(6, Builder)}.
