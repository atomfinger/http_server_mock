-module(http_server_mock@internal@json_codec_test).
-compile([no_auto_import, nowarn_unused_vars, nowarn_unused_function, nowarn_nomatch, inline]).
-define(FILEPATH, "test/http_server_mock/internal/json_codec_test.gleam").
-export([encode_decode_minimal_stub_test/0, encode_decode_stub_with_method_and_path_test/0, encode_decode_stub_with_all_path_matchers_test/0, encode_decode_stub_with_query_params_test/0, encode_decode_stub_with_headers_test/0, encode_decode_stub_with_body_matchers_test/0, encode_decode_stub_with_response_headers_test/0, encode_decode_stub_with_string_body_test/0, encode_decode_stub_with_delay_test/0, encode_decode_stub_with_scenario_test/0, encode_decode_multiple_stubs_test/0, decode_invalid_json_returns_error_test/0, encode_decode_recorded_requests_test/0]).

-if(?OTP_RELEASE >= 27).
-define(MODULEDOC(Str), -moduledoc(Str)).
-define(DOC(Str), -doc(Str)).
-else.
-define(MODULEDOC(Str), -compile([])).
-define(DOC(Str), -compile([])).
-endif.

?MODULEDOC(false).

-file("test/http_server_mock/internal/json_codec_test.gleam", 14).
?DOC(false).
-spec roundtrip_stub(http_server_mock@types:stub()) -> http_server_mock@types:stub().
roundtrip_stub(The_stub) ->
    Json_string = http_server_mock@internal@json_codec:encode_stub(The_stub),
    Decoded@1 = case http_server_mock@internal@json_codec:decode_stub(
        Json_string
    ) of
        {ok, Decoded} -> Decoded;
        _assert_fail ->
            erlang:error(#{gleam_error => let_assert,
                        message => <<"Pattern match failed, no pattern matched the value."/utf8>>,
                        file => <<?FILEPATH/utf8>>,
                        module => <<"http_server_mock/internal/json_codec_test"/utf8>>,
                        function => <<"roundtrip_stub"/utf8>>,
                        line => 16,
                        value => _assert_fail,
                        start => 479,
                        'end' => 539,
                        pattern_start => 490,
                        pattern_end => 501})
    end,
    Decoded@1.

-file("test/http_server_mock/internal/json_codec_test.gleam", 20).
?DOC(false).
-spec encode_decode_minimal_stub_test() -> nil.
encode_decode_minimal_stub_test() ->
    The_stub = begin
        _pipe = http_server_mock@stub_builder:new(),
        _pipe@1 = http_server_mock@stub_builder:matching(
            _pipe,
            http_server_mock@matcher:new()
        ),
        _pipe@2 = http_server_mock@stub_builder:responding_with(
            _pipe@1,
            http_server_mock@response:ok()
        ),
        _pipe@3 = http_server_mock@stub_builder:with_id(
            _pipe@2,
            <<"test-id"/utf8>>
        ),
        http_server_mock@stub_builder:build(_pipe@3)
    end,
    Roundtrip_result = roundtrip_stub(The_stub),
    _assert_subject = erlang:element(2, Roundtrip_result),
    _assert_subject@1 = <<"test-id"/utf8>>,
    case _assert_subject =:= _assert_subject@1 of
        true -> nil;
        false -> erlang:error(#{gleam_error => assert,
                message => <<"Assertion failed."/utf8>>,
                file => <<?FILEPATH/utf8>>,
                module => <<"http_server_mock/internal/json_codec_test"/utf8>>,
                function => <<"encode_decode_minimal_stub_test"/utf8>>,
                line => 28,
                kind => binary_operator,
                operator => '==',
                left => #{kind => expression,
                    value => _assert_subject,
                    start => 857,
                    'end' => 876
                    },
                right => #{kind => literal,
                    value => _assert_subject@1,
                    start => 880,
                    'end' => 889
                    },
                start => 850,
                'end' => 889,
                expression_start => 857})
    end,
    _assert_subject@2 = erlang:element(2, erlang:element(5, Roundtrip_result)),
    _assert_subject@3 = 200,
    case _assert_subject@2 =:= _assert_subject@3 of
        true -> nil;
        false -> erlang:error(#{gleam_error => assert,
                message => <<"Assertion failed."/utf8>>,
                file => <<?FILEPATH/utf8>>,
                module => <<"http_server_mock/internal/json_codec_test"/utf8>>,
                function => <<"encode_decode_minimal_stub_test"/utf8>>,
                line => 29,
                kind => binary_operator,
                operator => '==',
                left => #{kind => expression,
                    value => _assert_subject@2,
                    start => 899,
                    'end' => 931
                    },
                right => #{kind => literal,
                    value => _assert_subject@3,
                    start => 935,
                    'end' => 938
                    },
                start => 892,
                'end' => 938,
                expression_start => 899})
    end.

-file("test/http_server_mock/internal/json_codec_test.gleam", 32).
?DOC(false).
-spec encode_decode_stub_with_method_and_path_test() -> nil.
encode_decode_stub_with_method_and_path_test() ->
    The_stub = begin
        _pipe = http_server_mock@stub_builder:new(),
        _pipe@3 = http_server_mock@stub_builder:matching(
            _pipe,
            begin
                _pipe@1 = http_server_mock@matcher:new(),
                _pipe@2 = http_server_mock@matcher:method(_pipe@1, post),
                http_server_mock@matcher:path(_pipe@2, <<"/api/data"/utf8>>)
            end
        ),
        _pipe@5 = http_server_mock@stub_builder:responding_with(
            _pipe@3,
            begin
                _pipe@4 = http_server_mock@response:new(),
                http_server_mock@response:status(_pipe@4, 201)
            end
        ),
        _pipe@6 = http_server_mock@stub_builder:with_id(
            _pipe@5,
            <<"post-stub"/utf8>>
        ),
        http_server_mock@stub_builder:build(_pipe@6)
    end,
    Roundtrip_result = roundtrip_stub(The_stub),
    _assert_subject = erlang:element(2, erlang:element(4, Roundtrip_result)),
    _assert_subject@1 = {some, post},
    case _assert_subject =:= _assert_subject@1 of
        true -> nil;
        false -> erlang:error(#{gleam_error => assert,
                message => <<"Assertion failed."/utf8>>,
                file => <<?FILEPATH/utf8>>,
                module => <<"http_server_mock/internal/json_codec_test"/utf8>>,
                function => <<"encode_decode_stub_with_method_and_path_test"/utf8>>,
                line => 42,
                kind => binary_operator,
                operator => '==',
                left => #{kind => expression,
                    value => _assert_subject,
                    start => 1357,
                    'end' => 1388
                    },
                right => #{kind => expression,
                    value => _assert_subject@1,
                    start => 1392,
                    'end' => 1407
                    },
                start => 1350,
                'end' => 1407,
                expression_start => 1357})
    end,
    _assert_subject@2 = erlang:element(3, erlang:element(4, Roundtrip_result)),
    _assert_subject@3 = {some, {exact, <<"/api/data"/utf8>>}},
    case _assert_subject@2 =:= _assert_subject@3 of
        true -> nil;
        false -> erlang:error(#{gleam_error => assert,
                message => <<"Assertion failed."/utf8>>,
                file => <<?FILEPATH/utf8>>,
                module => <<"http_server_mock/internal/json_codec_test"/utf8>>,
                function => <<"encode_decode_stub_with_method_and_path_test"/utf8>>,
                line => 43,
                kind => binary_operator,
                operator => '==',
                left => #{kind => expression,
                    value => _assert_subject@2,
                    start => 1417,
                    'end' => 1446
                    },
                right => #{kind => literal,
                    value => _assert_subject@3,
                    start => 1450,
                    'end' => 1474
                    },
                start => 1410,
                'end' => 1474,
                expression_start => 1417})
    end.

-file("test/http_server_mock/internal/json_codec_test.gleam", 46).
?DOC(false).
-spec encode_decode_stub_with_all_path_matchers_test() -> nil.
encode_decode_stub_with_all_path_matchers_test() ->
    String_matchers = [{exact, <<"/exact"/utf8>>},
        {contains, <<"fragment"/utf8>>},
        {prefix, <<"/api"/utf8>>},
        {suffix, <<".json"/utf8>>},
        any_string],
    gleam@list:each(
        String_matchers,
        fun(String_matcher) ->
            The_stub = begin
                _pipe = http_server_mock@stub_builder:new(),
                _pipe@2 = http_server_mock@stub_builder:matching(
                    _pipe,
                    begin
                        _pipe@1 = http_server_mock@matcher:new(),
                        http_server_mock@matcher:path_matching(
                            _pipe@1,
                            String_matcher
                        )
                    end
                ),
                _pipe@3 = http_server_mock@stub_builder:responding_with(
                    _pipe@2,
                    http_server_mock@response:ok()
                ),
                _pipe@4 = http_server_mock@stub_builder:with_id(
                    _pipe@3,
                    <<"path-test"/utf8>>
                ),
                http_server_mock@stub_builder:build(_pipe@4)
            end,
            Roundtrip_result = roundtrip_stub(The_stub),
            _assert_subject = erlang:element(
                3,
                erlang:element(4, Roundtrip_result)
            ),
            _assert_subject@1 = {some, String_matcher},
            case _assert_subject =:= _assert_subject@1 of
                true -> nil;
                false -> erlang:error(#{gleam_error => assert,
                        message => <<"Assertion failed."/utf8>>,
                        file => <<?FILEPATH/utf8>>,
                        module => <<"http_server_mock/internal/json_codec_test"/utf8>>,
                        function => <<"encode_decode_stub_with_all_path_matchers_test"/utf8>>,
                        line => 64,
                        kind => binary_operator,
                        operator => '==',
                        left => #{kind => expression,
                            value => _assert_subject,
                            start => 2056,
                            'end' => 2085
                            },
                        right => #{kind => expression,
                            value => _assert_subject@1,
                            start => 2089,
                            'end' => 2109
                            },
                        start => 2049,
                        'end' => 2109,
                        expression_start => 2056})
            end
        end
    ).

-file("test/http_server_mock/internal/json_codec_test.gleam", 68).
?DOC(false).
-spec encode_decode_stub_with_query_params_test() -> nil.
encode_decode_stub_with_query_params_test() ->
    The_stub = begin
        _pipe = http_server_mock@stub_builder:new(),
        _pipe@2 = http_server_mock@stub_builder:matching(
            _pipe,
            begin
                _pipe@1 = http_server_mock@matcher:new(),
                http_server_mock@matcher:query_param(
                    _pipe@1,
                    <<"key"/utf8>>,
                    <<"value"/utf8>>
                )
            end
        ),
        _pipe@3 = http_server_mock@stub_builder:responding_with(
            _pipe@2,
            http_server_mock@response:ok()
        ),
        _pipe@4 = http_server_mock@stub_builder:with_id(
            _pipe@3,
            <<"query-stub"/utf8>>
        ),
        http_server_mock@stub_builder:build(_pipe@4)
    end,
    Roundtrip_result = roundtrip_stub(The_stub),
    _assert_subject = erlang:element(4, erlang:element(4, Roundtrip_result)),
    _assert_subject@1 = [{<<"key"/utf8>>, {exact, <<"value"/utf8>>}}],
    case _assert_subject =:= _assert_subject@1 of
        true -> nil;
        false -> erlang:error(#{gleam_error => assert,
                message => <<"Assertion failed."/utf8>>,
                file => <<?FILEPATH/utf8>>,
                module => <<"http_server_mock/internal/json_codec_test"/utf8>>,
                function => <<"encode_decode_stub_with_query_params_test"/utf8>>,
                line => 78,
                kind => binary_operator,
                operator => '==',
                left => #{kind => expression,
                    value => _assert_subject,
                    start => 2487,
                    'end' => 2524
                    },
                right => #{kind => literal,
                    value => _assert_subject@1,
                    start => 2528,
                    'end' => 2554
                    },
                start => 2480,
                'end' => 2554,
                expression_start => 2487})
    end.

-file("test/http_server_mock/internal/json_codec_test.gleam", 81).
?DOC(false).
-spec encode_decode_stub_with_headers_test() -> nil.
encode_decode_stub_with_headers_test() ->
    The_stub = begin
        _pipe = http_server_mock@stub_builder:new(),
        _pipe@2 = http_server_mock@stub_builder:matching(
            _pipe,
            begin
                _pipe@1 = http_server_mock@matcher:new(),
                http_server_mock@matcher:header(
                    _pipe@1,
                    <<"authorization"/utf8>>,
                    <<"Bearer token"/utf8>>
                )
            end
        ),
        _pipe@3 = http_server_mock@stub_builder:responding_with(
            _pipe@2,
            http_server_mock@response:ok()
        ),
        _pipe@4 = http_server_mock@stub_builder:with_id(
            _pipe@3,
            <<"header-stub"/utf8>>
        ),
        http_server_mock@stub_builder:build(_pipe@4)
    end,
    Roundtrip_result = roundtrip_stub(The_stub),
    _assert_subject = erlang:element(5, erlang:element(4, Roundtrip_result)),
    _assert_subject@1 = [{<<"authorization"/utf8>>,
            {exact, <<"Bearer token"/utf8>>}}],
    case _assert_subject =:= _assert_subject@1 of
        true -> nil;
        false -> erlang:error(#{gleam_error => assert,
                message => <<"Assertion failed."/utf8>>,
                file => <<?FILEPATH/utf8>>,
                module => <<"http_server_mock/internal/json_codec_test"/utf8>>,
                function => <<"encode_decode_stub_with_headers_test"/utf8>>,
                line => 91,
                kind => binary_operator,
                operator => '==',
                left => #{kind => expression,
                    value => _assert_subject,
                    start => 2935,
                    'end' => 2967
                    },
                right => #{kind => literal,
                    value => _assert_subject@1,
                    start => 2975,
                    'end' => 3018
                    },
                start => 2928,
                'end' => 3018,
                expression_start => 2935})
    end.

-file("test/http_server_mock/internal/json_codec_test.gleam", 95).
?DOC(false).
-spec encode_decode_stub_with_body_matchers_test() -> nil.
encode_decode_stub_with_body_matchers_test() ->
    Body_matchers = [any_body,
        {exact_body, <<"exact"/utf8>>},
        {contains_body, <<"frag"/utf8>>},
        {json_body, <<"{\"a\":1}"/utf8>>}],
    gleam@list:each(
        Body_matchers,
        fun(Body_matcher) ->
            The_stub = begin
                _pipe = http_server_mock@stub_builder:new(),
                _pipe@2 = http_server_mock@stub_builder:matching(
                    _pipe,
                    begin
                        _pipe@1 = http_server_mock@matcher:new(),
                        http_server_mock@matcher:body_matcher(
                            _pipe@1,
                            Body_matcher
                        )
                    end
                ),
                _pipe@3 = http_server_mock@stub_builder:responding_with(
                    _pipe@2,
                    http_server_mock@response:ok()
                ),
                _pipe@4 = http_server_mock@stub_builder:with_id(
                    _pipe@3,
                    <<"body-stub"/utf8>>
                ),
                http_server_mock@stub_builder:build(_pipe@4)
            end,
            Roundtrip_result = roundtrip_stub(The_stub),
            _assert_subject = erlang:element(
                6,
                erlang:element(4, Roundtrip_result)
            ),
            case _assert_subject =:= Body_matcher of
                true -> nil;
                false -> erlang:error(#{gleam_error => assert,
                        message => <<"Assertion failed."/utf8>>,
                        file => <<?FILEPATH/utf8>>,
                        module => <<"http_server_mock/internal/json_codec_test"/utf8>>,
                        function => <<"encode_decode_stub_with_body_matchers_test"/utf8>>,
                        line => 112,
                        kind => binary_operator,
                        operator => '==',
                        left => #{kind => expression,
                            value => _assert_subject,
                            start => 3580,
                            'end' => 3609
                            },
                        right => #{kind => expression,
                            value => Body_matcher,
                            start => 3613,
                            'end' => 3625
                            },
                        start => 3573,
                        'end' => 3625,
                        expression_start => 3580})
            end
        end
    ).

-file("test/http_server_mock/internal/json_codec_test.gleam", 116).
?DOC(false).
-spec encode_decode_stub_with_response_headers_test() -> nil.
encode_decode_stub_with_response_headers_test() ->
    The_stub = begin
        _pipe = http_server_mock@stub_builder:new(),
        _pipe@1 = http_server_mock@stub_builder:matching(
            _pipe,
            http_server_mock@matcher:new()
        ),
        _pipe@4 = http_server_mock@stub_builder:responding_with(
            _pipe@1,
            begin
                _pipe@2 = http_server_mock@response:new(),
                _pipe@3 = http_server_mock@response:header(
                    _pipe@2,
                    <<"content-type"/utf8>>,
                    <<"application/json"/utf8>>
                ),
                http_server_mock@response:header(
                    _pipe@3,
                    <<"x-custom"/utf8>>,
                    <<"val"/utf8>>
                )
            end
        ),
        _pipe@5 = http_server_mock@stub_builder:with_id(
            _pipe@4,
            <<"response-stub"/utf8>>
        ),
        http_server_mock@stub_builder:build(_pipe@5)
    end,
    Roundtrip_result = roundtrip_stub(The_stub),
    _assert_subject = erlang:element(3, erlang:element(5, Roundtrip_result)),
    _assert_subject@1 = [{<<"x-custom"/utf8>>, <<"val"/utf8>>},
        {<<"content-type"/utf8>>, <<"application/json"/utf8>>}],
    case _assert_subject =:= _assert_subject@1 of
        true -> nil;
        false -> erlang:error(#{gleam_error => assert,
                message => <<"Assertion failed."/utf8>>,
                file => <<?FILEPATH/utf8>>,
                module => <<"http_server_mock/internal/json_codec_test"/utf8>>,
                function => <<"encode_decode_stub_with_response_headers_test"/utf8>>,
                line => 128,
                kind => binary_operator,
                operator => '==',
                left => #{kind => expression,
                    value => _assert_subject,
                    start => 4077,
                    'end' => 4110
                    },
                right => #{kind => literal,
                    value => _assert_subject@1,
                    start => 4118,
                    'end' => 4179
                    },
                start => 4070,
                'end' => 4179,
                expression_start => 4077})
    end.

-file("test/http_server_mock/internal/json_codec_test.gleam", 132).
?DOC(false).
-spec encode_decode_stub_with_string_body_test() -> nil.
encode_decode_stub_with_string_body_test() ->
    The_stub = begin
        _pipe = http_server_mock@stub_builder:new(),
        _pipe@1 = http_server_mock@stub_builder:matching(
            _pipe,
            http_server_mock@matcher:new()
        ),
        _pipe@3 = http_server_mock@stub_builder:responding_with(
            _pipe@1,
            begin
                _pipe@2 = http_server_mock@response:new(),
                http_server_mock@response:body(_pipe@2, <<"hello"/utf8>>)
            end
        ),
        _pipe@4 = http_server_mock@stub_builder:with_id(
            _pipe@3,
            <<"string-body-stub"/utf8>>
        ),
        http_server_mock@stub_builder:build(_pipe@4)
    end,
    Roundtrip_result = roundtrip_stub(The_stub),
    _assert_subject = erlang:element(4, erlang:element(5, Roundtrip_result)),
    _assert_subject@1 = {string_body, <<"hello"/utf8>>},
    case _assert_subject =:= _assert_subject@1 of
        true -> nil;
        false -> erlang:error(#{gleam_error => assert,
                message => <<"Assertion failed."/utf8>>,
                file => <<?FILEPATH/utf8>>,
                module => <<"http_server_mock/internal/json_codec_test"/utf8>>,
                function => <<"encode_decode_stub_with_string_body_test"/utf8>>,
                line => 140,
                kind => binary_operator,
                operator => '==',
                left => #{kind => expression,
                    value => _assert_subject,
                    start => 4532,
                    'end' => 4562
                    },
                right => #{kind => literal,
                    value => _assert_subject@1,
                    start => 4566,
                    'end' => 4585
                    },
                start => 4525,
                'end' => 4585,
                expression_start => 4532})
    end.

-file("test/http_server_mock/internal/json_codec_test.gleam", 143).
?DOC(false).
-spec encode_decode_stub_with_delay_test() -> nil.
encode_decode_stub_with_delay_test() ->
    The_stub = begin
        _pipe = http_server_mock@stub_builder:new(),
        _pipe@1 = http_server_mock@stub_builder:matching(
            _pipe,
            http_server_mock@matcher:new()
        ),
        _pipe@3 = http_server_mock@stub_builder:responding_with(
            _pipe@1,
            begin
                _pipe@2 = http_server_mock@response:new(),
                http_server_mock@response:delay(_pipe@2, 250)
            end
        ),
        _pipe@4 = http_server_mock@stub_builder:with_id(
            _pipe@3,
            <<"delay-stub"/utf8>>
        ),
        http_server_mock@stub_builder:build(_pipe@4)
    end,
    Roundtrip_result = roundtrip_stub(The_stub),
    _assert_subject = erlang:element(5, erlang:element(5, Roundtrip_result)),
    _assert_subject@1 = {some, 250},
    case _assert_subject =:= _assert_subject@1 of
        true -> nil;
        false -> erlang:error(#{gleam_error => assert,
                message => <<"Assertion failed."/utf8>>,
                file => <<?FILEPATH/utf8>>,
                module => <<"http_server_mock/internal/json_codec_test"/utf8>>,
                function => <<"encode_decode_stub_with_delay_test"/utf8>>,
                line => 151,
                kind => binary_operator,
                operator => '==',
                left => #{kind => expression,
                    value => _assert_subject,
                    start => 4923,
                    'end' => 4957
                    },
                right => #{kind => literal,
                    value => _assert_subject@1,
                    start => 4961,
                    'end' => 4970
                    },
                start => 4916,
                'end' => 4970,
                expression_start => 4923})
    end.

-file("test/http_server_mock/internal/json_codec_test.gleam", 154).
?DOC(false).
-spec encode_decode_stub_with_scenario_test() -> nil.
encode_decode_stub_with_scenario_test() ->
    The_stub = begin
        _pipe = http_server_mock@stub_builder:new(),
        _pipe@1 = http_server_mock@stub_builder:matching(
            _pipe,
            http_server_mock@matcher:new()
        ),
        _pipe@2 = http_server_mock@stub_builder:responding_with(
            _pipe@1,
            http_server_mock@response:ok()
        ),
        _pipe@3 = http_server_mock@stub_builder:with_id(
            _pipe@2,
            <<"scenario-stub"/utf8>>
        ),
        _pipe@4 = http_server_mock@stub_builder:in_scenario(
            _pipe@3,
            <<"checkout"/utf8>>
        ),
        _pipe@5 = http_server_mock@stub_builder:when_state_is(
            _pipe@4,
            <<"step1"/utf8>>
        ),
        _pipe@6 = http_server_mock@stub_builder:then_transition_to(
            _pipe@5,
            <<"step2"/utf8>>
        ),
        http_server_mock@stub_builder:build(_pipe@6)
    end,
    Roundtrip_result = roundtrip_stub(The_stub),
    Scenario_state@1 = case erlang:element(6, Roundtrip_result) of
        {some, Scenario_state} -> Scenario_state;
        _assert_fail ->
            erlang:error(#{gleam_error => let_assert,
                        message => <<"Pattern match failed, no pattern matched the value."/utf8>>,
                        file => <<?FILEPATH/utf8>>,
                        module => <<"http_server_mock/internal/json_codec_test"/utf8>>,
                        function => <<"encode_decode_stub_with_scenario_test"/utf8>>,
                        line => 165,
                        value => _assert_fail,
                        start => 5418,
                        'end' => 5477,
                        pattern_start => 5429,
                        pattern_end => 5449})
    end,
    _assert_subject = erlang:element(2, Scenario_state@1),
    _assert_subject@1 = <<"checkout"/utf8>>,
    case _assert_subject =:= _assert_subject@1 of
        true -> nil;
        false -> erlang:error(#{gleam_error => assert,
                message => <<"Assertion failed."/utf8>>,
                file => <<?FILEPATH/utf8>>,
                module => <<"http_server_mock/internal/json_codec_test"/utf8>>,
                function => <<"encode_decode_stub_with_scenario_test"/utf8>>,
                line => 166,
                kind => binary_operator,
                operator => '==',
                left => #{kind => expression,
                    value => _assert_subject,
                    start => 5487,
                    'end' => 5506
                    },
                right => #{kind => literal,
                    value => _assert_subject@1,
                    start => 5510,
                    'end' => 5520
                    },
                start => 5480,
                'end' => 5520,
                expression_start => 5487})
    end,
    _assert_subject@2 = erlang:element(3, Scenario_state@1),
    _assert_subject@3 = {some, <<"step1"/utf8>>},
    case _assert_subject@2 =:= _assert_subject@3 of
        true -> nil;
        false -> erlang:error(#{gleam_error => assert,
                message => <<"Assertion failed."/utf8>>,
                file => <<?FILEPATH/utf8>>,
                module => <<"http_server_mock/internal/json_codec_test"/utf8>>,
                function => <<"encode_decode_stub_with_scenario_test"/utf8>>,
                line => 167,
                kind => binary_operator,
                operator => '==',
                left => #{kind => expression,
                    value => _assert_subject@2,
                    start => 5530,
                    'end' => 5559
                    },
                right => #{kind => literal,
                    value => _assert_subject@3,
                    start => 5563,
                    'end' => 5576
                    },
                start => 5523,
                'end' => 5576,
                expression_start => 5530})
    end,
    _assert_subject@4 = erlang:element(4, Scenario_state@1),
    _assert_subject@5 = {some, <<"step2"/utf8>>},
    case _assert_subject@4 =:= _assert_subject@5 of
        true -> nil;
        false -> erlang:error(#{gleam_error => assert,
                message => <<"Assertion failed."/utf8>>,
                file => <<?FILEPATH/utf8>>,
                module => <<"http_server_mock/internal/json_codec_test"/utf8>>,
                function => <<"encode_decode_stub_with_scenario_test"/utf8>>,
                line => 168,
                kind => binary_operator,
                operator => '==',
                left => #{kind => expression,
                    value => _assert_subject@4,
                    start => 5586,
                    'end' => 5610
                    },
                right => #{kind => literal,
                    value => _assert_subject@5,
                    start => 5614,
                    'end' => 5627
                    },
                start => 5579,
                'end' => 5627,
                expression_start => 5586})
    end.

-file("test/http_server_mock/internal/json_codec_test.gleam", 171).
?DOC(false).
-spec encode_decode_multiple_stubs_test() -> nil.
encode_decode_multiple_stubs_test() ->
    Stubs = [begin
            _pipe = http_server_mock@stub_builder:new(),
            _pipe@2 = http_server_mock@stub_builder:matching(
                _pipe,
                begin
                    _pipe@1 = http_server_mock@matcher:new(),
                    http_server_mock@matcher:path(_pipe@1, <<"/a"/utf8>>)
                end
            ),
            _pipe@3 = http_server_mock@stub_builder:responding_with(
                _pipe@2,
                http_server_mock@response:ok()
            ),
            _pipe@4 = http_server_mock@stub_builder:with_id(
                _pipe@3,
                <<"a"/utf8>>
            ),
            http_server_mock@stub_builder:build(_pipe@4)
        end,
        begin
            _pipe@5 = http_server_mock@stub_builder:new(),
            _pipe@7 = http_server_mock@stub_builder:matching(
                _pipe@5,
                begin
                    _pipe@6 = http_server_mock@matcher:new(),
                    http_server_mock@matcher:path(_pipe@6, <<"/b"/utf8>>)
                end
            ),
            _pipe@8 = http_server_mock@stub_builder:responding_with(
                _pipe@7,
                http_server_mock@response:not_found()
            ),
            _pipe@9 = http_server_mock@stub_builder:with_id(
                _pipe@8,
                <<"b"/utf8>>
            ),
            http_server_mock@stub_builder:build(_pipe@9)
        end],
    Json_string = http_server_mock@internal@json_codec:encode_stubs(Stubs),
    Decoded@1 = case http_server_mock@internal@json_codec:decode_stubs(
        Json_string
    ) of
        {ok, Decoded} -> Decoded;
        _assert_fail ->
            erlang:error(#{gleam_error => let_assert,
                        message => <<"Pattern match failed, no pattern matched the value."/utf8>>,
                        file => <<?FILEPATH/utf8>>,
                        module => <<"http_server_mock/internal/json_codec_test"/utf8>>,
                        function => <<"encode_decode_multiple_stubs_test"/utf8>>,
                        line => 185,
                        value => _assert_fail,
                        start => 6176,
                        'end' => 6237,
                        pattern_start => 6187,
                        pattern_end => 6198})
    end,
    _assert_subject = gleam@list:map(
        Decoded@1,
        fun(The_stub) -> erlang:element(2, The_stub) end
    ),
    _assert_subject@1 = [<<"a"/utf8>>, <<"b"/utf8>>],
    case _assert_subject =:= _assert_subject@1 of
        true -> nil;
        false -> erlang:error(#{gleam_error => assert,
                message => <<"Assertion failed."/utf8>>,
                file => <<?FILEPATH/utf8>>,
                module => <<"http_server_mock/internal/json_codec_test"/utf8>>,
                function => <<"encode_decode_multiple_stubs_test"/utf8>>,
                line => 186,
                kind => binary_operator,
                operator => '==',
                left => #{kind => expression,
                    value => _assert_subject,
                    start => 6247,
                    'end' => 6294
                    },
                right => #{kind => literal,
                    value => _assert_subject@1,
                    start => 6298,
                    'end' => 6308
                    },
                start => 6240,
                'end' => 6308,
                expression_start => 6247})
    end.

-file("test/http_server_mock/internal/json_codec_test.gleam", 189).
?DOC(false).
-spec decode_invalid_json_returns_error_test() -> {ok,
        http_server_mock@types:stub()} |
    {error, binary()}.
decode_invalid_json_returns_error_test() ->
    _assert_subject = http_server_mock@internal@json_codec:decode_stub(
        <<"not json at all"/utf8>>
    ),
    case _assert_subject of
        {error, _} -> _assert_subject;
        _assert_fail ->
            erlang:error(#{gleam_error => let_assert,
                        message => <<"Pattern match failed, no pattern matched the value."/utf8>>,
                        file => <<?FILEPATH/utf8>>,
                        module => <<"http_server_mock/internal/json_codec_test"/utf8>>,
                        function => <<"decode_invalid_json_returns_error_test"/utf8>>,
                        line => 190,
                        value => _assert_fail,
                        start => 6364,
                        'end' => 6427,
                        pattern_start => 6375,
                        pattern_end => 6383})
    end.

-file("test/http_server_mock/internal/json_codec_test.gleam", 193).
?DOC(false).
-spec encode_decode_recorded_requests_test() -> nil.
encode_decode_recorded_requests_test() ->
    Recorded_requests = [{recorded_request,
            <<"req1"/utf8>>,
            get,
            <<"/test"/utf8>>,
            {some, <<"a=1"/utf8>>},
            maps:from_list([{<<"accept"/utf8>>, <<"application/json"/utf8>>}]),
            <<""/utf8>>,
            1000000,
            {some, <<"stub-1"/utf8>>}}],
    Json_string = http_server_mock@internal@json_codec:encode_recorded_requests(
        Recorded_requests
    ),
    Decoded@1 = case http_server_mock@internal@json_codec:decode_recorded_requests(
        Json_string
    ) of
        {ok, Decoded} -> Decoded;
        _assert_fail ->
            erlang:error(#{gleam_error => let_assert,
                        message => <<"Pattern match failed, no pattern matched the value."/utf8>>,
                        file => <<?FILEPATH/utf8>>,
                        module => <<"http_server_mock/internal/json_codec_test"/utf8>>,
                        function => <<"encode_decode_recorded_requests_test"/utf8>>,
                        line => 207,
                        value => _assert_fail,
                        start => 6857,
                        'end' => 6930,
                        pattern_start => 6868,
                        pattern_end => 6879})
    end,
    Recorded_request@1 = case Decoded@1 of
        [Recorded_request] -> Recorded_request;
        _assert_fail@1 ->
            erlang:error(#{gleam_error => let_assert,
                        message => <<"Pattern match failed, no pattern matched the value."/utf8>>,
                        file => <<?FILEPATH/utf8>>,
                        module => <<"http_server_mock/internal/json_codec_test"/utf8>>,
                        function => <<"encode_decode_recorded_requests_test"/utf8>>,
                        line => 208,
                        value => _assert_fail@1,
                        start => 6933,
                        'end' => 6972,
                        pattern_start => 6944,
                        pattern_end => 6962})
    end,
    _assert_subject = erlang:element(2, Recorded_request@1),
    _assert_subject@1 = <<"req1"/utf8>>,
    case _assert_subject =:= _assert_subject@1 of
        true -> nil;
        false -> erlang:error(#{gleam_error => assert,
                message => <<"Assertion failed."/utf8>>,
                file => <<?FILEPATH/utf8>>,
                module => <<"http_server_mock/internal/json_codec_test"/utf8>>,
                function => <<"encode_decode_recorded_requests_test"/utf8>>,
                line => 209,
                kind => binary_operator,
                operator => '==',
                left => #{kind => expression,
                    value => _assert_subject,
                    start => 6982,
                    'end' => 7001
                    },
                right => #{kind => literal,
                    value => _assert_subject@1,
                    start => 7005,
                    'end' => 7011
                    },
                start => 6975,
                'end' => 7011,
                expression_start => 6982})
    end,
    _assert_subject@2 = erlang:element(3, Recorded_request@1),
    _assert_subject@3 = get,
    case _assert_subject@2 =:= _assert_subject@3 of
        true -> nil;
        false -> erlang:error(#{gleam_error => assert,
                message => <<"Assertion failed."/utf8>>,
                file => <<?FILEPATH/utf8>>,
                module => <<"http_server_mock/internal/json_codec_test"/utf8>>,
                function => <<"encode_decode_recorded_requests_test"/utf8>>,
                line => 210,
                kind => binary_operator,
                operator => '==',
                left => #{kind => expression,
                    value => _assert_subject@2,
                    start => 7021,
                    'end' => 7044
                    },
                right => #{kind => expression,
                    value => _assert_subject@3,
                    start => 7048,
                    'end' => 7056
                    },
                start => 7014,
                'end' => 7056,
                expression_start => 7021})
    end,
    _assert_subject@4 = erlang:element(4, Recorded_request@1),
    _assert_subject@5 = <<"/test"/utf8>>,
    case _assert_subject@4 =:= _assert_subject@5 of
        true -> nil;
        false -> erlang:error(#{gleam_error => assert,
                message => <<"Assertion failed."/utf8>>,
                file => <<?FILEPATH/utf8>>,
                module => <<"http_server_mock/internal/json_codec_test"/utf8>>,
                function => <<"encode_decode_recorded_requests_test"/utf8>>,
                line => 211,
                kind => binary_operator,
                operator => '==',
                left => #{kind => expression,
                    value => _assert_subject@4,
                    start => 7066,
                    'end' => 7087
                    },
                right => #{kind => literal,
                    value => _assert_subject@5,
                    start => 7091,
                    'end' => 7098
                    },
                start => 7059,
                'end' => 7098,
                expression_start => 7066})
    end,
    _assert_subject@6 = erlang:element(5, Recorded_request@1),
    _assert_subject@7 = {some, <<"a=1"/utf8>>},
    case _assert_subject@6 =:= _assert_subject@7 of
        true -> nil;
        false -> erlang:error(#{gleam_error => assert,
                message => <<"Assertion failed."/utf8>>,
                file => <<?FILEPATH/utf8>>,
                module => <<"http_server_mock/internal/json_codec_test"/utf8>>,
                function => <<"encode_decode_recorded_requests_test"/utf8>>,
                line => 212,
                kind => binary_operator,
                operator => '==',
                left => #{kind => expression,
                    value => _assert_subject@6,
                    start => 7108,
                    'end' => 7130
                    },
                right => #{kind => literal,
                    value => _assert_subject@7,
                    start => 7134,
                    'end' => 7145
                    },
                start => 7101,
                'end' => 7145,
                expression_start => 7108})
    end,
    _assert_subject@8 = erlang:element(9, Recorded_request@1),
    _assert_subject@9 = {some, <<"stub-1"/utf8>>},
    case _assert_subject@8 =:= _assert_subject@9 of
        true -> nil;
        false -> erlang:error(#{gleam_error => assert,
                message => <<"Assertion failed."/utf8>>,
                file => <<?FILEPATH/utf8>>,
                module => <<"http_server_mock/internal/json_codec_test"/utf8>>,
                function => <<"encode_decode_recorded_requests_test"/utf8>>,
                line => 213,
                kind => binary_operator,
                operator => '==',
                left => #{kind => expression,
                    value => _assert_subject@8,
                    start => 7155,
                    'end' => 7187
                    },
                right => #{kind => literal,
                    value => _assert_subject@9,
                    start => 7191,
                    'end' => 7205
                    },
                start => 7148,
                'end' => 7205,
                expression_start => 7155})
    end.
