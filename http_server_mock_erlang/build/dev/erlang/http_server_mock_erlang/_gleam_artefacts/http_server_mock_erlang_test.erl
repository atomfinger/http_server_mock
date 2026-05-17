-module(http_server_mock_erlang_test).
-compile([no_auto_import, nowarn_unused_vars, nowarn_unused_function, nowarn_nomatch, inline]).
-define(FILEPATH, "test/http_server_mock_erlang_test.gleam").
-export([main/0, stub_responds_to_matching_requests_test/0, unmatched_requests_return_404_test/0, matchers_can_filter_on_method_path_and_query_test/0, post_stub_matches_on_body_and_returns_status_test/0, recorded_requests_can_be_verified_test/0, scenarios_model_stateful_sequences_test/0]).
-export_type([test_response/0]).

-type test_response() :: {test_response, integer(), binary()}.

-file("test/http_server_mock_erlang_test.gleam", 12).
-spec main() -> nil.
main() ->
    gleeunit:main().

-file("test/http_server_mock_erlang_test.gleam", 21).
-spec get(binary()) -> test_response().
get(Url) ->
    Req@1 = case gleam@http@request:to(Url) of
        {ok, Req} -> Req;
        _assert_fail ->
            erlang:error(#{gleam_error => let_assert,
                        message => <<"Pattern match failed, no pattern matched the value."/utf8>>,
                        file => <<?FILEPATH/utf8>>,
                        module => <<"http_server_mock_erlang_test"/utf8>>,
                        function => <<"get"/utf8>>,
                        line => 22,
                        value => _assert_fail,
                        start => 474,
                        'end' => 510,
                        pattern_start => 485,
                        pattern_end => 492})
    end,
    Resp@1 = case gleam@httpc:send(Req@1) of
        {ok, Resp} -> Resp;
        _assert_fail@1 ->
            erlang:error(#{gleam_error => let_assert,
                        message => <<"Pattern match failed, no pattern matched the value."/utf8>>,
                        file => <<?FILEPATH/utf8>>,
                        module => <<"http_server_mock_erlang_test"/utf8>>,
                        function => <<"get"/utf8>>,
                        line => 23,
                        value => _assert_fail@1,
                        start => 513,
                        'end' => 550,
                        pattern_start => 524,
                        pattern_end => 532})
    end,
    {test_response, erlang:element(2, Resp@1), erlang:element(4, Resp@1)}.

-file("test/http_server_mock_erlang_test.gleam", 28).
-spec post(binary(), binary(), binary()) -> test_response().
post(Url, Body, Content_type) ->
    Base@1 = case gleam@http@request:to(Url) of
        {ok, Base} -> Base;
        _assert_fail ->
            erlang:error(#{gleam_error => let_assert,
                        message => <<"Pattern match failed, no pattern matched the value."/utf8>>,
                        file => <<?FILEPATH/utf8>>,
                        module => <<"http_server_mock_erlang_test"/utf8>>,
                        function => <<"post"/utf8>>,
                        line => 29,
                        value => _assert_fail,
                        start => 742,
                        'end' => 779,
                        pattern_start => 753,
                        pattern_end => 761})
    end,
    Resp@1 = case begin
        _pipe = Base@1,
        _pipe@1 = gleam@http@request:set_method(_pipe, post),
        _pipe@2 = gleam@http@request:set_body(_pipe@1, Body),
        _pipe@3 = gleam@http@request:set_header(
            _pipe@2,
            <<"content-type"/utf8>>,
            Content_type
        ),
        gleam@httpc:send(_pipe@3)
    end of
        {ok, Resp} -> Resp;
        _assert_fail@1 ->
            erlang:error(#{gleam_error => let_assert,
                        message => <<"Pattern match failed, no pattern matched the value."/utf8>>,
                        file => <<?FILEPATH/utf8>>,
                        module => <<"http_server_mock_erlang_test"/utf8>>,
                        function => <<"post"/utf8>>,
                        line => 30,
                        value => _assert_fail@1,
                        start => 782,
                        'end' => 953,
                        pattern_start => 793,
                        pattern_end => 801})
    end,
    {test_response, erlang:element(2, Resp@1), erlang:element(4, Resp@1)}.

-file("test/http_server_mock_erlang_test.gleam", 39).
-spec stub_responds_to_matching_requests_test() -> http_server_mock@internal@server:mock_server(http_server_mock@internal@server:stopped()).
stub_responds_to_matching_requests_test() ->
    Server = begin
        _pipe = http_server_mock:new(http_server_mock_erlang:server()),
        _pipe@1 = http_server_mock:start(_pipe),
        http_server_mock:with_stub(
            _pipe@1,
            begin
                _pipe@2 = http_server_mock@stub_builder:new(),
                _pipe@4 = http_server_mock@stub_builder:matching(
                    _pipe@2,
                    begin
                        _pipe@3 = http_server_mock@matcher:new(),
                        http_server_mock@matcher:path(
                            _pipe@3,
                            <<"/greet"/utf8>>
                        )
                    end
                ),
                _pipe@6 = http_server_mock@stub_builder:responding_with(
                    _pipe@4,
                    begin
                        _pipe@5 = http_server_mock@response:new(),
                        http_server_mock@response:body(
                            _pipe@5,
                            <<"Hello!"/utf8>>
                        )
                    end
                ),
                http_server_mock@stub_builder:build(_pipe@6)
            end
        )
    end,
    _assert_subject = erlang:element(
        3,
        get(<<(http_server_mock:base_url(Server))/binary, "/greet"/utf8>>)
    ),
    _assert_subject@1 = <<"Hello!"/utf8>>,
    case _assert_subject =:= _assert_subject@1 of
        true -> nil;
        false -> erlang:error(#{gleam_error => assert,
                message => <<"Assertion failed."/utf8>>,
                file => <<?FILEPATH/utf8>>,
                module => <<"http_server_mock_erlang_test"/utf8>>,
                function => <<"stub_responds_to_matching_requests_test"/utf8>>,
                line => 50,
                kind => binary_operator,
                operator => '==',
                left => #{kind => expression,
                    value => _assert_subject,
                    start => 1427,
                    'end' => 1482
                    },
                right => #{kind => literal,
                    value => _assert_subject@1,
                    start => 1486,
                    'end' => 1494
                    },
                start => 1420,
                'end' => 1494,
                expression_start => 1427})
    end,
    http_server_mock:stop(Server).

-file("test/http_server_mock_erlang_test.gleam", 55).
-spec unmatched_requests_return_404_test() -> http_server_mock@internal@server:mock_server(http_server_mock@internal@server:stopped()).
unmatched_requests_return_404_test() ->
    Server = begin
        _pipe = http_server_mock:new(http_server_mock_erlang:server()),
        http_server_mock:start(_pipe)
    end,
    _assert_subject = erlang:element(
        2,
        get(
            <<(http_server_mock:base_url(Server))/binary,
                "/not-registered"/utf8>>
        )
    ),
    _assert_subject@1 = 404,
    case _assert_subject =:= _assert_subject@1 of
        true -> nil;
        false -> erlang:error(#{gleam_error => assert,
                message => <<"Assertion failed."/utf8>>,
                file => <<?FILEPATH/utf8>>,
                module => <<"http_server_mock_erlang_test"/utf8>>,
                function => <<"unmatched_requests_return_404_test"/utf8>>,
                line => 60,
                kind => binary_operator,
                operator => '==',
                left => #{kind => expression,
                    value => _assert_subject,
                    start => 1693,
                    'end' => 1759
                    },
                right => #{kind => literal,
                    value => _assert_subject@1,
                    start => 1767,
                    'end' => 1770
                    },
                start => 1686,
                'end' => 1770,
                expression_start => 1693})
    end,
    http_server_mock:stop(Server).

-file("test/http_server_mock_erlang_test.gleam", 66).
-spec matchers_can_filter_on_method_path_and_query_test() -> http_server_mock@internal@server:mock_server(http_server_mock@internal@server:stopped()).
matchers_can_filter_on_method_path_and_query_test() ->
    Server = begin
        _pipe = http_server_mock:new(http_server_mock_erlang:server()),
        _pipe@1 = http_server_mock:start(_pipe),
        http_server_mock:with_stub(
            _pipe@1,
            begin
                _pipe@2 = http_server_mock@stub_builder:new(),
                _pipe@6 = http_server_mock@stub_builder:matching(
                    _pipe@2,
                    begin
                        _pipe@3 = http_server_mock@matcher:new(),
                        _pipe@4 = http_server_mock@matcher:method(_pipe@3, get),
                        _pipe@5 = http_server_mock@matcher:path(
                            _pipe@4,
                            <<"/search"/utf8>>
                        ),
                        http_server_mock@matcher:query_param(
                            _pipe@5,
                            <<"q"/utf8>>,
                            <<"gleam"/utf8>>
                        )
                    end
                ),
                _pipe@8 = http_server_mock@stub_builder:responding_with(
                    _pipe@6,
                    begin
                        _pipe@7 = http_server_mock@response:new(),
                        http_server_mock@response:body(
                            _pipe@7,
                            <<"found"/utf8>>
                        )
                    end
                ),
                http_server_mock@stub_builder:build(_pipe@8)
            end
        )
    end,
    _assert_subject = erlang:element(
        3,
        get(
            <<(http_server_mock:base_url(Server))/binary,
                "/search?q=gleam"/utf8>>
        )
    ),
    _assert_subject@1 = <<"found"/utf8>>,
    case _assert_subject =:= _assert_subject@1 of
        true -> nil;
        false -> erlang:error(#{gleam_error => assert,
                message => <<"Assertion failed."/utf8>>,
                file => <<?FILEPATH/utf8>>,
                module => <<"http_server_mock_erlang_test"/utf8>>,
                function => <<"matchers_can_filter_on_method_path_and_query_test"/utf8>>,
                line => 82,
                kind => binary_operator,
                operator => '==',
                left => #{kind => expression,
                    value => _assert_subject,
                    start => 2340,
                    'end' => 2404
                    },
                right => #{kind => literal,
                    value => _assert_subject@1,
                    start => 2412,
                    'end' => 2419
                    },
                start => 2333,
                'end' => 2419,
                expression_start => 2340})
    end,
    _assert_subject@2 = erlang:element(
        2,
        get(
            <<(http_server_mock:base_url(Server))/binary,
                "/search?q=other"/utf8>>
        )
    ),
    _assert_subject@3 = 404,
    case _assert_subject@2 =:= _assert_subject@3 of
        true -> nil;
        false -> erlang:error(#{gleam_error => assert,
                message => <<"Assertion failed."/utf8>>,
                file => <<?FILEPATH/utf8>>,
                module => <<"http_server_mock_erlang_test"/utf8>>,
                function => <<"matchers_can_filter_on_method_path_and_query_test"/utf8>>,
                line => 84,
                kind => binary_operator,
                operator => '==',
                left => #{kind => expression,
                    value => _assert_subject@2,
                    start => 2429,
                    'end' => 2495
                    },
                right => #{kind => literal,
                    value => _assert_subject@3,
                    start => 2503,
                    'end' => 2506
                    },
                start => 2422,
                'end' => 2506,
                expression_start => 2429})
    end,
    http_server_mock:stop(Server).

-file("test/http_server_mock_erlang_test.gleam", 90).
-spec post_stub_matches_on_body_and_returns_status_test() -> http_server_mock@internal@server:mock_server(http_server_mock@internal@server:stopped()).
post_stub_matches_on_body_and_returns_status_test() ->
    Server = begin
        _pipe = http_server_mock:new(http_server_mock_erlang:server()),
        _pipe@1 = http_server_mock:start(_pipe),
        http_server_mock:with_stub(
            _pipe@1,
            begin
                _pipe@2 = http_server_mock@stub_builder:new(),
                _pipe@6 = http_server_mock@stub_builder:matching(
                    _pipe@2,
                    begin
                        _pipe@3 = http_server_mock@matcher:new(),
                        _pipe@4 = http_server_mock@matcher:method(_pipe@3, post),
                        _pipe@5 = http_server_mock@matcher:path(
                            _pipe@4,
                            <<"/echo"/utf8>>
                        ),
                        http_server_mock@matcher:body_containing(
                            _pipe@5,
                            <<"ping"/utf8>>
                        )
                    end
                ),
                _pipe@9 = http_server_mock@stub_builder:responding_with(
                    _pipe@6,
                    begin
                        _pipe@7 = http_server_mock@response:new(),
                        _pipe@8 = http_server_mock@response:status(_pipe@7, 201),
                        http_server_mock@response:body(_pipe@8, <<"pong"/utf8>>)
                    end
                ),
                http_server_mock@stub_builder:build(_pipe@9)
            end
        )
    end,
    Resp = post(
        <<(http_server_mock:base_url(Server))/binary, "/echo"/utf8>>,
        <<"ping"/utf8>>,
        <<"text/plain"/utf8>>
    ),
    _assert_subject = erlang:element(2, Resp),
    _assert_subject@1 = 201,
    case _assert_subject =:= _assert_subject@1 of
        true -> nil;
        false -> erlang:error(#{gleam_error => assert,
                message => <<"Assertion failed."/utf8>>,
                file => <<?FILEPATH/utf8>>,
                module => <<"http_server_mock_erlang_test"/utf8>>,
                function => <<"post_stub_matches_on_body_and_returns_status_test"/utf8>>,
                line => 110,
                kind => binary_operator,
                operator => '==',
                left => #{kind => expression,
                    value => _assert_subject,
                    start => 3203,
                    'end' => 3214
                    },
                right => #{kind => literal,
                    value => _assert_subject@1,
                    start => 3218,
                    'end' => 3221
                    },
                start => 3196,
                'end' => 3221,
                expression_start => 3203})
    end,
    _assert_subject@2 = erlang:element(3, Resp),
    _assert_subject@3 = <<"pong"/utf8>>,
    case _assert_subject@2 =:= _assert_subject@3 of
        true -> nil;
        false -> erlang:error(#{gleam_error => assert,
                message => <<"Assertion failed."/utf8>>,
                file => <<?FILEPATH/utf8>>,
                module => <<"http_server_mock_erlang_test"/utf8>>,
                function => <<"post_stub_matches_on_body_and_returns_status_test"/utf8>>,
                line => 111,
                kind => binary_operator,
                operator => '==',
                left => #{kind => expression,
                    value => _assert_subject@2,
                    start => 3231,
                    'end' => 3240
                    },
                right => #{kind => literal,
                    value => _assert_subject@3,
                    start => 3244,
                    'end' => 3250
                    },
                start => 3224,
                'end' => 3250,
                expression_start => 3231})
    end,
    http_server_mock:stop(Server).

-file("test/http_server_mock_erlang_test.gleam", 116).
-spec recorded_requests_can_be_verified_test() -> http_server_mock@internal@server:mock_server(http_server_mock@internal@server:stopped()).
recorded_requests_can_be_verified_test() ->
    Ping = begin
        _pipe = http_server_mock@matcher:new(),
        _pipe@1 = http_server_mock@matcher:method(_pipe, get),
        http_server_mock@matcher:path(_pipe@1, <<"/ping"/utf8>>)
    end,
    Server = begin
        _pipe@2 = http_server_mock:new(http_server_mock_erlang:server()),
        _pipe@3 = http_server_mock:start(_pipe@2),
        http_server_mock:with_stub(
            _pipe@3,
            begin
                _pipe@4 = http_server_mock@stub_builder:new(),
                _pipe@5 = http_server_mock@stub_builder:matching(_pipe@4, Ping),
                _pipe@6 = http_server_mock@stub_builder:responding_with(
                    _pipe@5,
                    http_server_mock@response:ok()
                ),
                http_server_mock@stub_builder:build(_pipe@6)
            end
        )
    end,
    _ = get(<<(http_server_mock:base_url(Server))/binary, "/ping"/utf8>>),
    _ = get(<<(http_server_mock:base_url(Server))/binary, "/ping"/utf8>>),
    _ = get(<<(http_server_mock:base_url(Server))/binary, "/ping"/utf8>>),
    http_server_mock@verify:called_times(Server, Ping, 3),
    http_server_mock:stop(Server).

-file("test/http_server_mock_erlang_test.gleam", 138).
-spec scenarios_model_stateful_sequences_test() -> http_server_mock@internal@server:mock_server(http_server_mock@internal@server:stopped()).
scenarios_model_stateful_sequences_test() ->
    Get_job = begin
        _pipe = http_server_mock@matcher:new(),
        _pipe@1 = http_server_mock@matcher:method(_pipe, get),
        http_server_mock@matcher:path(_pipe@1, <<"/job"/utf8>>)
    end,
    Server = begin
        _pipe@2 = http_server_mock:new(http_server_mock_erlang:server()),
        http_server_mock:start(_pipe@2)
    end,
    case http_server_mock:add_stub(
        Server,
        begin
            _pipe@3 = http_server_mock@stub_builder:new(),
            _pipe@4 = http_server_mock@stub_builder:matching(_pipe@3, Get_job),
            _pipe@6 = http_server_mock@stub_builder:responding_with(
                _pipe@4,
                begin
                    _pipe@5 = http_server_mock@response:new(),
                    http_server_mock@response:body(_pipe@5, <<"running"/utf8>>)
                end
            ),
            _pipe@7 = http_server_mock@stub_builder:in_scenario(
                _pipe@6,
                <<"job"/utf8>>
            ),
            _pipe@8 = http_server_mock@stub_builder:then_transition_to(
                _pipe@7,
                <<"done"/utf8>>
            ),
            http_server_mock@stub_builder:build(_pipe@8)
        end
    ) of
        {ok, _} -> nil;
        _assert_fail ->
            erlang:error(#{gleam_error => let_assert,
                        message => <<"Pattern match failed, no pattern matched the value."/utf8>>,
                        file => <<?FILEPATH/utf8>>,
                        module => <<"http_server_mock_erlang_test"/utf8>>,
                        function => <<"scenarios_model_stateful_sequences_test"/utf8>>,
                        line => 145,
                        value => _assert_fail,
                        start => 4214,
                        'end' => 4582,
                        pattern_start => 4225,
                        pattern_end => 4230})
    end,
    case http_server_mock:add_stub(
        Server,
        begin
            _pipe@9 = http_server_mock@stub_builder:new(),
            _pipe@10 = http_server_mock@stub_builder:matching(_pipe@9, Get_job),
            _pipe@12 = http_server_mock@stub_builder:responding_with(
                _pipe@10,
                begin
                    _pipe@11 = http_server_mock@response:new(),
                    http_server_mock@response:body(
                        _pipe@11,
                        <<"complete"/utf8>>
                    )
                end
            ),
            _pipe@13 = http_server_mock@stub_builder:in_scenario(
                _pipe@12,
                <<"job"/utf8>>
            ),
            _pipe@14 = http_server_mock@stub_builder:when_state_is(
                _pipe@13,
                <<"done"/utf8>>
            ),
            http_server_mock@stub_builder:build(_pipe@14)
        end
    ) of
        {ok, _} -> nil;
        _assert_fail@1 ->
            erlang:error(#{gleam_error => let_assert,
                        message => <<"Pattern match failed, no pattern matched the value."/utf8>>,
                        file => <<?FILEPATH/utf8>>,
                        module => <<"http_server_mock_erlang_test"/utf8>>,
                        function => <<"scenarios_model_stateful_sequences_test"/utf8>>,
                        line => 157,
                        value => _assert_fail@1,
                        start => 4585,
                        'end' => 4949,
                        pattern_start => 4596,
                        pattern_end => 4601})
    end,
    _assert_subject = erlang:element(
        3,
        get(<<(http_server_mock:base_url(Server))/binary, "/job"/utf8>>)
    ),
    _assert_subject@1 = <<"running"/utf8>>,
    case _assert_subject =:= _assert_subject@1 of
        true -> nil;
        false -> erlang:error(#{gleam_error => assert,
                message => <<"Assertion failed."/utf8>>,
                file => <<?FILEPATH/utf8>>,
                module => <<"http_server_mock_erlang_test"/utf8>>,
                function => <<"scenarios_model_stateful_sequences_test"/utf8>>,
                line => 170,
                kind => binary_operator,
                operator => '==',
                left => #{kind => expression,
                    value => _assert_subject,
                    start => 4960,
                    'end' => 5013
                    },
                right => #{kind => literal,
                    value => _assert_subject@1,
                    start => 5017,
                    'end' => 5026
                    },
                start => 4953,
                'end' => 5026,
                expression_start => 4960})
    end,
    _assert_subject@2 = erlang:element(
        3,
        get(<<(http_server_mock:base_url(Server))/binary, "/job"/utf8>>)
    ),
    _assert_subject@3 = <<"complete"/utf8>>,
    case _assert_subject@2 =:= _assert_subject@3 of
        true -> nil;
        false -> erlang:error(#{gleam_error => assert,
                message => <<"Assertion failed."/utf8>>,
                file => <<?FILEPATH/utf8>>,
                module => <<"http_server_mock_erlang_test"/utf8>>,
                function => <<"scenarios_model_stateful_sequences_test"/utf8>>,
                line => 171,
                kind => binary_operator,
                operator => '==',
                left => #{kind => expression,
                    value => _assert_subject@2,
                    start => 5036,
                    'end' => 5089
                    },
                right => #{kind => literal,
                    value => _assert_subject@3,
                    start => 5093,
                    'end' => 5103
                    },
                start => 5029,
                'end' => 5103,
                expression_start => 5036})
    end,
    http_server_mock:stop(Server).
