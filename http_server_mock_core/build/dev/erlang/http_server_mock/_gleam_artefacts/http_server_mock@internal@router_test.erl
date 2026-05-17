-module(http_server_mock@internal@router_test).
-compile([no_auto_import, nowarn_unused_vars, nowarn_unused_function, nowarn_nomatch, inline]).
-define(FILEPATH, "test/http_server_mock/internal/router_test.gleam").
-export([find_match_returns_none_when_no_stubs_test/0, find_match_returns_stub_when_matches_test/0, find_match_returns_none_when_path_differs_test/0, find_match_picks_higher_score_over_lower_test/0, find_match_priority_overrides_score_test/0, score_returns_none_when_no_match_test/0, score_returns_some_when_matches_test/0, score_exact_path_higher_than_wildcard_test/0, scenario_blocks_unmatched_state_test/0, scenario_matches_correct_state_test/0, scenario_initial_state_requires_no_entry_test/0, scenario_initial_state_fails_if_scenario_active_test/0]).

-if(?OTP_RELEASE >= 27).
-define(MODULEDOC(Str), -moduledoc(Str)).
-define(DOC(Str), -doc(Str)).
-else.
-define(MODULEDOC(Str), -compile([])).
-define(DOC(Str), -compile([])).
-endif.

?MODULEDOC(false).

-file("test/http_server_mock/internal/router_test.gleam", 10).
?DOC(false).
-spec make_get_request(binary()) -> http_server_mock@types:recorded_request().
make_get_request(Path) ->
    {recorded_request,
        <<"test"/utf8>>,
        get,
        Path,
        none,
        maps:new(),
        <<""/utf8>>,
        0,
        none}.

-file("test/http_server_mock/internal/router_test.gleam", 23).
?DOC(false).
-spec make_stub(http_server_mock@types:request_matcher()) -> http_server_mock@stub_builder:stub_builder(http_server_mock@stub_builder:with_matcher(), http_server_mock@stub_builder:with_response()).
make_stub(Request_matcher) ->
    _pipe = http_server_mock@stub_builder:new(),
    _pipe@1 = http_server_mock@stub_builder:matching(_pipe, Request_matcher),
    http_server_mock@stub_builder:responding_with(
        _pipe@1,
        http_server_mock@response:ok()
    ).

-file("test/http_server_mock/internal/router_test.gleam", 34).
?DOC(false).
-spec find_match_returns_none_when_no_stubs_test() -> gleam@option:option({http_server_mock@types:stub(),
    http_server_mock@types:response_definition()}).
find_match_returns_none_when_no_stubs_test() ->
    _assert_subject = http_server_mock@internal@router:find_match(
        [],
        maps:new(),
        make_get_request(<<"/path"/utf8>>)
    ),
    case _assert_subject of
        none -> _assert_subject;
        _assert_fail ->
            erlang:error(#{gleam_error => let_assert,
                        message => <<"Pattern match failed, no pattern matched the value."/utf8>>,
                        file => <<?FILEPATH/utf8>>,
                        module => <<"http_server_mock/internal/router_test"/utf8>>,
                        function => <<"find_match_returns_none_when_no_stubs_test"/utf8>>,
                        line => 35,
                        value => _assert_fail,
                        start => 841,
                        'end' => 919,
                        pattern_start => 852,
                        pattern_end => 856})
    end.

-file("test/http_server_mock/internal/router_test.gleam", 38).
?DOC(false).
-spec find_match_returns_stub_when_matches_test() -> gleam@option:option({http_server_mock@types:stub(),
    http_server_mock@types:response_definition()}).
find_match_returns_stub_when_matches_test() ->
    The_stub = begin
        _pipe@1 = make_stub(
            begin
                _pipe = http_server_mock@matcher:new(),
                http_server_mock@matcher:path(_pipe, <<"/hello"/utf8>>)
            end
        ),
        http_server_mock@stub_builder:build(_pipe@1)
    end,
    _assert_subject = http_server_mock@internal@router:find_match(
        [The_stub],
        maps:new(),
        make_get_request(<<"/hello"/utf8>>)
    ),
    case _assert_subject of
        {some, _} -> _assert_subject;
        _assert_fail ->
            erlang:error(#{gleam_error => let_assert,
                        message => <<"Pattern match failed, no pattern matched the value."/utf8>>,
                        file => <<?FILEPATH/utf8>>,
                        module => <<"http_server_mock/internal/router_test"/utf8>>,
                        function => <<"find_match_returns_stub_when_matches_test"/utf8>>,
                        line => 41,
                        value => _assert_fail,
                        start => 1074,
                        'end' => 1168,
                        pattern_start => 1085,
                        pattern_end => 1092})
    end.

-file("test/http_server_mock/internal/router_test.gleam", 45).
?DOC(false).
-spec find_match_returns_none_when_path_differs_test() -> gleam@option:option({http_server_mock@types:stub(),
    http_server_mock@types:response_definition()}).
find_match_returns_none_when_path_differs_test() ->
    The_stub = begin
        _pipe@1 = make_stub(
            begin
                _pipe = http_server_mock@matcher:new(),
                http_server_mock@matcher:path(_pipe, <<"/hello"/utf8>>)
            end
        ),
        http_server_mock@stub_builder:build(_pipe@1)
    end,
    _assert_subject = http_server_mock@internal@router:find_match(
        [The_stub],
        maps:new(),
        make_get_request(<<"/world"/utf8>>)
    ),
    case _assert_subject of
        none -> _assert_subject;
        _assert_fail ->
            erlang:error(#{gleam_error => let_assert,
                        message => <<"Pattern match failed, no pattern matched the value."/utf8>>,
                        file => <<?FILEPATH/utf8>>,
                        module => <<"http_server_mock/internal/router_test"/utf8>>,
                        function => <<"find_match_returns_none_when_path_differs_test"/utf8>>,
                        line => 48,
                        value => _assert_fail,
                        start => 1328,
                        'end' => 1419,
                        pattern_start => 1339,
                        pattern_end => 1343})
    end.

-file("test/http_server_mock/internal/router_test.gleam", 52).
?DOC(false).
-spec find_match_picks_higher_score_over_lower_test() -> binary().
find_match_picks_higher_score_over_lower_test() ->
    Exact_stub = begin
        _pipe@1 = make_stub(
            begin
                _pipe = http_server_mock@matcher:new(),
                http_server_mock@matcher:path(_pipe, <<"/api/users"/utf8>>)
            end
        ),
        _pipe@2 = http_server_mock@stub_builder:with_id(
            _pipe@1,
            <<"exact"/utf8>>
        ),
        http_server_mock@stub_builder:build(_pipe@2)
    end,
    Contains_stub = begin
        _pipe@4 = make_stub(
            begin
                _pipe@3 = http_server_mock@matcher:new(),
                http_server_mock@matcher:path_contains(
                    _pipe@3,
                    <<"users"/utf8>>
                )
            end
        ),
        _pipe@5 = http_server_mock@stub_builder:with_id(
            _pipe@4,
            <<"contains"/utf8>>
        ),
        http_server_mock@stub_builder:build(_pipe@5)
    end,
    Matched_stub@1 = case http_server_mock@internal@router:find_match(
        [Contains_stub, Exact_stub],
        maps:new(),
        make_get_request(<<"/api/users"/utf8>>)
    ) of
        {some, {Matched_stub, _}} -> Matched_stub;
        _assert_fail ->
            erlang:error(#{gleam_error => let_assert,
                        message => <<"Pattern match failed, no pattern matched the value."/utf8>>,
                        file => <<?FILEPATH/utf8>>,
                        module => <<"http_server_mock/internal/router_test"/utf8>>,
                        function => <<"find_match_picks_higher_score_over_lower_test"/utf8>>,
                        line => 62,
                        value => _assert_fail,
                        start => 1779,
                        'end' => 1936,
                        pattern_start => 1790,
                        pattern_end => 1814})
    end,
    _assert_subject = erlang:element(2, Matched_stub@1),
    case _assert_subject of
        <<"exact"/utf8>> -> _assert_subject;
        _assert_fail@1 ->
            erlang:error(#{gleam_error => let_assert,
                        message => <<"Pattern match failed, no pattern matched the value."/utf8>>,
                        file => <<?FILEPATH/utf8>>,
                        module => <<"http_server_mock/internal/router_test"/utf8>>,
                        function => <<"find_match_picks_higher_score_over_lower_test"/utf8>>,
                        line => 68,
                        value => _assert_fail@1,
                        start => 1939,
                        'end' => 1975,
                        pattern_start => 1950,
                        pattern_end => 1957})
    end.

-file("test/http_server_mock/internal/router_test.gleam", 71).
?DOC(false).
-spec find_match_priority_overrides_score_test() -> binary().
find_match_priority_overrides_score_test() ->
    High_priority_stub = begin
        _pipe@1 = make_stub(
            begin
                _pipe = http_server_mock@matcher:new(),
                http_server_mock@matcher:path_contains(_pipe, <<"users"/utf8>>)
            end
        ),
        _pipe@2 = http_server_mock@stub_builder:with_id(
            _pipe@1,
            <<"high"/utf8>>
        ),
        _pipe@3 = http_server_mock@stub_builder:with_priority(_pipe@2, 1),
        http_server_mock@stub_builder:build(_pipe@3)
    end,
    Low_priority_stub = begin
        _pipe@5 = make_stub(
            begin
                _pipe@4 = http_server_mock@matcher:new(),
                http_server_mock@matcher:path(_pipe@4, <<"/api/users"/utf8>>)
            end
        ),
        _pipe@6 = http_server_mock@stub_builder:with_id(_pipe@5, <<"low"/utf8>>),
        _pipe@7 = http_server_mock@stub_builder:with_priority(_pipe@6, 5),
        http_server_mock@stub_builder:build(_pipe@7)
    end,
    Matched_stub@1 = case http_server_mock@internal@router:find_match(
        [Low_priority_stub, High_priority_stub],
        maps:new(),
        make_get_request(<<"/api/users"/utf8>>)
    ) of
        {some, {Matched_stub, _}} -> Matched_stub;
        _assert_fail ->
            erlang:error(#{gleam_error => let_assert,
                        message => <<"Pattern match failed, no pattern matched the value."/utf8>>,
                        file => <<?FILEPATH/utf8>>,
                        module => <<"http_server_mock/internal/router_test"/utf8>>,
                        function => <<"find_match_priority_overrides_score_test"/utf8>>,
                        line => 83,
                        value => _assert_fail,
                        start => 2410,
                        'end' => 2579,
                        pattern_start => 2421,
                        pattern_end => 2445})
    end,
    _assert_subject = erlang:element(2, Matched_stub@1),
    case _assert_subject of
        <<"high"/utf8>> -> _assert_subject;
        _assert_fail@1 ->
            erlang:error(#{gleam_error => let_assert,
                        message => <<"Pattern match failed, no pattern matched the value."/utf8>>,
                        file => <<?FILEPATH/utf8>>,
                        module => <<"http_server_mock/internal/router_test"/utf8>>,
                        function => <<"find_match_priority_overrides_score_test"/utf8>>,
                        line => 89,
                        value => _assert_fail@1,
                        start => 2582,
                        'end' => 2617,
                        pattern_start => 2593,
                        pattern_end => 2599})
    end.

-file("test/http_server_mock/internal/router_test.gleam", 92).
?DOC(false).
-spec score_returns_none_when_no_match_test() -> gleam@option:option(integer()).
score_returns_none_when_no_match_test() ->
    The_stub = begin
        _pipe@1 = make_stub(
            begin
                _pipe = http_server_mock@matcher:new(),
                http_server_mock@matcher:path(_pipe, <<"/specific"/utf8>>)
            end
        ),
        http_server_mock@stub_builder:build(_pipe@1)
    end,
    _assert_subject = http_server_mock@internal@router:score(
        The_stub,
        maps:new(),
        make_get_request(<<"/other"/utf8>>)
    ),
    case _assert_subject of
        none -> _assert_subject;
        _assert_fail ->
            erlang:error(#{gleam_error => let_assert,
                        message => <<"Pattern match failed, no pattern matched the value."/utf8>>,
                        file => <<?FILEPATH/utf8>>,
                        module => <<"http_server_mock/internal/router_test"/utf8>>,
                        function => <<"score_returns_none_when_no_match_test"/utf8>>,
                        line => 96,
                        value => _assert_fail,
                        start => 2775,
                        'end' => 2859,
                        pattern_start => 2786,
                        pattern_end => 2790})
    end.

-file("test/http_server_mock/internal/router_test.gleam", 100).
?DOC(false).
-spec score_returns_some_when_matches_test() -> gleam@option:option(integer()).
score_returns_some_when_matches_test() ->
    The_stub = begin
        _pipe@1 = make_stub(
            begin
                _pipe = http_server_mock@matcher:new(),
                http_server_mock@matcher:path(_pipe, <<"/specific"/utf8>>)
            end
        ),
        http_server_mock@stub_builder:build(_pipe@1)
    end,
    _assert_subject = http_server_mock@internal@router:score(
        The_stub,
        maps:new(),
        make_get_request(<<"/specific"/utf8>>)
    ),
    case _assert_subject of
        {some, _} -> _assert_subject;
        _assert_fail ->
            erlang:error(#{gleam_error => let_assert,
                        message => <<"Pattern match failed, no pattern matched the value."/utf8>>,
                        file => <<?FILEPATH/utf8>>,
                        module => <<"http_server_mock/internal/router_test"/utf8>>,
                        function => <<"score_returns_some_when_matches_test"/utf8>>,
                        line => 104,
                        value => _assert_fail,
                        start => 3016,
                        'end' => 3106,
                        pattern_start => 3027,
                        pattern_end => 3034})
    end.

-file("test/http_server_mock/internal/router_test.gleam", 108).
?DOC(false).
-spec score_exact_path_higher_than_wildcard_test() -> boolean().
score_exact_path_higher_than_wildcard_test() ->
    Exact_stub = begin
        _pipe@1 = make_stub(
            begin
                _pipe = http_server_mock@matcher:new(),
                http_server_mock@matcher:path(_pipe, <<"/users"/utf8>>)
            end
        ),
        http_server_mock@stub_builder:build(_pipe@1)
    end,
    Any_stub = begin
        _pipe@2 = make_stub(http_server_mock@matcher:new()),
        http_server_mock@stub_builder:build(_pipe@2)
    end,
    Exact_value@1 = case http_server_mock@internal@router:score(
        Exact_stub,
        maps:new(),
        make_get_request(<<"/users"/utf8>>)
    ) of
        {some, Exact_value} -> Exact_value;
        _assert_fail ->
            erlang:error(#{gleam_error => let_assert,
                        message => <<"Pattern match failed, no pattern matched the value."/utf8>>,
                        file => <<?FILEPATH/utf8>>,
                        module => <<"http_server_mock/internal/router_test"/utf8>>,
                        function => <<"score_exact_path_higher_than_wildcard_test"/utf8>>,
                        line => 113,
                        value => _assert_fail,
                        start => 3331,
                        'end' => 3430,
                        pattern_start => 3342,
                        pattern_end => 3359})
    end,
    Any_value@1 = case http_server_mock@internal@router:score(
        Any_stub,
        maps:new(),
        make_get_request(<<"/users"/utf8>>)
    ) of
        {some, Any_value} -> Any_value;
        _assert_fail@1 ->
            erlang:error(#{gleam_error => let_assert,
                        message => <<"Pattern match failed, no pattern matched the value."/utf8>>,
                        file => <<?FILEPATH/utf8>>,
                        module => <<"http_server_mock/internal/router_test"/utf8>>,
                        function => <<"score_exact_path_higher_than_wildcard_test"/utf8>>,
                        line => 115,
                        value => _assert_fail@1,
                        start => 3433,
                        'end' => 3528,
                        pattern_start => 3444,
                        pattern_end => 3459})
    end,
    _assert_subject = Exact_value@1 > Any_value@1,
    case _assert_subject of
        true -> _assert_subject;
        _assert_fail@2 ->
            erlang:error(#{gleam_error => let_assert,
                        message => <<"Pattern match failed, no pattern matched the value."/utf8>>,
                        file => <<?FILEPATH/utf8>>,
                        module => <<"http_server_mock/internal/router_test"/utf8>>,
                        function => <<"score_exact_path_higher_than_wildcard_test"/utf8>>,
                        line => 117,
                        value => _assert_fail@2,
                        start => 3531,
                        'end' => 3572,
                        pattern_start => 3542,
                        pattern_end => 3546})
    end.

-file("test/http_server_mock/internal/router_test.gleam", 120).
?DOC(false).
-spec scenario_blocks_unmatched_state_test() -> gleam@option:option({http_server_mock@types:stub(),
    http_server_mock@types:response_definition()}).
scenario_blocks_unmatched_state_test() ->
    The_stub = begin
        _pipe@1 = make_stub(
            begin
                _pipe = http_server_mock@matcher:new(),
                http_server_mock@matcher:path(_pipe, <<"/order"/utf8>>)
            end
        ),
        _pipe@2 = http_server_mock@stub_builder:in_scenario(
            _pipe@1,
            <<"checkout"/utf8>>
        ),
        _pipe@3 = http_server_mock@stub_builder:when_state_is(
            _pipe@2,
            <<"confirmed"/utf8>>
        ),
        http_server_mock@stub_builder:build(_pipe@3)
    end,
    Scenarios = maps:from_list([{<<"checkout"/utf8>>, <<"pending"/utf8>>}]),
    _assert_subject = http_server_mock@internal@router:find_match(
        [The_stub],
        Scenarios,
        make_get_request(<<"/order"/utf8>>)
    ),
    case _assert_subject of
        none -> _assert_subject;
        _assert_fail ->
            erlang:error(#{gleam_error => let_assert,
                        message => <<"Pattern match failed, no pattern matched the value."/utf8>>,
                        file => <<?FILEPATH/utf8>>,
                        module => <<"http_server_mock/internal/router_test"/utf8>>,
                        function => <<"scenario_blocks_unmatched_state_test"/utf8>>,
                        line => 128,
                        value => _assert_fail,
                        start => 3879,
                        'end' => 3969,
                        pattern_start => 3890,
                        pattern_end => 3894})
    end.

-file("test/http_server_mock/internal/router_test.gleam", 132).
?DOC(false).
-spec scenario_matches_correct_state_test() -> gleam@option:option({http_server_mock@types:stub(),
    http_server_mock@types:response_definition()}).
scenario_matches_correct_state_test() ->
    The_stub = begin
        _pipe@1 = make_stub(
            begin
                _pipe = http_server_mock@matcher:new(),
                http_server_mock@matcher:path(_pipe, <<"/order"/utf8>>)
            end
        ),
        _pipe@2 = http_server_mock@stub_builder:in_scenario(
            _pipe@1,
            <<"checkout"/utf8>>
        ),
        _pipe@3 = http_server_mock@stub_builder:when_state_is(
            _pipe@2,
            <<"confirmed"/utf8>>
        ),
        http_server_mock@stub_builder:build(_pipe@3)
    end,
    Scenarios = maps:from_list([{<<"checkout"/utf8>>, <<"confirmed"/utf8>>}]),
    _assert_subject = http_server_mock@internal@router:find_match(
        [The_stub],
        Scenarios,
        make_get_request(<<"/order"/utf8>>)
    ),
    case _assert_subject of
        {some, _} -> _assert_subject;
        _assert_fail ->
            erlang:error(#{gleam_error => let_assert,
                        message => <<"Pattern match failed, no pattern matched the value."/utf8>>,
                        file => <<?FILEPATH/utf8>>,
                        module => <<"http_server_mock/internal/router_test"/utf8>>,
                        function => <<"scenario_matches_correct_state_test"/utf8>>,
                        line => 140,
                        value => _assert_fail,
                        start => 4277,
                        'end' => 4370,
                        pattern_start => 4288,
                        pattern_end => 4295})
    end.

-file("test/http_server_mock/internal/router_test.gleam", 144).
?DOC(false).
-spec scenario_initial_state_requires_no_entry_test() -> gleam@option:option({http_server_mock@types:stub(),
    http_server_mock@types:response_definition()}).
scenario_initial_state_requires_no_entry_test() ->
    The_stub = begin
        _pipe@1 = make_stub(
            begin
                _pipe = http_server_mock@matcher:new(),
                http_server_mock@matcher:path(_pipe, <<"/start"/utf8>>)
            end
        ),
        _pipe@2 = http_server_mock@stub_builder:in_scenario(
            _pipe@1,
            <<"flow"/utf8>>
        ),
        http_server_mock@stub_builder:build(_pipe@2)
    end,
    _assert_subject = http_server_mock@internal@router:find_match(
        [The_stub],
        maps:new(),
        make_get_request(<<"/start"/utf8>>)
    ),
    case _assert_subject of
        {some, _} -> _assert_subject;
        _assert_fail ->
            erlang:error(#{gleam_error => let_assert,
                        message => <<"Pattern match failed, no pattern matched the value."/utf8>>,
                        file => <<?FILEPATH/utf8>>,
                        module => <<"http_server_mock/internal/router_test"/utf8>>,
                        function => <<"scenario_initial_state_requires_no_entry_test"/utf8>>,
                        line => 150,
                        value => _assert_fail,
                        start => 4574,
                        'end' => 4668,
                        pattern_start => 4585,
                        pattern_end => 4592})
    end.

-file("test/http_server_mock/internal/router_test.gleam", 154).
?DOC(false).
-spec scenario_initial_state_fails_if_scenario_active_test() -> gleam@option:option({http_server_mock@types:stub(),
    http_server_mock@types:response_definition()}).
scenario_initial_state_fails_if_scenario_active_test() ->
    The_stub = begin
        _pipe@1 = make_stub(
            begin
                _pipe = http_server_mock@matcher:new(),
                http_server_mock@matcher:path(_pipe, <<"/start"/utf8>>)
            end
        ),
        _pipe@2 = http_server_mock@stub_builder:in_scenario(
            _pipe@1,
            <<"flow"/utf8>>
        ),
        http_server_mock@stub_builder:build(_pipe@2)
    end,
    Scenarios = maps:from_list([{<<"flow"/utf8>>, <<"step2"/utf8>>}]),
    _assert_subject = http_server_mock@internal@router:find_match(
        [The_stub],
        Scenarios,
        make_get_request(<<"/start"/utf8>>)
    ),
    case _assert_subject of
        none -> _assert_subject;
        _assert_fail ->
            erlang:error(#{gleam_error => let_assert,
                        message => <<"Pattern match failed, no pattern matched the value."/utf8>>,
                        file => <<?FILEPATH/utf8>>,
                        module => <<"http_server_mock/internal/router_test"/utf8>>,
                        function => <<"scenario_initial_state_fails_if_scenario_active_test"/utf8>>,
                        line => 161,
                        value => _assert_fail,
                        start => 4934,
                        'end' => 5024,
                        pattern_start => 4945,
                        pattern_end => 4949})
    end.
