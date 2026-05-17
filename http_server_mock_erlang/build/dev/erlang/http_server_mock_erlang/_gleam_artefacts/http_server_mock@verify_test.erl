-module(http_server_mock@verify_test).
-compile([no_auto_import, nowarn_unused_vars, nowarn_unused_function, nowarn_nomatch, inline]).
-define(FILEPATH, "test/http_server_mock/verify_test.gleam").
-export([called_returns_matched_requests_test/0, called_times_returns_matched_when_count_correct_test/0, called_at_least_returns_matched_when_enough_test/0, never_called_passes_when_no_requests_made_test/0]).

-file("test/http_server_mock/verify_test.gleam", 12).
-spec get(binary()) -> nil.
get(Url) ->
    Req@1 = case gleam@http@request:to(Url) of
        {ok, Req} -> Req;
        _assert_fail ->
            erlang:error(#{gleam_error => let_assert,
                        message => <<"Pattern match failed, no pattern matched the value."/utf8>>,
                        file => <<?FILEPATH/utf8>>,
                        module => <<"http_server_mock/verify_test"/utf8>>,
                        function => <<"get"/utf8>>,
                        line => 13,
                        value => _assert_fail,
                        start => 346,
                        'end' => 382,
                        pattern_start => 357,
                        pattern_end => 364})
    end,
    case gleam@httpc:send(Req@1) of
        {ok, _} -> nil;
        _assert_fail@1 ->
            erlang:error(#{gleam_error => let_assert,
                        message => <<"Pattern match failed, no pattern matched the value."/utf8>>,
                        file => <<?FILEPATH/utf8>>,
                        module => <<"http_server_mock/verify_test"/utf8>>,
                        function => <<"get"/utf8>>,
                        line => 14,
                        value => _assert_fail@1,
                        start => 385,
                        'end' => 419,
                        pattern_start => 396,
                        pattern_end => 401})
    end,
    nil.

-file("test/http_server_mock/verify_test.gleam", 18).
-spec called_returns_matched_requests_test() -> http_server_mock@internal@server:mock_server(http_server_mock@internal@server:stopped()).
called_returns_matched_requests_test() ->
    Server = begin
        _pipe = http_server_mock:new(http_server_mock_erlang:server()),
        http_server_mock:start(_pipe)
    end,
    Base = http_server_mock:base_url(Server),
    case http_server_mock:add_stub(
        Server,
        begin
            _pipe@1 = http_server_mock@stub_builder:new(),
            _pipe@3 = http_server_mock@stub_builder:matching(
                _pipe@1,
                begin
                    _pipe@2 = http_server_mock@matcher:new(),
                    http_server_mock@matcher:path(_pipe@2, <<"/hello"/utf8>>)
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
                        module => <<"http_server_mock/verify_test"/utf8>>,
                        function => <<"called_returns_matched_requests_test"/utf8>>,
                        line => 24,
                        value => _assert_fail,
                        start => 633,
                        'end' => 889,
                        pattern_start => 644,
                        pattern_end => 649})
    end,
    case http_server_mock:add_stub(
        Server,
        begin
            _pipe@5 = http_server_mock@stub_builder:new(),
            _pipe@7 = http_server_mock@stub_builder:matching(
                _pipe@5,
                begin
                    _pipe@6 = http_server_mock@matcher:new(),
                    http_server_mock@matcher:path(_pipe@6, <<"/other"/utf8>>)
                end
            ),
            _pipe@8 = http_server_mock@stub_builder:responding_with(
                _pipe@7,
                http_server_mock@response:ok()
            ),
            http_server_mock@stub_builder:build(_pipe@8)
        end
    ) of
        {ok, _} -> nil;
        _assert_fail@1 ->
            erlang:error(#{gleam_error => let_assert,
                        message => <<"Pattern match failed, no pattern matched the value."/utf8>>,
                        file => <<?FILEPATH/utf8>>,
                        module => <<"http_server_mock/verify_test"/utf8>>,
                        function => <<"called_returns_matched_requests_test"/utf8>>,
                        line => 32,
                        value => _assert_fail@1,
                        start => 892,
                        'end' => 1148,
                        pattern_start => 903,
                        pattern_end => 908})
    end,
    get(<<Base/binary, "/hello"/utf8>>),
    get(<<Base/binary, "/other"/utf8>>),
    Result = http_server_mock@verify:called(
        Server,
        begin
            _pipe@9 = http_server_mock@matcher:new(),
            http_server_mock@matcher:path(_pipe@9, <<"/hello"/utf8>>)
        end
    ),
    Req@1 = case Result of
        [Req] -> Req;
        _assert_fail@2 ->
            erlang:error(#{gleam_error => let_assert,
                        message => <<"Pattern match failed, no pattern matched the value."/utf8>>,
                        file => <<?FILEPATH/utf8>>,
                        module => <<"http_server_mock/verify_test"/utf8>>,
                        function => <<"called_returns_matched_requests_test"/utf8>>,
                        line => 45,
                        value => _assert_fail@2,
                        start => 1279,
                        'end' => 1304,
                        pattern_start => 1290,
                        pattern_end => 1295})
    end,
    _assert_subject = erlang:element(4, Req@1),
    _assert_subject@1 = <<"/hello"/utf8>>,
    case _assert_subject =:= _assert_subject@1 of
        true -> nil;
        false -> erlang:error(#{gleam_error => assert,
                message => <<"Assertion failed."/utf8>>,
                file => <<?FILEPATH/utf8>>,
                module => <<"http_server_mock/verify_test"/utf8>>,
                function => <<"called_returns_matched_requests_test"/utf8>>,
                line => 46,
                kind => binary_operator,
                operator => '==',
                left => #{kind => expression,
                    value => _assert_subject,
                    start => 1314,
                    'end' => 1322
                    },
                right => #{kind => literal,
                    value => _assert_subject@1,
                    start => 1326,
                    'end' => 1334
                    },
                start => 1307,
                'end' => 1334,
                expression_start => 1314})
    end,
    http_server_mock:stop(Server).

-file("test/http_server_mock/verify_test.gleam", 51).
-spec called_times_returns_matched_when_count_correct_test() -> http_server_mock@internal@server:mock_server(http_server_mock@internal@server:stopped()).
called_times_returns_matched_when_count_correct_test() ->
    Server = begin
        _pipe = http_server_mock:new(http_server_mock_erlang:server()),
        http_server_mock:start(_pipe)
    end,
    Base = http_server_mock:base_url(Server),
    case http_server_mock:add_stub(
        Server,
        begin
            _pipe@1 = http_server_mock@stub_builder:new(),
            _pipe@3 = http_server_mock@stub_builder:matching(
                _pipe@1,
                begin
                    _pipe@2 = http_server_mock@matcher:new(),
                    http_server_mock@matcher:path(_pipe@2, <<"/api"/utf8>>)
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
                        module => <<"http_server_mock/verify_test"/utf8>>,
                        function => <<"called_times_returns_matched_when_count_correct_test"/utf8>>,
                        line => 57,
                        value => _assert_fail,
                        start => 1591,
                        'end' => 1845,
                        pattern_start => 1602,
                        pattern_end => 1607})
    end,
    get(<<Base/binary, "/api"/utf8>>),
    get(<<Base/binary, "/api"/utf8>>),
    Result = http_server_mock@verify:called_times(
        Server,
        begin
            _pipe@5 = http_server_mock@matcher:new(),
            http_server_mock@matcher:path(_pipe@5, <<"/api"/utf8>>)
        end,
        2
    ),
    _assert_subject = erlang:length(Result),
    _assert_subject@1 = 2,
    case _assert_subject =:= _assert_subject@1 of
        true -> nil;
        false -> erlang:error(#{gleam_error => assert,
                message => <<"Assertion failed."/utf8>>,
                file => <<?FILEPATH/utf8>>,
                module => <<"http_server_mock/verify_test"/utf8>>,
                function => <<"called_times_returns_matched_when_count_correct_test"/utf8>>,
                line => 71,
                kind => binary_operator,
                operator => '==',
                left => #{kind => expression,
                    value => _assert_subject,
                    start => 1990,
                    'end' => 2009
                    },
                right => #{kind => literal,
                    value => _assert_subject@1,
                    start => 2013,
                    'end' => 2014
                    },
                start => 1983,
                'end' => 2014,
                expression_start => 1990})
    end,
    http_server_mock:stop(Server).

-file("test/http_server_mock/verify_test.gleam", 76).
-spec called_at_least_returns_matched_when_enough_test() -> http_server_mock@internal@server:mock_server(http_server_mock@internal@server:stopped()).
called_at_least_returns_matched_when_enough_test() ->
    Server = begin
        _pipe = http_server_mock:new(http_server_mock_erlang:server()),
        http_server_mock:start(_pipe)
    end,
    Base = http_server_mock:base_url(Server),
    case http_server_mock:add_stub(
        Server,
        begin
            _pipe@1 = http_server_mock@stub_builder:new(),
            _pipe@3 = http_server_mock@stub_builder:matching(
                _pipe@1,
                begin
                    _pipe@2 = http_server_mock@matcher:new(),
                    http_server_mock@matcher:path(_pipe@2, <<"/x"/utf8>>)
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
                        module => <<"http_server_mock/verify_test"/utf8>>,
                        function => <<"called_at_least_returns_matched_when_enough_test"/utf8>>,
                        line => 82,
                        value => _assert_fail,
                        start => 2267,
                        'end' => 2519,
                        pattern_start => 2278,
                        pattern_end => 2283})
    end,
    get(<<Base/binary, "/x"/utf8>>),
    get(<<Base/binary, "/x"/utf8>>),
    get(<<Base/binary, "/x"/utf8>>),
    Result = http_server_mock@verify:called_at_least(
        Server,
        begin
            _pipe@5 = http_server_mock@matcher:new(),
            http_server_mock@matcher:path(_pipe@5, <<"/x"/utf8>>)
        end,
        2
    ),
    _assert_subject = erlang:length(Result),
    _assert_subject@1 = 3,
    case _assert_subject =:= _assert_subject@1 of
        true -> nil;
        false -> erlang:error(#{gleam_error => assert,
                message => <<"Assertion failed."/utf8>>,
                file => <<?FILEPATH/utf8>>,
                module => <<"http_server_mock/verify_test"/utf8>>,
                function => <<"called_at_least_returns_matched_when_enough_test"/utf8>>,
                line => 97,
                kind => binary_operator,
                operator => '==',
                left => #{kind => expression,
                    value => _assert_subject,
                    start => 2681,
                    'end' => 2700
                    },
                right => #{kind => literal,
                    value => _assert_subject@1,
                    start => 2704,
                    'end' => 2705
                    },
                start => 2674,
                'end' => 2705,
                expression_start => 2681})
    end,
    http_server_mock:stop(Server).

-file("test/http_server_mock/verify_test.gleam", 102).
-spec never_called_passes_when_no_requests_made_test() -> http_server_mock@internal@server:mock_server(http_server_mock@internal@server:stopped()).
never_called_passes_when_no_requests_made_test() ->
    Server = begin
        _pipe = http_server_mock:new(http_server_mock_erlang:server()),
        http_server_mock:start(_pipe)
    end,
    http_server_mock@verify:never_called(
        Server,
        begin
            _pipe@1 = http_server_mock@matcher:new(),
            http_server_mock@matcher:path(_pipe@1, <<"/never"/utf8>>)
        end
    ),
    http_server_mock:stop(Server).
