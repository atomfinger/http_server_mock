-module(http_server_mock@integration_test).
-compile([no_auto_import, nowarn_unused_vars, nowarn_unused_function, nowarn_nomatch, inline]).
-define(FILEPATH, "test/http_server_mock/integration_test.gleam").
-export([simple_get_stub_test/0, unmatched_request_returns_404_test/0, stub_with_response_headers_test/0, multiple_stubs_different_paths_test/0, recorded_requests_tracks_calls_test/0, verify_called_times_test/0, reset_stubs_removes_all_stubs_test/0, reset_requests_clears_history_test/0, query_param_matching_test/0, admin_health_endpoint_test/0, admin_stubs_list_test/0, admin_delete_stubs_test/0, unmatched_requests_test/0, post_with_body_matching_test/0]).
-export_type([test_response/0]).

-type test_response() :: {test_response,
        integer(),
        list({binary(), binary()}),
        binary()}.

-file("test/http_server_mock/integration_test.gleam", 20).
-spec get(binary()) -> test_response().
get(Url) ->
    Http_request@1 = case gleam@http@request:to(Url) of
        {ok, Http_request} -> Http_request;
        _assert_fail ->
            erlang:error(#{gleam_error => let_assert,
                        message => <<"Pattern match failed, no pattern matched the value."/utf8>>,
                        file => <<?FILEPATH/utf8>>,
                        module => <<"http_server_mock/integration_test"/utf8>>,
                        function => <<"get"/utf8>>,
                        line => 21,
                        value => _assert_fail,
                        start => 549,
                        'end' => 594,
                        pattern_start => 560,
                        pattern_end => 576})
    end,
    Http_response@1 = case gleam@httpc:send(Http_request@1) of
        {ok, Http_response} -> Http_response;
        _assert_fail@1 ->
            erlang:error(#{gleam_error => let_assert,
                        message => <<"Pattern match failed, no pattern matched the value."/utf8>>,
                        file => <<?FILEPATH/utf8>>,
                        module => <<"http_server_mock/integration_test"/utf8>>,
                        function => <<"get"/utf8>>,
                        line => 22,
                        value => _assert_fail@1,
                        start => 597,
                        'end' => 652,
                        pattern_start => 608,
                        pattern_end => 625})
    end,
    {test_response,
        erlang:element(2, Http_response@1),
        erlang:element(3, Http_response@1),
        erlang:element(4, Http_response@1)}.

-file("test/http_server_mock/integration_test.gleam", 31).
-spec post(binary(), binary(), binary()) -> test_response().
post(Url, Body, Content_type) ->
    Base_request@1 = case gleam@http@request:to(Url) of
        {ok, Base_request} -> Base_request;
        _assert_fail ->
            erlang:error(#{gleam_error => let_assert,
                        message => <<"Pattern match failed, no pattern matched the value."/utf8>>,
                        file => <<?FILEPATH/utf8>>,
                        module => <<"http_server_mock/integration_test"/utf8>>,
                        function => <<"post"/utf8>>,
                        line => 32,
                        value => _assert_fail,
                        start => 917,
                        'end' => 962,
                        pattern_start => 928,
                        pattern_end => 944})
    end,
    Http_response@1 = case begin
        _pipe = Base_request@1,
        _pipe@1 = gleam@http@request:set_method(_pipe, post),
        _pipe@2 = gleam@http@request:set_body(_pipe@1, Body),
        _pipe@3 = gleam@http@request:set_header(
            _pipe@2,
            <<"content-type"/utf8>>,
            Content_type
        ),
        gleam@httpc:send(_pipe@3)
    end of
        {ok, Http_response} -> Http_response;
        _assert_fail@1 ->
            erlang:error(#{gleam_error => let_assert,
                        message => <<"Pattern match failed, no pattern matched the value."/utf8>>,
                        file => <<?FILEPATH/utf8>>,
                        module => <<"http_server_mock/integration_test"/utf8>>,
                        function => <<"post"/utf8>>,
                        line => 33,
                        value => _assert_fail@1,
                        start => 965,
                        'end' => 1153,
                        pattern_start => 976,
                        pattern_end => 993})
    end,
    {test_response,
        erlang:element(2, Http_response@1),
        erlang:element(3, Http_response@1),
        erlang:element(4, Http_response@1)}.

-file("test/http_server_mock/integration_test.gleam", 47).
-spec delete(binary()) -> test_response().
delete(Url) ->
    Base_request@1 = case gleam@http@request:to(Url) of
        {ok, Base_request} -> Base_request;
        _assert_fail ->
            erlang:error(#{gleam_error => let_assert,
                        message => <<"Pattern match failed, no pattern matched the value."/utf8>>,
                        file => <<?FILEPATH/utf8>>,
                        module => <<"http_server_mock/integration_test"/utf8>>,
                        function => <<"delete"/utf8>>,
                        line => 48,
                        value => _assert_fail,
                        start => 1386,
                        'end' => 1431,
                        pattern_start => 1397,
                        pattern_end => 1413})
    end,
    Http_response@1 = case begin
        _pipe = Base_request@1,
        _pipe@1 = gleam@http@request:set_method(_pipe, delete),
        gleam@httpc:send(_pipe@1)
    end of
        {ok, Http_response} -> Http_response;
        _assert_fail@1 ->
            erlang:error(#{gleam_error => let_assert,
                        message => <<"Pattern match failed, no pattern matched the value."/utf8>>,
                        file => <<?FILEPATH/utf8>>,
                        module => <<"http_server_mock/integration_test"/utf8>>,
                        function => <<"delete"/utf8>>,
                        line => 49,
                        value => _assert_fail@1,
                        start => 1434,
                        'end' => 1538,
                        pattern_start => 1445,
                        pattern_end => 1462})
    end,
    {test_response,
        erlang:element(2, Http_response@1),
        erlang:element(3, Http_response@1),
        erlang:element(4, Http_response@1)}.

-file("test/http_server_mock/integration_test.gleam", 60).
-spec simple_get_stub_test() -> http_server_mock@internal@server:mock_server(http_server_mock@internal@server:stopped()).
simple_get_stub_test() ->
    Server = begin
        _pipe = http_server_mock:new(http_server_mock_erlang:server()),
        http_server_mock:start(_pipe)
    end,
    case http_server_mock:add_stub(
        Server,
        begin
            _pipe@1 = http_server_mock@stub_builder:new(),
            _pipe@4 = http_server_mock@stub_builder:matching(
                _pipe@1,
                begin
                    _pipe@2 = http_server_mock@matcher:new(),
                    _pipe@3 = http_server_mock@matcher:method(_pipe@2, get),
                    http_server_mock@matcher:path(_pipe@3, <<"/hello"/utf8>>)
                end
            ),
            _pipe@7 = http_server_mock@stub_builder:responding_with(
                _pipe@4,
                begin
                    _pipe@5 = http_server_mock@response:new(),
                    _pipe@6 = http_server_mock@response:status(_pipe@5, 200),
                    http_server_mock@response:body(_pipe@6, <<"world"/utf8>>)
                end
            ),
            http_server_mock@stub_builder:build(_pipe@7)
        end
    ) of
        {ok, _} -> nil;
        _assert_fail ->
            erlang:error(#{gleam_error => let_assert,
                        message => <<"Pattern match failed, no pattern matched the value."/utf8>>,
                        file => <<?FILEPATH/utf8>>,
                        module => <<"http_server_mock/integration_test"/utf8>>,
                        function => <<"simple_get_stub_test"/utf8>>,
                        line => 65,
                        value => _assert_fail,
                        start => 1803,
                        'end' => 2215,
                        pattern_start => 1814,
                        pattern_end => 1819})
    end,
    Http_response = get(
        <<(http_server_mock:base_url(Server))/binary, "/hello"/utf8>>
    ),
    _assert_subject = erlang:element(2, Http_response),
    _assert_subject@1 = 200,
    case _assert_subject =:= _assert_subject@1 of
        true -> nil;
        false -> erlang:error(#{gleam_error => assert,
                message => <<"Assertion failed."/utf8>>,
                file => <<?FILEPATH/utf8>>,
                module => <<"http_server_mock/integration_test"/utf8>>,
                function => <<"simple_get_stub_test"/utf8>>,
                line => 81,
                kind => binary_operator,
                operator => '==',
                left => #{kind => expression,
                    value => _assert_subject,
                    start => 2299,
                    'end' => 2319
                    },
                right => #{kind => literal,
                    value => _assert_subject@1,
                    start => 2323,
                    'end' => 2326
                    },
                start => 2292,
                'end' => 2326,
                expression_start => 2299})
    end,
    _assert_subject@2 = erlang:element(4, Http_response),
    _assert_subject@3 = <<"world"/utf8>>,
    case _assert_subject@2 =:= _assert_subject@3 of
        true -> nil;
        false -> erlang:error(#{gleam_error => assert,
                message => <<"Assertion failed."/utf8>>,
                file => <<?FILEPATH/utf8>>,
                module => <<"http_server_mock/integration_test"/utf8>>,
                function => <<"simple_get_stub_test"/utf8>>,
                line => 82,
                kind => binary_operator,
                operator => '==',
                left => #{kind => expression,
                    value => _assert_subject@2,
                    start => 2336,
                    'end' => 2354
                    },
                right => #{kind => literal,
                    value => _assert_subject@3,
                    start => 2358,
                    'end' => 2365
                    },
                start => 2329,
                'end' => 2365,
                expression_start => 2336})
    end,
    http_server_mock:stop(Server).

-file("test/http_server_mock/integration_test.gleam", 87).
-spec unmatched_request_returns_404_test() -> http_server_mock@internal@server:mock_server(http_server_mock@internal@server:stopped()).
unmatched_request_returns_404_test() ->
    Server = begin
        _pipe = http_server_mock:new(http_server_mock_erlang:server()),
        http_server_mock:start(_pipe)
    end,
    _assert_subject = erlang:element(
        2,
        get(
            <<(http_server_mock:base_url(Server))/binary, "/no-such-path"/utf8>>
        )
    ),
    _assert_subject@1 = 404,
    case _assert_subject =:= _assert_subject@1 of
        true -> nil;
        false -> erlang:error(#{gleam_error => assert,
                message => <<"Assertion failed."/utf8>>,
                file => <<?FILEPATH/utf8>>,
                module => <<"http_server_mock/integration_test"/utf8>>,
                function => <<"unmatched_request_returns_404_test"/utf8>>,
                line => 92,
                kind => binary_operator,
                operator => '==',
                left => #{kind => expression,
                    value => _assert_subject,
                    start => 2564,
                    'end' => 2628
                    },
                right => #{kind => literal,
                    value => _assert_subject@1,
                    start => 2632,
                    'end' => 2635
                    },
                start => 2557,
                'end' => 2635,
                expression_start => 2564})
    end,
    http_server_mock:stop(Server).

-file("test/http_server_mock/integration_test.gleam", 97).
-spec stub_with_response_headers_test() -> http_server_mock@internal@server:mock_server(http_server_mock@internal@server:stopped()).
stub_with_response_headers_test() ->
    Server = begin
        _pipe = http_server_mock:new(http_server_mock_erlang:server()),
        http_server_mock:start(_pipe)
    end,
    case http_server_mock:add_stub(
        Server,
        begin
            _pipe@1 = http_server_mock@stub_builder:new(),
            _pipe@3 = http_server_mock@stub_builder:matching(
                _pipe@1,
                begin
                    _pipe@2 = http_server_mock@matcher:new(),
                    http_server_mock@matcher:path(
                        _pipe@2,
                        <<"/json-data"/utf8>>
                    )
                end
            ),
            _pipe@7 = http_server_mock@stub_builder:responding_with(
                _pipe@3,
                begin
                    _pipe@4 = http_server_mock@response:new(),
                    _pipe@5 = http_server_mock@response:status(_pipe@4, 200),
                    _pipe@6 = http_server_mock@response:header(
                        _pipe@5,
                        <<"content-type"/utf8>>,
                        <<"application/json"/utf8>>
                    ),
                    http_server_mock@response:json_body(
                        _pipe@6,
                        <<"{\"ok\":true}"/utf8>>
                    )
                end
            ),
            http_server_mock@stub_builder:build(_pipe@7)
        end
    ) of
        {ok, _} -> nil;
        _assert_fail ->
            erlang:error(#{gleam_error => let_assert,
                        message => <<"Pattern match failed, no pattern matched the value."/utf8>>,
                        file => <<?FILEPATH/utf8>>,
                        module => <<"http_server_mock/integration_test"/utf8>>,
                        function => <<"stub_with_response_headers_test"/utf8>>,
                        line => 102,
                        value => _assert_fail,
                        start => 2824,
                        'end' => 3274,
                        pattern_start => 2835,
                        pattern_end => 2840})
    end,
    Http_response = get(
        <<(http_server_mock:base_url(Server))/binary, "/json-data"/utf8>>
    ),
    _assert_subject = erlang:element(2, Http_response),
    _assert_subject@1 = 200,
    case _assert_subject =:= _assert_subject@1 of
        true -> nil;
        false -> erlang:error(#{gleam_error => assert,
                message => <<"Assertion failed."/utf8>>,
                file => <<?FILEPATH/utf8>>,
                module => <<"http_server_mock/integration_test"/utf8>>,
                function => <<"stub_with_response_headers_test"/utf8>>,
                line => 117,
                kind => binary_operator,
                operator => '==',
                left => #{kind => expression,
                    value => _assert_subject,
                    start => 3362,
                    'end' => 3382
                    },
                right => #{kind => literal,
                    value => _assert_subject@1,
                    start => 3386,
                    'end' => 3389
                    },
                start => 3355,
                'end' => 3389,
                expression_start => 3362})
    end,
    _assert_subject@2 = erlang:element(4, Http_response),
    _assert_subject@3 = <<"{\"ok\":true}"/utf8>>,
    case _assert_subject@2 =:= _assert_subject@3 of
        true -> nil;
        false -> erlang:error(#{gleam_error => assert,
                message => <<"Assertion failed."/utf8>>,
                file => <<?FILEPATH/utf8>>,
                module => <<"http_server_mock/integration_test"/utf8>>,
                function => <<"stub_with_response_headers_test"/utf8>>,
                line => 118,
                kind => binary_operator,
                operator => '==',
                left => #{kind => expression,
                    value => _assert_subject@2,
                    start => 3399,
                    'end' => 3417
                    },
                right => #{kind => literal,
                    value => _assert_subject@3,
                    start => 3421,
                    'end' => 3436
                    },
                start => 3392,
                'end' => 3436,
                expression_start => 3399})
    end,
    Content_type = begin
        _pipe@8 = erlang:element(3, Http_response),
        _pipe@9 = gleam@list:key_find(_pipe@8, <<"content-type"/utf8>>),
        gleam@result:unwrap(_pipe@9, <<""/utf8>>)
    end,
    _assert_subject@4 = <<"application/json"/utf8>>,
    case gleam_stdlib:contains_string(Content_type, _assert_subject@4) of
        true -> nil;
        false -> erlang:error(#{gleam_error => assert,
                message => <<"Assertion failed."/utf8>>,
                file => <<?FILEPATH/utf8>>,
                module => <<"http_server_mock/integration_test"/utf8>>,
                function => <<"stub_with_response_headers_test"/utf8>>,
                line => 123,
                kind => function_call,
                arguments => [#{kind => expression,
                        value => Content_type,
                        start => 3571,
                        'end' => 3583
                        }, #{kind => literal,
                        value => _assert_subject@4,
                        start => 3585,
                        'end' => 3603
                        }],
                start => 3548,
                'end' => 3604,
                expression_start => 3555})
    end,
    http_server_mock:stop(Server).

-file("test/http_server_mock/integration_test.gleam", 128).
-spec multiple_stubs_different_paths_test() -> http_server_mock@internal@server:mock_server(http_server_mock@internal@server:stopped()).
multiple_stubs_different_paths_test() ->
    Server = begin
        _pipe = http_server_mock:new(http_server_mock_erlang:server()),
        http_server_mock:start(_pipe)
    end,
    case http_server_mock:add_stub(
        Server,
        begin
            _pipe@1 = http_server_mock@stub_builder:new(),
            _pipe@3 = http_server_mock@stub_builder:matching(
                _pipe@1,
                begin
                    _pipe@2 = http_server_mock@matcher:new(),
                    http_server_mock@matcher:path(_pipe@2, <<"/a"/utf8>>)
                end
            ),
            _pipe@5 = http_server_mock@stub_builder:responding_with(
                _pipe@3,
                begin
                    _pipe@4 = http_server_mock@response:new(),
                    http_server_mock@response:body(
                        _pipe@4,
                        <<"response-a"/utf8>>
                    )
                end
            ),
            http_server_mock@stub_builder:build(_pipe@5)
        end
    ) of
        {ok, _} -> nil;
        _assert_fail ->
            erlang:error(#{gleam_error => let_assert,
                        message => <<"Pattern match failed, no pattern matched the value."/utf8>>,
                        file => <<?FILEPATH/utf8>>,
                        module => <<"http_server_mock/integration_test"/utf8>>,
                        function => <<"multiple_stubs_different_paths_test"/utf8>>,
                        line => 133,
                        value => _assert_fail,
                        start => 3797,
                        'end' => 4112,
                        pattern_start => 3808,
                        pattern_end => 3813})
    end,
    case http_server_mock:add_stub(
        Server,
        begin
            _pipe@6 = http_server_mock@stub_builder:new(),
            _pipe@8 = http_server_mock@stub_builder:matching(
                _pipe@6,
                begin
                    _pipe@7 = http_server_mock@matcher:new(),
                    http_server_mock@matcher:path(_pipe@7, <<"/b"/utf8>>)
                end
            ),
            _pipe@10 = http_server_mock@stub_builder:responding_with(
                _pipe@8,
                begin
                    _pipe@9 = http_server_mock@response:new(),
                    http_server_mock@response:body(
                        _pipe@9,
                        <<"response-b"/utf8>>
                    )
                end
            ),
            http_server_mock@stub_builder:build(_pipe@10)
        end
    ) of
        {ok, _} -> nil;
        _assert_fail@1 ->
            erlang:error(#{gleam_error => let_assert,
                        message => <<"Pattern match failed, no pattern matched the value."/utf8>>,
                        file => <<?FILEPATH/utf8>>,
                        module => <<"http_server_mock/integration_test"/utf8>>,
                        function => <<"multiple_stubs_different_paths_test"/utf8>>,
                        line => 143,
                        value => _assert_fail@1,
                        start => 4115,
                        'end' => 4430,
                        pattern_start => 4126,
                        pattern_end => 4131})
    end,
    _assert_subject = erlang:element(
        4,
        get(<<(http_server_mock:base_url(Server))/binary, "/a"/utf8>>)
    ),
    _assert_subject@1 = <<"response-a"/utf8>>,
    case _assert_subject =:= _assert_subject@1 of
        true -> nil;
        false -> erlang:error(#{gleam_error => assert,
                message => <<"Assertion failed."/utf8>>,
                file => <<?FILEPATH/utf8>>,
                module => <<"http_server_mock/integration_test"/utf8>>,
                function => <<"multiple_stubs_different_paths_test"/utf8>>,
                line => 154,
                kind => binary_operator,
                operator => '==',
                left => #{kind => expression,
                    value => _assert_subject,
                    start => 4441,
                    'end' => 4492
                    },
                right => #{kind => literal,
                    value => _assert_subject@1,
                    start => 4496,
                    'end' => 4508
                    },
                start => 4434,
                'end' => 4508,
                expression_start => 4441})
    end,
    _assert_subject@2 = erlang:element(
        4,
        get(<<(http_server_mock:base_url(Server))/binary, "/b"/utf8>>)
    ),
    _assert_subject@3 = <<"response-b"/utf8>>,
    case _assert_subject@2 =:= _assert_subject@3 of
        true -> nil;
        false -> erlang:error(#{gleam_error => assert,
                message => <<"Assertion failed."/utf8>>,
                file => <<?FILEPATH/utf8>>,
                module => <<"http_server_mock/integration_test"/utf8>>,
                function => <<"multiple_stubs_different_paths_test"/utf8>>,
                line => 155,
                kind => binary_operator,
                operator => '==',
                left => #{kind => expression,
                    value => _assert_subject@2,
                    start => 4518,
                    'end' => 4569
                    },
                right => #{kind => literal,
                    value => _assert_subject@3,
                    start => 4573,
                    'end' => 4585
                    },
                start => 4511,
                'end' => 4585,
                expression_start => 4518})
    end,
    http_server_mock:stop(Server).

-file("test/http_server_mock/integration_test.gleam", 160).
-spec recorded_requests_tracks_calls_test() -> http_server_mock@internal@server:mock_server(http_server_mock@internal@server:stopped()).
recorded_requests_tracks_calls_test() ->
    Server = begin
        _pipe = http_server_mock:new(http_server_mock_erlang:server()),
        http_server_mock:start(_pipe)
    end,
    case http_server_mock:add_stub(
        Server,
        begin
            _pipe@1 = http_server_mock@stub_builder:new(),
            _pipe@3 = http_server_mock@stub_builder:matching(
                _pipe@1,
                begin
                    _pipe@2 = http_server_mock@matcher:new(),
                    http_server_mock@matcher:path(_pipe@2, <<"/track"/utf8>>)
                end
            ),
            _pipe@5 = http_server_mock@stub_builder:responding_with(
                _pipe@3,
                begin
                    _pipe@4 = http_server_mock@response:new(),
                    http_server_mock@response:body(_pipe@4, <<"ok"/utf8>>)
                end
            ),
            http_server_mock@stub_builder:build(_pipe@5)
        end
    ) of
        {ok, _} -> nil;
        _assert_fail ->
            erlang:error(#{gleam_error => let_assert,
                        message => <<"Pattern match failed, no pattern matched the value."/utf8>>,
                        file => <<?FILEPATH/utf8>>,
                        module => <<"http_server_mock/integration_test"/utf8>>,
                        function => <<"recorded_requests_tracks_calls_test"/utf8>>,
                        line => 165,
                        value => _assert_fail,
                        start => 4778,
                        'end' => 5089,
                        pattern_start => 4789,
                        pattern_end => 4794})
    end,
    _ = get(<<(http_server_mock:base_url(Server))/binary, "/track"/utf8>>),
    _ = get(<<(http_server_mock:base_url(Server))/binary, "/track"/utf8>>),
    Recorded_requests@1 = case http_server_mock:recorded_requests(Server) of
        {ok, Recorded_requests} -> Recorded_requests;
        _assert_fail@1 ->
            erlang:error(#{gleam_error => let_assert,
                        message => <<"Pattern match failed, no pattern matched the value."/utf8>>,
                        file => <<?FILEPATH/utf8>>,
                        module => <<"http_server_mock/integration_test"/utf8>>,
                        function => <<"recorded_requests_tracks_calls_test"/utf8>>,
                        line => 179,
                        value => _assert_fail@1,
                        start => 5216,
                        'end' => 5293,
                        pattern_start => 5227,
                        pattern_end => 5248})
    end,
    Tracked = gleam@list:filter(
        Recorded_requests@1,
        fun(Recorded) -> erlang:element(4, Recorded) =:= <<"/track"/utf8>> end
    ),
    _assert_subject = erlang:length(Tracked),
    _assert_subject@1 = 2,
    case _assert_subject =:= _assert_subject@1 of
        true -> nil;
        false -> erlang:error(#{gleam_error => assert,
                message => <<"Assertion failed."/utf8>>,
                file => <<?FILEPATH/utf8>>,
                module => <<"http_server_mock/integration_test"/utf8>>,
                function => <<"recorded_requests_tracks_calls_test"/utf8>>,
                line => 182,
                kind => binary_operator,
                operator => '==',
                left => #{kind => expression,
                    value => _assert_subject,
                    start => 5398,
                    'end' => 5418
                    },
                right => #{kind => literal,
                    value => _assert_subject@1,
                    start => 5422,
                    'end' => 5423
                    },
                start => 5391,
                'end' => 5423,
                expression_start => 5398})
    end,
    http_server_mock:stop(Server).

-file("test/http_server_mock/integration_test.gleam", 187).
-spec verify_called_times_test() -> http_server_mock@internal@server:mock_server(http_server_mock@internal@server:stopped()).
verify_called_times_test() ->
    Server = begin
        _pipe = http_server_mock:new(http_server_mock_erlang:server()),
        http_server_mock:start(_pipe)
    end,
    Request_matcher = begin
        _pipe@1 = http_server_mock@matcher:new(),
        _pipe@2 = http_server_mock@matcher:method(_pipe@1, get),
        http_server_mock@matcher:path(_pipe@2, <<"/counted"/utf8>>)
    end,
    case http_server_mock:add_stub(
        Server,
        begin
            _pipe@3 = http_server_mock@stub_builder:new(),
            _pipe@4 = http_server_mock@stub_builder:matching(
                _pipe@3,
                Request_matcher
            ),
            _pipe@6 = http_server_mock@stub_builder:responding_with(
                _pipe@4,
                begin
                    _pipe@5 = http_server_mock@response:new(),
                    http_server_mock@response:body(_pipe@5, <<"ok"/utf8>>)
                end
            ),
            http_server_mock@stub_builder:build(_pipe@6)
        end
    ) of
        {ok, _} -> nil;
        _assert_fail ->
            erlang:error(#{gleam_error => let_assert,
                        message => <<"Pattern match failed, no pattern matched the value."/utf8>>,
                        file => <<?FILEPATH/utf8>>,
                        module => <<"http_server_mock/integration_test"/utf8>>,
                        function => <<"verify_called_times_test"/utf8>>,
                        line => 194,
                        value => _assert_fail,
                        start => 5703,
                        'end' => 5990,
                        pattern_start => 5714,
                        pattern_end => 5719})
    end,
    _ = get(<<(http_server_mock:base_url(Server))/binary, "/counted"/utf8>>),
    _ = get(<<(http_server_mock:base_url(Server))/binary, "/counted"/utf8>>),
    _ = get(<<(http_server_mock:base_url(Server))/binary, "/counted"/utf8>>),
    http_server_mock@verify:called_times(Server, Request_matcher, 3),
    http_server_mock:stop(Server).

-file("test/http_server_mock/integration_test.gleam", 214).
-spec reset_stubs_removes_all_stubs_test() -> http_server_mock@internal@server:mock_server(http_server_mock@internal@server:stopped()).
reset_stubs_removes_all_stubs_test() ->
    Server = begin
        _pipe = http_server_mock:new(http_server_mock_erlang:server()),
        http_server_mock:start(_pipe)
    end,
    case http_server_mock:add_stub(
        Server,
        begin
            _pipe@1 = http_server_mock@stub_builder:new(),
            _pipe@3 = http_server_mock@stub_builder:matching(
                _pipe@1,
                begin
                    _pipe@2 = http_server_mock@matcher:new(),
                    http_server_mock@matcher:path(_pipe@2, <<"/gone"/utf8>>)
                end
            ),
            _pipe@5 = http_server_mock@stub_builder:responding_with(
                _pipe@3,
                begin
                    _pipe@4 = http_server_mock@response:new(),
                    http_server_mock@response:body(_pipe@4, <<"was here"/utf8>>)
                end
            ),
            http_server_mock@stub_builder:build(_pipe@5)
        end
    ) of
        {ok, _} -> nil;
        _assert_fail ->
            erlang:error(#{gleam_error => let_assert,
                        message => <<"Pattern match failed, no pattern matched the value."/utf8>>,
                        file => <<?FILEPATH/utf8>>,
                        module => <<"http_server_mock/integration_test"/utf8>>,
                        function => <<"reset_stubs_removes_all_stubs_test"/utf8>>,
                        line => 219,
                        value => _assert_fail,
                        start => 6423,
                        'end' => 6739,
                        pattern_start => 6434,
                        pattern_end => 6439})
    end,
    _assert_subject = erlang:element(
        2,
        get(<<(http_server_mock:base_url(Server))/binary, "/gone"/utf8>>)
    ),
    _assert_subject@1 = 200,
    case _assert_subject =:= _assert_subject@1 of
        true -> nil;
        false -> erlang:error(#{gleam_error => assert,
                message => <<"Assertion failed."/utf8>>,
                file => <<?FILEPATH/utf8>>,
                module => <<"http_server_mock/integration_test"/utf8>>,
                function => <<"reset_stubs_removes_all_stubs_test"/utf8>>,
                line => 230,
                kind => binary_operator,
                operator => '==',
                left => #{kind => expression,
                    value => _assert_subject,
                    start => 6750,
                    'end' => 6806
                    },
                right => #{kind => literal,
                    value => _assert_subject@1,
                    start => 6810,
                    'end' => 6813
                    },
                start => 6743,
                'end' => 6813,
                expression_start => 6750})
    end,
    http_server_mock:reset_stubs(Server),
    _assert_subject@2 = erlang:element(
        2,
        get(<<(http_server_mock:base_url(Server))/binary, "/gone"/utf8>>)
    ),
    _assert_subject@3 = 404,
    case _assert_subject@2 =:= _assert_subject@3 of
        true -> nil;
        false -> erlang:error(#{gleam_error => assert,
                message => <<"Assertion failed."/utf8>>,
                file => <<?FILEPATH/utf8>>,
                module => <<"http_server_mock/integration_test"/utf8>>,
                function => <<"reset_stubs_removes_all_stubs_test"/utf8>>,
                line => 232,
                kind => binary_operator,
                operator => '==',
                left => #{kind => expression,
                    value => _assert_subject@2,
                    start => 6862,
                    'end' => 6918
                    },
                right => #{kind => literal,
                    value => _assert_subject@3,
                    start => 6922,
                    'end' => 6925
                    },
                start => 6855,
                'end' => 6925,
                expression_start => 6862})
    end,
    http_server_mock:stop(Server).

-file("test/http_server_mock/integration_test.gleam", 237).
-spec reset_requests_clears_history_test() -> http_server_mock@internal@server:mock_server(http_server_mock@internal@server:stopped()).
reset_requests_clears_history_test() ->
    Server = begin
        _pipe = http_server_mock:new(http_server_mock_erlang:server()),
        http_server_mock:start(_pipe)
    end,
    case http_server_mock:add_stub(
        Server,
        begin
            _pipe@1 = http_server_mock@stub_builder:new(),
            _pipe@3 = http_server_mock@stub_builder:matching(
                _pipe@1,
                begin
                    _pipe@2 = http_server_mock@matcher:new(),
                    http_server_mock@matcher:path(_pipe@2, <<"/call"/utf8>>)
                end
            ),
            _pipe@5 = http_server_mock@stub_builder:responding_with(
                _pipe@3,
                begin
                    _pipe@4 = http_server_mock@response:new(),
                    http_server_mock@response:body(_pipe@4, <<"ok"/utf8>>)
                end
            ),
            http_server_mock@stub_builder:build(_pipe@5)
        end
    ) of
        {ok, _} -> nil;
        _assert_fail ->
            erlang:error(#{gleam_error => let_assert,
                        message => <<"Pattern match failed, no pattern matched the value."/utf8>>,
                        file => <<?FILEPATH/utf8>>,
                        module => <<"http_server_mock/integration_test"/utf8>>,
                        function => <<"reset_requests_clears_history_test"/utf8>>,
                        line => 242,
                        value => _assert_fail,
                        start => 7117,
                        'end' => 7427,
                        pattern_start => 7128,
                        pattern_end => 7133})
    end,
    _ = get(<<(http_server_mock:base_url(Server))/binary, "/call"/utf8>>),
    http_server_mock:reset_requests(Server),
    Recorded_requests@1 = case http_server_mock:recorded_requests(Server) of
        {ok, Recorded_requests} -> Recorded_requests;
        _assert_fail@1 ->
            erlang:error(#{gleam_error => let_assert,
                        message => <<"Pattern match failed, no pattern matched the value."/utf8>>,
                        file => <<?FILEPATH/utf8>>,
                        module => <<"http_server_mock/integration_test"/utf8>>,
                        function => <<"reset_requests_clears_history_test"/utf8>>,
                        line => 256,
                        value => _assert_fail@1,
                        start => 7534,
                        'end' => 7611,
                        pattern_start => 7545,
                        pattern_end => 7566})
    end,
    _assert_subject = [],
    case Recorded_requests@1 =:= _assert_subject of
        true -> nil;
        false -> erlang:error(#{gleam_error => assert,
                message => <<"Assertion failed."/utf8>>,
                file => <<?FILEPATH/utf8>>,
                module => <<"http_server_mock/integration_test"/utf8>>,
                function => <<"reset_requests_clears_history_test"/utf8>>,
                line => 257,
                kind => binary_operator,
                operator => '==',
                left => #{kind => expression,
                    value => Recorded_requests@1,
                    start => 7621,
                    'end' => 7638
                    },
                right => #{kind => literal,
                    value => _assert_subject,
                    start => 7642,
                    'end' => 7644
                    },
                start => 7614,
                'end' => 7644,
                expression_start => 7621})
    end,
    http_server_mock:stop(Server).

-file("test/http_server_mock/integration_test.gleam", 262).
-spec query_param_matching_test() -> http_server_mock@internal@server:mock_server(http_server_mock@internal@server:stopped()).
query_param_matching_test() ->
    Server = begin
        _pipe = http_server_mock:new(http_server_mock_erlang:server()),
        http_server_mock:start(_pipe)
    end,
    Request_matcher = begin
        _pipe@1 = http_server_mock@matcher:new(),
        _pipe@2 = http_server_mock@matcher:path(_pipe@1, <<"/search"/utf8>>),
        http_server_mock@matcher:query_param(
            _pipe@2,
            <<"q"/utf8>>,
            <<"gleam"/utf8>>
        )
    end,
    case http_server_mock:add_stub(
        Server,
        begin
            _pipe@3 = http_server_mock@stub_builder:new(),
            _pipe@4 = http_server_mock@stub_builder:matching(
                _pipe@3,
                Request_matcher
            ),
            _pipe@6 = http_server_mock@stub_builder:responding_with(
                _pipe@4,
                begin
                    _pipe@5 = http_server_mock@response:new(),
                    http_server_mock@response:body(_pipe@5, <<"found"/utf8>>)
                end
            ),
            http_server_mock@stub_builder:build(_pipe@6)
        end
    ) of
        {ok, _} -> nil;
        _assert_fail ->
            erlang:error(#{gleam_error => let_assert,
                        message => <<"Pattern match failed, no pattern matched the value."/utf8>>,
                        file => <<?FILEPATH/utf8>>,
                        module => <<"http_server_mock/integration_test"/utf8>>,
                        function => <<"query_param_matching_test"/utf8>>,
                        line => 271,
                        value => _assert_fail,
                        start => 7941,
                        'end' => 8231,
                        pattern_start => 7952,
                        pattern_end => 7957})
    end,
    _assert_subject = erlang:element(
        4,
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
                module => <<"http_server_mock/integration_test"/utf8>>,
                function => <<"query_param_matching_test"/utf8>>,
                line => 282,
                kind => binary_operator,
                operator => '==',
                left => #{kind => expression,
                    value => _assert_subject,
                    start => 8242,
                    'end' => 8306
                    },
                right => #{kind => literal,
                    value => _assert_subject@1,
                    start => 8314,
                    'end' => 8321
                    },
                start => 8235,
                'end' => 8321,
                expression_start => 8242})
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
                module => <<"http_server_mock/integration_test"/utf8>>,
                function => <<"query_param_matching_test"/utf8>>,
                line => 284,
                kind => binary_operator,
                operator => '==',
                left => #{kind => expression,
                    value => _assert_subject@2,
                    start => 8331,
                    'end' => 8397
                    },
                right => #{kind => literal,
                    value => _assert_subject@3,
                    start => 8405,
                    'end' => 8408
                    },
                start => 8324,
                'end' => 8408,
                expression_start => 8331})
    end,
    http_server_mock:stop(Server).

-file("test/http_server_mock/integration_test.gleam", 290).
-spec admin_health_endpoint_test() -> http_server_mock@internal@server:mock_server(http_server_mock@internal@server:stopped()).
admin_health_endpoint_test() ->
    Server = begin
        _pipe = http_server_mock:new(http_server_mock_erlang:server()),
        http_server_mock:start(_pipe)
    end,
    Http_response = get(
        <<(http_server_mock:base_url(Server))/binary, "/__admin/health"/utf8>>
    ),
    _assert_subject = erlang:element(2, Http_response),
    _assert_subject@1 = 200,
    case _assert_subject =:= _assert_subject@1 of
        true -> nil;
        false -> erlang:error(#{gleam_error => assert,
                message => <<"Assertion failed."/utf8>>,
                file => <<?FILEPATH/utf8>>,
                module => <<"http_server_mock/integration_test"/utf8>>,
                function => <<"admin_health_endpoint_test"/utf8>>,
                line => 297,
                kind => binary_operator,
                operator => '==',
                left => #{kind => expression,
                    value => _assert_subject,
                    start => 8685,
                    'end' => 8705
                    },
                right => #{kind => literal,
                    value => _assert_subject@1,
                    start => 8709,
                    'end' => 8712
                    },
                start => 8678,
                'end' => 8712,
                expression_start => 8685})
    end,
    _assert_subject@2 = erlang:element(4, Http_response),
    _assert_subject@3 = <<"{\"status\":\"ok\"}"/utf8>>,
    case _assert_subject@2 =:= _assert_subject@3 of
        true -> nil;
        false -> erlang:error(#{gleam_error => assert,
                message => <<"Assertion failed."/utf8>>,
                file => <<?FILEPATH/utf8>>,
                module => <<"http_server_mock/integration_test"/utf8>>,
                function => <<"admin_health_endpoint_test"/utf8>>,
                line => 298,
                kind => binary_operator,
                operator => '==',
                left => #{kind => expression,
                    value => _assert_subject@2,
                    start => 8722,
                    'end' => 8740
                    },
                right => #{kind => literal,
                    value => _assert_subject@3,
                    start => 8744,
                    'end' => 8765
                    },
                start => 8715,
                'end' => 8765,
                expression_start => 8722})
    end,
    http_server_mock:stop(Server).

-file("test/http_server_mock/integration_test.gleam", 303).
-spec admin_stubs_list_test() -> http_server_mock@internal@server:mock_server(http_server_mock@internal@server:stopped()).
admin_stubs_list_test() ->
    Server = begin
        _pipe = http_server_mock:new(http_server_mock_erlang:server()),
        http_server_mock:start(_pipe)
    end,
    case http_server_mock:add_stub(
        Server,
        begin
            _pipe@1 = http_server_mock@stub_builder:new(),
            _pipe@3 = http_server_mock@stub_builder:matching(
                _pipe@1,
                begin
                    _pipe@2 = http_server_mock@matcher:new(),
                    http_server_mock@matcher:path(_pipe@2, <<"/listed"/utf8>>)
                end
            ),
            _pipe@5 = http_server_mock@stub_builder:responding_with(
                _pipe@3,
                begin
                    _pipe@4 = http_server_mock@response:new(),
                    http_server_mock@response:body(_pipe@4, <<"ok"/utf8>>)
                end
            ),
            _pipe@6 = http_server_mock@stub_builder:with_id(
                _pipe@5,
                <<"listed-stub"/utf8>>
            ),
            http_server_mock@stub_builder:build(_pipe@6)
        end
    ) of
        {ok, _} -> nil;
        _assert_fail ->
            erlang:error(#{gleam_error => let_assert,
                        message => <<"Pattern match failed, no pattern matched the value."/utf8>>,
                        file => <<?FILEPATH/utf8>>,
                        module => <<"http_server_mock/integration_test"/utf8>>,
                        function => <<"admin_stubs_list_test"/utf8>>,
                        line => 308,
                        value => _assert_fail,
                        start => 8944,
                        'end' => 9303,
                        pattern_start => 8955,
                        pattern_end => 8960})
    end,
    Http_response = get(
        <<(http_server_mock:base_url(Server))/binary, "/__admin/stubs"/utf8>>
    ),
    _assert_subject = erlang:element(2, Http_response),
    _assert_subject@1 = 200,
    case _assert_subject =:= _assert_subject@1 of
        true -> nil;
        false -> erlang:error(#{gleam_error => assert,
                message => <<"Assertion failed."/utf8>>,
                file => <<?FILEPATH/utf8>>,
                module => <<"http_server_mock/integration_test"/utf8>>,
                function => <<"admin_stubs_list_test"/utf8>>,
                line => 321,
                kind => binary_operator,
                operator => '==',
                left => #{kind => expression,
                    value => _assert_subject,
                    start => 9395,
                    'end' => 9415
                    },
                right => #{kind => literal,
                    value => _assert_subject@1,
                    start => 9419,
                    'end' => 9422
                    },
                start => 9388,
                'end' => 9422,
                expression_start => 9395})
    end,
    _assert_subject@2 = erlang:element(4, Http_response),
    _assert_subject@3 = <<"listed-stub"/utf8>>,
    case gleam_stdlib:contains_string(_assert_subject@2, _assert_subject@3) of
        true -> nil;
        false -> erlang:error(#{gleam_error => assert,
                message => <<"Assertion failed."/utf8>>,
                file => <<?FILEPATH/utf8>>,
                module => <<"http_server_mock/integration_test"/utf8>>,
                function => <<"admin_stubs_list_test"/utf8>>,
                line => 322,
                kind => function_call,
                arguments => [#{kind => expression,
                        value => _assert_subject@2,
                        start => 9448,
                        'end' => 9466
                        }, #{kind => literal,
                        value => _assert_subject@3,
                        start => 9468,
                        'end' => 9481
                        }],
                start => 9425,
                'end' => 9482,
                expression_start => 9432})
    end,
    http_server_mock:stop(Server).

-file("test/http_server_mock/integration_test.gleam", 327).
-spec admin_delete_stubs_test() -> http_server_mock@internal@server:mock_server(http_server_mock@internal@server:stopped()).
admin_delete_stubs_test() ->
    Server = begin
        _pipe = http_server_mock:new(http_server_mock_erlang:server()),
        http_server_mock:start(_pipe)
    end,
    case http_server_mock:add_stub(
        Server,
        begin
            _pipe@1 = http_server_mock@stub_builder:new(),
            _pipe@3 = http_server_mock@stub_builder:matching(
                _pipe@1,
                begin
                    _pipe@2 = http_server_mock@matcher:new(),
                    http_server_mock@matcher:path(_pipe@2, <<"/bye"/utf8>>)
                end
            ),
            _pipe@5 = http_server_mock@stub_builder:responding_with(
                _pipe@3,
                begin
                    _pipe@4 = http_server_mock@response:new(),
                    http_server_mock@response:body(_pipe@4, <<"hi"/utf8>>)
                end
            ),
            http_server_mock@stub_builder:build(_pipe@5)
        end
    ) of
        {ok, _} -> nil;
        _assert_fail ->
            erlang:error(#{gleam_error => let_assert,
                        message => <<"Pattern match failed, no pattern matched the value."/utf8>>,
                        file => <<?FILEPATH/utf8>>,
                        module => <<"http_server_mock/integration_test"/utf8>>,
                        function => <<"admin_delete_stubs_test"/utf8>>,
                        line => 332,
                        value => _assert_fail,
                        start => 9663,
                        'end' => 9972,
                        pattern_start => 9674,
                        pattern_end => 9679})
    end,
    _assert_subject = erlang:element(
        2,
        get(<<(http_server_mock:base_url(Server))/binary, "/bye"/utf8>>)
    ),
    _assert_subject@1 = 200,
    case _assert_subject =:= _assert_subject@1 of
        true -> nil;
        false -> erlang:error(#{gleam_error => assert,
                message => <<"Assertion failed."/utf8>>,
                file => <<?FILEPATH/utf8>>,
                module => <<"http_server_mock/integration_test"/utf8>>,
                function => <<"admin_delete_stubs_test"/utf8>>,
                line => 343,
                kind => binary_operator,
                operator => '==',
                left => #{kind => expression,
                    value => _assert_subject,
                    start => 9983,
                    'end' => 10038
                    },
                right => #{kind => literal,
                    value => _assert_subject@1,
                    start => 10042,
                    'end' => 10045
                    },
                start => 9976,
                'end' => 10045,
                expression_start => 9983})
    end,
    _assert_subject@2 = erlang:element(
        2,
        delete(
            <<(http_server_mock:base_url(Server))/binary,
                "/__admin/stubs"/utf8>>
        )
    ),
    _assert_subject@3 = 200,
    case _assert_subject@2 =:= _assert_subject@3 of
        true -> nil;
        false -> erlang:error(#{gleam_error => assert,
                message => <<"Assertion failed."/utf8>>,
                file => <<?FILEPATH/utf8>>,
                module => <<"http_server_mock/integration_test"/utf8>>,
                function => <<"admin_delete_stubs_test"/utf8>>,
                line => 344,
                kind => binary_operator,
                operator => '==',
                left => #{kind => expression,
                    value => _assert_subject@2,
                    start => 10055,
                    'end' => 10123
                    },
                right => #{kind => literal,
                    value => _assert_subject@3,
                    start => 10131,
                    'end' => 10134
                    },
                start => 10048,
                'end' => 10134,
                expression_start => 10055})
    end,
    _assert_subject@4 = erlang:element(
        2,
        get(<<(http_server_mock:base_url(Server))/binary, "/bye"/utf8>>)
    ),
    _assert_subject@5 = 404,
    case _assert_subject@4 =:= _assert_subject@5 of
        true -> nil;
        false -> erlang:error(#{gleam_error => assert,
                message => <<"Assertion failed."/utf8>>,
                file => <<?FILEPATH/utf8>>,
                module => <<"http_server_mock/integration_test"/utf8>>,
                function => <<"admin_delete_stubs_test"/utf8>>,
                line => 346,
                kind => binary_operator,
                operator => '==',
                left => #{kind => expression,
                    value => _assert_subject@4,
                    start => 10144,
                    'end' => 10199
                    },
                right => #{kind => literal,
                    value => _assert_subject@5,
                    start => 10203,
                    'end' => 10206
                    },
                start => 10137,
                'end' => 10206,
                expression_start => 10144})
    end,
    http_server_mock:stop(Server).

-file("test/http_server_mock/integration_test.gleam", 351).
-spec unmatched_requests_test() -> http_server_mock@internal@server:mock_server(http_server_mock@internal@server:stopped()).
unmatched_requests_test() ->
    Server = begin
        _pipe = http_server_mock:new(http_server_mock_erlang:server()),
        http_server_mock:start(_pipe)
    end,
    case http_server_mock:add_stub(
        Server,
        begin
            _pipe@1 = http_server_mock@stub_builder:new(),
            _pipe@3 = http_server_mock@stub_builder:matching(
                _pipe@1,
                begin
                    _pipe@2 = http_server_mock@matcher:new(),
                    http_server_mock@matcher:path(_pipe@2, <<"/known"/utf8>>)
                end
            ),
            _pipe@4 = http_server_mock@stub_builder:responding_with(
                _pipe@3,
                http_server_mock@response:ok()
            ),
            http_server_mock@stub_builder:build(_pipe@4)
        end
    ) of
        {ok, _} -> nil;
        _assert_fail ->
            erlang:error(#{gleam_error => let_assert,
                        message => <<"Pattern match failed, no pattern matched the value."/utf8>>,
                        file => <<?FILEPATH/utf8>>,
                        module => <<"http_server_mock/integration_test"/utf8>>,
                        function => <<"unmatched_requests_test"/utf8>>,
                        line => 356,
                        value => _assert_fail,
                        start => 10387,
                        'end' => 10648,
                        pattern_start => 10398,
                        pattern_end => 10403})
    end,
    _ = get(<<(http_server_mock:base_url(Server))/binary, "/known"/utf8>>),
    _ = get(<<(http_server_mock:base_url(Server))/binary, "/unknown-a"/utf8>>),
    _ = get(<<(http_server_mock:base_url(Server))/binary, "/unknown-b"/utf8>>),
    Unmatched@1 = case http_server_mock:unmatched_requests(Server) of
        {ok, Unmatched} -> Unmatched;
        _assert_fail@1 ->
            erlang:error(#{gleam_error => let_assert,
                        message => <<"Pattern match failed, no pattern matched the value."/utf8>>,
                        file => <<?FILEPATH/utf8>>,
                        module => <<"http_server_mock/integration_test"/utf8>>,
                        function => <<"unmatched_requests_test"/utf8>>,
                        line => 369,
                        value => _assert_fail@1,
                        start => 10844,
                        'end' => 10914,
                        pattern_start => 10855,
                        pattern_end => 10868})
    end,
    _assert_subject = erlang:length(Unmatched@1),
    _assert_subject@1 = 2,
    case _assert_subject =:= _assert_subject@1 of
        true -> nil;
        false -> erlang:error(#{gleam_error => assert,
                message => <<"Assertion failed."/utf8>>,
                file => <<?FILEPATH/utf8>>,
                module => <<"http_server_mock/integration_test"/utf8>>,
                function => <<"unmatched_requests_test"/utf8>>,
                line => 370,
                kind => binary_operator,
                operator => '==',
                left => #{kind => expression,
                    value => _assert_subject,
                    start => 10924,
                    'end' => 10946
                    },
                right => #{kind => literal,
                    value => _assert_subject@1,
                    start => 10950,
                    'end' => 10951
                    },
                start => 10917,
                'end' => 10951,
                expression_start => 10924})
    end,
    _assert_subject@2 = fun(Req) -> erlang:element(9, Req) =:= none end,
    case gleam@list:all(Unmatched@1, _assert_subject@2) of
        true -> nil;
        false -> erlang:error(#{gleam_error => assert,
                message => <<"Assertion failed."/utf8>>,
                file => <<?FILEPATH/utf8>>,
                module => <<"http_server_mock/integration_test"/utf8>>,
                function => <<"unmatched_requests_test"/utf8>>,
                line => 371,
                kind => function_call,
                arguments => [#{kind => expression,
                        value => Unmatched@1,
                        start => 10970,
                        'end' => 10979
                        }, #{kind => expression,
                        value => _assert_subject@2,
                        start => 10981,
                        'end' => 11027
                        }],
                start => 10954,
                'end' => 11028,
                expression_start => 10961})
    end,
    http_server_mock:stop(Server).

-file("test/http_server_mock/integration_test.gleam", 376).
-spec post_with_body_matching_test() -> http_server_mock@internal@server:mock_server(http_server_mock@internal@server:stopped()).
post_with_body_matching_test() ->
    Server = begin
        _pipe = http_server_mock:new(http_server_mock_erlang:server()),
        http_server_mock:start(_pipe)
    end,
    Request_matcher = begin
        _pipe@1 = http_server_mock@matcher:new(),
        _pipe@2 = http_server_mock@matcher:method(_pipe@1, post),
        _pipe@3 = http_server_mock@matcher:path(_pipe@2, <<"/submit"/utf8>>),
        http_server_mock@matcher:body_containing(_pipe@3, <<"important"/utf8>>)
    end,
    case http_server_mock:add_stub(
        Server,
        begin
            _pipe@4 = http_server_mock@stub_builder:new(),
            _pipe@5 = http_server_mock@stub_builder:matching(
                _pipe@4,
                Request_matcher
            ),
            _pipe@7 = http_server_mock@stub_builder:responding_with(
                _pipe@5,
                begin
                    _pipe@6 = http_server_mock@response:new(),
                    http_server_mock@response:status(_pipe@6, 201)
                end
            ),
            http_server_mock@stub_builder:build(_pipe@7)
        end
    ) of
        {ok, _} -> nil;
        _assert_fail ->
            erlang:error(#{gleam_error => let_assert,
                        message => <<"Pattern match failed, no pattern matched the value."/utf8>>,
                        file => <<?FILEPATH/utf8>>,
                        module => <<"http_server_mock/integration_test"/utf8>>,
                        function => <<"post_with_body_matching_test"/utf8>>,
                        line => 386,
                        value => _assert_fail,
                        start => 11364,
                        'end' => 11652,
                        pattern_start => 11375,
                        pattern_end => 11380})
    end,
    _assert_subject = erlang:element(
        2,
        post(
            <<(http_server_mock:base_url(Server))/binary, "/submit"/utf8>>,
            <<"{\"important\":true}"/utf8>>,
            <<"application/json"/utf8>>
        )
    ),
    _assert_subject@1 = 201,
    case _assert_subject =:= _assert_subject@1 of
        true -> nil;
        false -> erlang:error(#{gleam_error => assert,
                message => <<"Assertion failed."/utf8>>,
                file => <<?FILEPATH/utf8>>,
                module => <<"http_server_mock/integration_test"/utf8>>,
                function => <<"post_with_body_matching_test"/utf8>>,
                line => 397,
                kind => binary_operator,
                operator => '==',
                left => #{kind => expression,
                    value => _assert_subject,
                    start => 11663,
                    'end' => 11791
                    },
                right => #{kind => literal,
                    value => _assert_subject@1,
                    start => 11799,
                    'end' => 11802
                    },
                start => 11656,
                'end' => 11802,
                expression_start => 11663})
    end,
    _assert_subject@2 = erlang:element(
        2,
        post(
            <<(http_server_mock:base_url(Server))/binary, "/submit"/utf8>>,
            <<"{\"other\":true}"/utf8>>,
            <<"application/json"/utf8>>
        )
    ),
    _assert_subject@3 = 404,
    case _assert_subject@2 =:= _assert_subject@3 of
        true -> nil;
        false -> erlang:error(#{gleam_error => assert,
                message => <<"Assertion failed."/utf8>>,
                file => <<?FILEPATH/utf8>>,
                module => <<"http_server_mock/integration_test"/utf8>>,
                function => <<"post_with_body_matching_test"/utf8>>,
                line => 404,
                kind => binary_operator,
                operator => '==',
                left => #{kind => expression,
                    value => _assert_subject@2,
                    start => 11813,
                    'end' => 11937
                    },
                right => #{kind => literal,
                    value => _assert_subject@3,
                    start => 11945,
                    'end' => 11948
                    },
                start => 11806,
                'end' => 11948,
                expression_start => 11813})
    end,
    http_server_mock:stop(Server).
