-module(http_server_mock@matcher_test).
-compile([no_auto_import, nowarn_unused_vars, nowarn_unused_function, nowarn_nomatch, inline]).
-define(FILEPATH, "test/http_server_mock/matcher_test.gleam").
-export([new_matcher_matches_anything_test/0, method_matcher_matches_correct_method_test/0, method_matcher_rejects_wrong_method_test/0, exact_path_matches_test/0, exact_path_rejects_different_test/0, path_contains_matches_test/0, path_contains_rejects_missing_fragment_test/0, path_matching_prefix_test/0, path_matching_suffix_test/0, path_matching_any_string_test/0, query_param_matches_test/0, query_param_rejects_wrong_value_test/0, query_param_rejects_missing_key_test/0, header_matches_test/0, header_case_insensitive_key_test/0, body_exact_matches_test/0, body_exact_rejects_different_test/0, body_containing_matches_test/0, body_json_matches_ignoring_whitespace_test/0, combined_matcher_all_must_match_test/0, combined_matcher_partial_miss_fails_test/0, apply_string_matcher_exact_test/0, apply_string_matcher_contains_test/0, apply_string_matcher_prefix_test/0, apply_string_matcher_suffix_test/0, apply_string_matcher_any_test/0]).

-file("test/http_server_mock/matcher_test.gleam", 10).
-spec make_request(gleam@http:method(), binary()) -> http_server_mock@types:recorded_request().
make_request(Method, Path) ->
    {recorded_request,
        <<"test"/utf8>>,
        Method,
        Path,
        none,
        maps:new(),
        <<""/utf8>>,
        0,
        none}.

-file("test/http_server_mock/matcher_test.gleam", 23).
-spec make_request_with_query(gleam@http:method(), binary(), binary()) -> http_server_mock@types:recorded_request().
make_request_with_query(Method, Path, Query_string) ->
    {recorded_request,
        <<"test"/utf8>>,
        Method,
        Path,
        {some, Query_string},
        maps:new(),
        <<""/utf8>>,
        0,
        none}.

-file("test/http_server_mock/matcher_test.gleam", 40).
-spec make_request_with_body(binary()) -> http_server_mock@types:recorded_request().
make_request_with_body(Body) ->
    {recorded_request,
        <<"test"/utf8>>,
        post,
        <<"/"/utf8>>,
        none,
        maps:new(),
        Body,
        0,
        none}.

-file("test/http_server_mock/matcher_test.gleam", 53).
-spec new_matcher_matches_anything_test() -> boolean().
new_matcher_matches_anything_test() ->
    _assert_subject = begin
        _pipe = http_server_mock@matcher:new(),
        http_server_mock@matcher:matches(
            _pipe,
            make_request(get, <<"/anything"/utf8>>)
        )
    end,
    case _assert_subject of
        true -> _assert_subject;
        _assert_fail ->
            erlang:error(#{gleam_error => let_assert,
                        message => <<"Pattern match failed, no pattern matched the value."/utf8>>,
                        file => <<?FILEPATH/utf8>>,
                        module => <<"http_server_mock/matcher_test"/utf8>>,
                        function => <<"new_matcher_matches_anything_test"/utf8>>,
                        line => 54,
                        value => _assert_fail,
                        start => 1081,
                        'end' => 1176,
                        pattern_start => 1092,
                        pattern_end => 1096})
    end.

-file("test/http_server_mock/matcher_test.gleam", 59).
-spec method_matcher_matches_correct_method_test() -> boolean().
method_matcher_matches_correct_method_test() ->
    _assert_subject = begin
        _pipe = http_server_mock@matcher:new(),
        _pipe@1 = http_server_mock@matcher:method(_pipe, get),
        http_server_mock@matcher:matches(
            _pipe@1,
            make_request(get, <<"/path"/utf8>>)
        )
    end,
    case _assert_subject of
        true -> _assert_subject;
        _assert_fail ->
            erlang:error(#{gleam_error => let_assert,
                        message => <<"Pattern match failed, no pattern matched the value."/utf8>>,
                        file => <<?FILEPATH/utf8>>,
                        module => <<"http_server_mock/matcher_test"/utf8>>,
                        function => <<"method_matcher_matches_correct_method_test"/utf8>>,
                        line => 60,
                        value => _assert_fail,
                        start => 1236,
                        'end' => 1359,
                        pattern_start => 1247,
                        pattern_end => 1251})
    end.

-file("test/http_server_mock/matcher_test.gleam", 66).
-spec method_matcher_rejects_wrong_method_test() -> boolean().
method_matcher_rejects_wrong_method_test() ->
    _assert_subject = begin
        _pipe = http_server_mock@matcher:new(),
        _pipe@1 = http_server_mock@matcher:method(_pipe, post),
        http_server_mock@matcher:matches(
            _pipe@1,
            make_request(get, <<"/path"/utf8>>)
        )
    end,
    case _assert_subject of
        false -> _assert_subject;
        _assert_fail ->
            erlang:error(#{gleam_error => let_assert,
                        message => <<"Pattern match failed, no pattern matched the value."/utf8>>,
                        file => <<?FILEPATH/utf8>>,
                        module => <<"http_server_mock/matcher_test"/utf8>>,
                        function => <<"method_matcher_rejects_wrong_method_test"/utf8>>,
                        line => 67,
                        value => _assert_fail,
                        start => 1417,
                        'end' => 1542,
                        pattern_start => 1428,
                        pattern_end => 1433})
    end.

-file("test/http_server_mock/matcher_test.gleam", 73).
-spec exact_path_matches_test() -> boolean().
exact_path_matches_test() ->
    _assert_subject = begin
        _pipe = http_server_mock@matcher:new(),
        _pipe@1 = http_server_mock@matcher:path(_pipe, <<"/api/users"/utf8>>),
        http_server_mock@matcher:matches(
            _pipe@1,
            make_request(get, <<"/api/users"/utf8>>)
        )
    end,
    case _assert_subject of
        true -> _assert_subject;
        _assert_fail ->
            erlang:error(#{gleam_error => let_assert,
                        message => <<"Pattern match failed, no pattern matched the value."/utf8>>,
                        file => <<?FILEPATH/utf8>>,
                        module => <<"http_server_mock/matcher_test"/utf8>>,
                        function => <<"exact_path_matches_test"/utf8>>,
                        line => 74,
                        value => _assert_fail,
                        start => 1583,
                        'end' => 1713,
                        pattern_start => 1594,
                        pattern_end => 1598})
    end.

-file("test/http_server_mock/matcher_test.gleam", 80).
-spec exact_path_rejects_different_test() -> boolean().
exact_path_rejects_different_test() ->
    _assert_subject = begin
        _pipe = http_server_mock@matcher:new(),
        _pipe@1 = http_server_mock@matcher:path(_pipe, <<"/api/users"/utf8>>),
        http_server_mock@matcher:matches(
            _pipe@1,
            make_request(get, <<"/api/other"/utf8>>)
        )
    end,
    case _assert_subject of
        false -> _assert_subject;
        _assert_fail ->
            erlang:error(#{gleam_error => let_assert,
                        message => <<"Pattern match failed, no pattern matched the value."/utf8>>,
                        file => <<?FILEPATH/utf8>>,
                        module => <<"http_server_mock/matcher_test"/utf8>>,
                        function => <<"exact_path_rejects_different_test"/utf8>>,
                        line => 81,
                        value => _assert_fail,
                        start => 1764,
                        'end' => 1895,
                        pattern_start => 1775,
                        pattern_end => 1780})
    end.

-file("test/http_server_mock/matcher_test.gleam", 87).
-spec path_contains_matches_test() -> boolean().
path_contains_matches_test() ->
    _assert_subject = begin
        _pipe = http_server_mock@matcher:new(),
        _pipe@1 = http_server_mock@matcher:path_contains(
            _pipe,
            <<"users"/utf8>>
        ),
        http_server_mock@matcher:matches(
            _pipe@1,
            make_request(get, <<"/api/users/123"/utf8>>)
        )
    end,
    case _assert_subject of
        true -> _assert_subject;
        _assert_fail ->
            erlang:error(#{gleam_error => let_assert,
                        message => <<"Pattern match failed, no pattern matched the value."/utf8>>,
                        file => <<?FILEPATH/utf8>>,
                        module => <<"http_server_mock/matcher_test"/utf8>>,
                        function => <<"path_contains_matches_test"/utf8>>,
                        line => 88,
                        value => _assert_fail,
                        start => 1939,
                        'end' => 2077,
                        pattern_start => 1950,
                        pattern_end => 1954})
    end.

-file("test/http_server_mock/matcher_test.gleam", 94).
-spec path_contains_rejects_missing_fragment_test() -> boolean().
path_contains_rejects_missing_fragment_test() ->
    _assert_subject = begin
        _pipe = http_server_mock@matcher:new(),
        _pipe@1 = http_server_mock@matcher:path_contains(
            _pipe,
            <<"orders"/utf8>>
        ),
        http_server_mock@matcher:matches(
            _pipe@1,
            make_request(get, <<"/api/users/123"/utf8>>)
        )
    end,
    case _assert_subject of
        false -> _assert_subject;
        _assert_fail ->
            erlang:error(#{gleam_error => let_assert,
                        message => <<"Pattern match failed, no pattern matched the value."/utf8>>,
                        file => <<?FILEPATH/utf8>>,
                        module => <<"http_server_mock/matcher_test"/utf8>>,
                        function => <<"path_contains_rejects_missing_fragment_test"/utf8>>,
                        line => 95,
                        value => _assert_fail,
                        start => 2138,
                        'end' => 2278,
                        pattern_start => 2149,
                        pattern_end => 2154})
    end.

-file("test/http_server_mock/matcher_test.gleam", 101).
-spec path_matching_prefix_test() -> boolean().
path_matching_prefix_test() ->
    _assert_subject = begin
        _pipe = http_server_mock@matcher:new(),
        _pipe@1 = http_server_mock@matcher:path_matching(
            _pipe,
            {prefix, <<"/api"/utf8>>}
        ),
        http_server_mock@matcher:matches(
            _pipe@1,
            make_request(get, <<"/api/users"/utf8>>)
        )
    end,
    case _assert_subject of
        true -> _assert_subject;
        _assert_fail ->
            erlang:error(#{gleam_error => let_assert,
                        message => <<"Pattern match failed, no pattern matched the value."/utf8>>,
                        file => <<?FILEPATH/utf8>>,
                        module => <<"http_server_mock/matcher_test"/utf8>>,
                        function => <<"path_matching_prefix_test"/utf8>>,
                        line => 102,
                        value => _assert_fail,
                        start => 2321,
                        'end' => 2462,
                        pattern_start => 2332,
                        pattern_end => 2336})
    end.

-file("test/http_server_mock/matcher_test.gleam", 108).
-spec path_matching_suffix_test() -> boolean().
path_matching_suffix_test() ->
    _assert_subject = begin
        _pipe = http_server_mock@matcher:new(),
        _pipe@1 = http_server_mock@matcher:path_matching(
            _pipe,
            {suffix, <<".json"/utf8>>}
        ),
        http_server_mock@matcher:matches(
            _pipe@1,
            make_request(get, <<"/data.json"/utf8>>)
        )
    end,
    case _assert_subject of
        true -> _assert_subject;
        _assert_fail ->
            erlang:error(#{gleam_error => let_assert,
                        message => <<"Pattern match failed, no pattern matched the value."/utf8>>,
                        file => <<?FILEPATH/utf8>>,
                        module => <<"http_server_mock/matcher_test"/utf8>>,
                        function => <<"path_matching_suffix_test"/utf8>>,
                        line => 109,
                        value => _assert_fail,
                        start => 2505,
                        'end' => 2647,
                        pattern_start => 2516,
                        pattern_end => 2520})
    end.

-file("test/http_server_mock/matcher_test.gleam", 115).
-spec path_matching_any_string_test() -> boolean().
path_matching_any_string_test() ->
    _assert_subject = begin
        _pipe = http_server_mock@matcher:new(),
        _pipe@1 = http_server_mock@matcher:path_matching(_pipe, any_string),
        http_server_mock@matcher:matches(
            _pipe@1,
            make_request(get, <<"/literally/anything"/utf8>>)
        )
    end,
    case _assert_subject of
        true -> _assert_subject;
        _assert_fail ->
            erlang:error(#{gleam_error => let_assert,
                        message => <<"Pattern match failed, no pattern matched the value."/utf8>>,
                        file => <<?FILEPATH/utf8>>,
                        module => <<"http_server_mock/matcher_test"/utf8>>,
                        function => <<"path_matching_any_string_test"/utf8>>,
                        line => 116,
                        value => _assert_fail,
                        start => 2694,
                        'end' => 2839,
                        pattern_start => 2705,
                        pattern_end => 2709})
    end.

-file("test/http_server_mock/matcher_test.gleam", 122).
-spec query_param_matches_test() -> boolean().
query_param_matches_test() ->
    _assert_subject = begin
        _pipe = http_server_mock@matcher:new(),
        _pipe@1 = http_server_mock@matcher:query_param(
            _pipe,
            <<"lang"/utf8>>,
            <<"en"/utf8>>
        ),
        http_server_mock@matcher:matches(
            _pipe@1,
            make_request_with_query(
                get,
                <<"/search"/utf8>>,
                <<"lang=en&q=test"/utf8>>
            )
        )
    end,
    case _assert_subject of
        true -> _assert_subject;
        _assert_fail ->
            erlang:error(#{gleam_error => let_assert,
                        message => <<"Pattern match failed, no pattern matched the value."/utf8>>,
                        file => <<?FILEPATH/utf8>>,
                        module => <<"http_server_mock/matcher_test"/utf8>>,
                        function => <<"query_param_matches_test"/utf8>>,
                        line => 123,
                        value => _assert_fail,
                        start => 2881,
                        'end' => 3069,
                        pattern_start => 2892,
                        pattern_end => 2896})
    end.

-file("test/http_server_mock/matcher_test.gleam", 133).
-spec query_param_rejects_wrong_value_test() -> boolean().
query_param_rejects_wrong_value_test() ->
    _assert_subject = begin
        _pipe = http_server_mock@matcher:new(),
        _pipe@1 = http_server_mock@matcher:query_param(
            _pipe,
            <<"lang"/utf8>>,
            <<"fr"/utf8>>
        ),
        http_server_mock@matcher:matches(
            _pipe@1,
            make_request_with_query(get, <<"/search"/utf8>>, <<"lang=en"/utf8>>)
        )
    end,
    case _assert_subject of
        false -> _assert_subject;
        _assert_fail ->
            erlang:error(#{gleam_error => let_assert,
                        message => <<"Pattern match failed, no pattern matched the value."/utf8>>,
                        file => <<?FILEPATH/utf8>>,
                        module => <<"http_server_mock/matcher_test"/utf8>>,
                        function => <<"query_param_rejects_wrong_value_test"/utf8>>,
                        line => 134,
                        value => _assert_fail,
                        start => 3123,
                        'end' => 3280,
                        pattern_start => 3134,
                        pattern_end => 3139})
    end.

-file("test/http_server_mock/matcher_test.gleam", 140).
-spec query_param_rejects_missing_key_test() -> boolean().
query_param_rejects_missing_key_test() ->
    _assert_subject = begin
        _pipe = http_server_mock@matcher:new(),
        _pipe@1 = http_server_mock@matcher:query_param(
            _pipe,
            <<"lang"/utf8>>,
            <<"en"/utf8>>
        ),
        http_server_mock@matcher:matches(
            _pipe@1,
            make_request(get, <<"/search"/utf8>>)
        )
    end,
    case _assert_subject of
        false -> _assert_subject;
        _assert_fail ->
            erlang:error(#{gleam_error => let_assert,
                        message => <<"Pattern match failed, no pattern matched the value."/utf8>>,
                        file => <<?FILEPATH/utf8>>,
                        module => <<"http_server_mock/matcher_test"/utf8>>,
                        function => <<"query_param_rejects_missing_key_test"/utf8>>,
                        line => 141,
                        value => _assert_fail,
                        start => 3334,
                        'end' => 3469,
                        pattern_start => 3345,
                        pattern_end => 3350})
    end.

-file("test/http_server_mock/matcher_test.gleam", 147).
-spec header_matches_test() -> boolean().
header_matches_test() ->
    Headers = maps:from_list(
        [{<<"content-type"/utf8>>, <<"application/json"/utf8>>}]
    ),
    Recorded_request = {recorded_request,
        <<"t"/utf8>>,
        post,
        <<"/"/utf8>>,
        none,
        Headers,
        <<""/utf8>>,
        0,
        none},
    _assert_subject = begin
        _pipe = http_server_mock@matcher:new(),
        _pipe@1 = http_server_mock@matcher:header(
            _pipe,
            <<"content-type"/utf8>>,
            <<"application/json"/utf8>>
        ),
        http_server_mock@matcher:matches(_pipe@1, Recorded_request)
    end,
    case _assert_subject of
        true -> _assert_subject;
        _assert_fail ->
            erlang:error(#{gleam_error => let_assert,
                        message => <<"Pattern match failed, no pattern matched the value."/utf8>>,
                        file => <<?FILEPATH/utf8>>,
                        module => <<"http_server_mock/matcher_test"/utf8>>,
                        function => <<"header_matches_test"/utf8>>,
                        line => 160,
                        value => _assert_fail,
                        start => 3798,
                        'end' => 3932,
                        pattern_start => 3809,
                        pattern_end => 3813})
    end.

-file("test/http_server_mock/matcher_test.gleam", 166).
-spec header_case_insensitive_key_test() -> boolean().
header_case_insensitive_key_test() ->
    Headers = maps:from_list(
        [{<<"content-type"/utf8>>, <<"application/json"/utf8>>}]
    ),
    Recorded_request = {recorded_request,
        <<"t"/utf8>>,
        post,
        <<"/"/utf8>>,
        none,
        Headers,
        <<""/utf8>>,
        0,
        none},
    _assert_subject = begin
        _pipe = http_server_mock@matcher:new(),
        _pipe@1 = http_server_mock@matcher:header(
            _pipe,
            <<"Content-Type"/utf8>>,
            <<"application/json"/utf8>>
        ),
        http_server_mock@matcher:matches(_pipe@1, Recorded_request)
    end,
    case _assert_subject of
        true -> _assert_subject;
        _assert_fail ->
            erlang:error(#{gleam_error => let_assert,
                        message => <<"Pattern match failed, no pattern matched the value."/utf8>>,
                        file => <<?FILEPATH/utf8>>,
                        module => <<"http_server_mock/matcher_test"/utf8>>,
                        function => <<"header_case_insensitive_key_test"/utf8>>,
                        line => 179,
                        value => _assert_fail,
                        start => 4274,
                        'end' => 4408,
                        pattern_start => 4285,
                        pattern_end => 4289})
    end.

-file("test/http_server_mock/matcher_test.gleam", 185).
-spec body_exact_matches_test() -> boolean().
body_exact_matches_test() ->
    _assert_subject = begin
        _pipe = http_server_mock@matcher:new(),
        _pipe@1 = http_server_mock@matcher:body_equal_to(
            _pipe,
            <<"{\"key\":\"val\"}"/utf8>>
        ),
        http_server_mock@matcher:matches(
            _pipe@1,
            make_request_with_body(<<"{\"key\":\"val\"}"/utf8>>)
        )
    end,
    case _assert_subject of
        true -> _assert_subject;
        _assert_fail ->
            erlang:error(#{gleam_error => let_assert,
                        message => <<"Pattern match failed, no pattern matched the value."/utf8>>,
                        file => <<?FILEPATH/utf8>>,
                        module => <<"http_server_mock/matcher_test"/utf8>>,
                        function => <<"body_exact_matches_test"/utf8>>,
                        line => 186,
                        value => _assert_fail,
                        start => 4449,
                        'end' => 4602,
                        pattern_start => 4460,
                        pattern_end => 4464})
    end.

-file("test/http_server_mock/matcher_test.gleam", 192).
-spec body_exact_rejects_different_test() -> boolean().
body_exact_rejects_different_test() ->
    _assert_subject = begin
        _pipe = http_server_mock@matcher:new(),
        _pipe@1 = http_server_mock@matcher:body_equal_to(
            _pipe,
            <<"{\"key\":\"val\"}"/utf8>>
        ),
        http_server_mock@matcher:matches(
            _pipe@1,
            make_request_with_body(<<"{\"key\":\"other\"}"/utf8>>)
        )
    end,
    case _assert_subject of
        false -> _assert_subject;
        _assert_fail ->
            erlang:error(#{gleam_error => let_assert,
                        message => <<"Pattern match failed, no pattern matched the value."/utf8>>,
                        file => <<?FILEPATH/utf8>>,
                        module => <<"http_server_mock/matcher_test"/utf8>>,
                        function => <<"body_exact_rejects_different_test"/utf8>>,
                        line => 193,
                        value => _assert_fail,
                        start => 4653,
                        'end' => 4809,
                        pattern_start => 4664,
                        pattern_end => 4669})
    end.

-file("test/http_server_mock/matcher_test.gleam", 199).
-spec body_containing_matches_test() -> boolean().
body_containing_matches_test() ->
    _assert_subject = begin
        _pipe = http_server_mock@matcher:new(),
        _pipe@1 = http_server_mock@matcher:body_containing(
            _pipe,
            <<"hello"/utf8>>
        ),
        http_server_mock@matcher:matches(
            _pipe@1,
            make_request_with_body(<<"say hello world"/utf8>>)
        )
    end,
    case _assert_subject of
        true -> _assert_subject;
        _assert_fail ->
            erlang:error(#{gleam_error => let_assert,
                        message => <<"Pattern match failed, no pattern matched the value."/utf8>>,
                        file => <<?FILEPATH/utf8>>,
                        module => <<"http_server_mock/matcher_test"/utf8>>,
                        function => <<"body_containing_matches_test"/utf8>>,
                        line => 200,
                        value => _assert_fail,
                        start => 4855,
                        'end' => 4996,
                        pattern_start => 4866,
                        pattern_end => 4870})
    end.

-file("test/http_server_mock/matcher_test.gleam", 206).
-spec body_json_matches_ignoring_whitespace_test() -> boolean().
body_json_matches_ignoring_whitespace_test() ->
    _assert_subject = begin
        _pipe = http_server_mock@matcher:new(),
        _pipe@1 = http_server_mock@matcher:body_json(
            _pipe,
            <<"{\"a\":1}"/utf8>>
        ),
        http_server_mock@matcher:matches(
            _pipe@1,
            make_request_with_body(<<"{ \"a\" : 1 }"/utf8>>)
        )
    end,
    case _assert_subject of
        true -> _assert_subject;
        _assert_fail ->
            erlang:error(#{gleam_error => let_assert,
                        message => <<"Pattern match failed, no pattern matched the value."/utf8>>,
                        file => <<?FILEPATH/utf8>>,
                        module => <<"http_server_mock/matcher_test"/utf8>>,
                        function => <<"body_json_matches_ignoring_whitespace_test"/utf8>>,
                        line => 207,
                        value => _assert_fail,
                        start => 5056,
                        'end' => 5193,
                        pattern_start => 5067,
                        pattern_end => 5071})
    end.

-file("test/http_server_mock/matcher_test.gleam", 213).
-spec combined_matcher_all_must_match_test() -> boolean().
combined_matcher_all_must_match_test() ->
    _assert_subject = begin
        _pipe = http_server_mock@matcher:new(),
        _pipe@1 = http_server_mock@matcher:method(_pipe, post),
        _pipe@2 = http_server_mock@matcher:path(_pipe@1, <<"/submit"/utf8>>),
        _pipe@3 = http_server_mock@matcher:body_containing(
            _pipe@2,
            <<"data"/utf8>>
        ),
        http_server_mock@matcher:matches(
            _pipe@3,
            {recorded_request,
                <<"t"/utf8>>,
                post,
                <<"/submit"/utf8>>,
                none,
                maps:new(),
                <<"submit data here"/utf8>>,
                0,
                none}
        )
    end,
    case _assert_subject of
        true -> _assert_subject;
        _assert_fail ->
            erlang:error(#{gleam_error => let_assert,
                        message => <<"Pattern match failed, no pattern matched the value."/utf8>>,
                        file => <<?FILEPATH/utf8>>,
                        module => <<"http_server_mock/matcher_test"/utf8>>,
                        function => <<"combined_matcher_all_must_match_test"/utf8>>,
                        line => 214,
                        value => _assert_fail,
                        start => 5247,
                        'end' => 5625,
                        pattern_start => 5258,
                        pattern_end => 5262})
    end.

-file("test/http_server_mock/matcher_test.gleam", 231).
-spec combined_matcher_partial_miss_fails_test() -> boolean().
combined_matcher_partial_miss_fails_test() ->
    _assert_subject = begin
        _pipe = http_server_mock@matcher:new(),
        _pipe@1 = http_server_mock@matcher:method(_pipe, post),
        _pipe@2 = http_server_mock@matcher:path(_pipe@1, <<"/submit"/utf8>>),
        http_server_mock@matcher:matches(
            _pipe@2,
            make_request(get, <<"/submit"/utf8>>)
        )
    end,
    case _assert_subject of
        false -> _assert_subject;
        _assert_fail ->
            erlang:error(#{gleam_error => let_assert,
                        message => <<"Pattern match failed, no pattern matched the value."/utf8>>,
                        file => <<?FILEPATH/utf8>>,
                        module => <<"http_server_mock/matcher_test"/utf8>>,
                        function => <<"combined_matcher_partial_miss_fails_test"/utf8>>,
                        line => 232,
                        value => _assert_fail,
                        start => 5683,
                        'end' => 5841,
                        pattern_start => 5694,
                        pattern_end => 5699})
    end.

-file("test/http_server_mock/matcher_test.gleam", 239).
-spec apply_string_matcher_exact_test() -> boolean().
apply_string_matcher_exact_test() ->
    case http_server_mock@matcher:apply_string_matcher(
        {exact, <<"hello"/utf8>>},
        <<"hello"/utf8>>
    ) of
        true -> nil;
        _assert_fail ->
            erlang:error(#{gleam_error => let_assert,
                        message => <<"Pattern match failed, no pattern matched the value."/utf8>>,
                        file => <<?FILEPATH/utf8>>,
                        module => <<"http_server_mock/matcher_test"/utf8>>,
                        function => <<"apply_string_matcher_exact_test"/utf8>>,
                        line => 240,
                        value => _assert_fail,
                        start => 5890,
                        'end' => 5961,
                        pattern_start => 5901,
                        pattern_end => 5905})
    end,
    _assert_subject = http_server_mock@matcher:apply_string_matcher(
        {exact, <<"hello"/utf8>>},
        <<"world"/utf8>>
    ),
    case _assert_subject of
        false -> _assert_subject;
        _assert_fail@1 ->
            erlang:error(#{gleam_error => let_assert,
                        message => <<"Pattern match failed, no pattern matched the value."/utf8>>,
                        file => <<?FILEPATH/utf8>>,
                        module => <<"http_server_mock/matcher_test"/utf8>>,
                        function => <<"apply_string_matcher_exact_test"/utf8>>,
                        line => 241,
                        value => _assert_fail@1,
                        start => 5964,
                        'end' => 6036,
                        pattern_start => 5975,
                        pattern_end => 5980})
    end.

-file("test/http_server_mock/matcher_test.gleam", 244).
-spec apply_string_matcher_contains_test() -> boolean().
apply_string_matcher_contains_test() ->
    case http_server_mock@matcher:apply_string_matcher(
        {contains, <<"ell"/utf8>>},
        <<"hello"/utf8>>
    ) of
        true -> nil;
        _assert_fail ->
            erlang:error(#{gleam_error => let_assert,
                        message => <<"Pattern match failed, no pattern matched the value."/utf8>>,
                        file => <<?FILEPATH/utf8>>,
                        module => <<"http_server_mock/matcher_test"/utf8>>,
                        function => <<"apply_string_matcher_contains_test"/utf8>>,
                        line => 245,
                        value => _assert_fail,
                        start => 6088,
                        'end' => 6160,
                        pattern_start => 6099,
                        pattern_end => 6103})
    end,
    _assert_subject = http_server_mock@matcher:apply_string_matcher(
        {contains, <<"xyz"/utf8>>},
        <<"hello"/utf8>>
    ),
    case _assert_subject of
        false -> _assert_subject;
        _assert_fail@1 ->
            erlang:error(#{gleam_error => let_assert,
                        message => <<"Pattern match failed, no pattern matched the value."/utf8>>,
                        file => <<?FILEPATH/utf8>>,
                        module => <<"http_server_mock/matcher_test"/utf8>>,
                        function => <<"apply_string_matcher_contains_test"/utf8>>,
                        line => 246,
                        value => _assert_fail@1,
                        start => 6163,
                        'end' => 6236,
                        pattern_start => 6174,
                        pattern_end => 6179})
    end.

-file("test/http_server_mock/matcher_test.gleam", 249).
-spec apply_string_matcher_prefix_test() -> boolean().
apply_string_matcher_prefix_test() ->
    case http_server_mock@matcher:apply_string_matcher(
        {prefix, <<"hel"/utf8>>},
        <<"hello"/utf8>>
    ) of
        true -> nil;
        _assert_fail ->
            erlang:error(#{gleam_error => let_assert,
                        message => <<"Pattern match failed, no pattern matched the value."/utf8>>,
                        file => <<?FILEPATH/utf8>>,
                        module => <<"http_server_mock/matcher_test"/utf8>>,
                        function => <<"apply_string_matcher_prefix_test"/utf8>>,
                        line => 250,
                        value => _assert_fail,
                        start => 6286,
                        'end' => 6356,
                        pattern_start => 6297,
                        pattern_end => 6301})
    end,
    _assert_subject = http_server_mock@matcher:apply_string_matcher(
        {prefix, <<"llo"/utf8>>},
        <<"hello"/utf8>>
    ),
    case _assert_subject of
        false -> _assert_subject;
        _assert_fail@1 ->
            erlang:error(#{gleam_error => let_assert,
                        message => <<"Pattern match failed, no pattern matched the value."/utf8>>,
                        file => <<?FILEPATH/utf8>>,
                        module => <<"http_server_mock/matcher_test"/utf8>>,
                        function => <<"apply_string_matcher_prefix_test"/utf8>>,
                        line => 251,
                        value => _assert_fail@1,
                        start => 6359,
                        'end' => 6430,
                        pattern_start => 6370,
                        pattern_end => 6375})
    end.

-file("test/http_server_mock/matcher_test.gleam", 254).
-spec apply_string_matcher_suffix_test() -> boolean().
apply_string_matcher_suffix_test() ->
    case http_server_mock@matcher:apply_string_matcher(
        {suffix, <<"llo"/utf8>>},
        <<"hello"/utf8>>
    ) of
        true -> nil;
        _assert_fail ->
            erlang:error(#{gleam_error => let_assert,
                        message => <<"Pattern match failed, no pattern matched the value."/utf8>>,
                        file => <<?FILEPATH/utf8>>,
                        module => <<"http_server_mock/matcher_test"/utf8>>,
                        function => <<"apply_string_matcher_suffix_test"/utf8>>,
                        line => 255,
                        value => _assert_fail,
                        start => 6480,
                        'end' => 6550,
                        pattern_start => 6491,
                        pattern_end => 6495})
    end,
    _assert_subject = http_server_mock@matcher:apply_string_matcher(
        {suffix, <<"hel"/utf8>>},
        <<"hello"/utf8>>
    ),
    case _assert_subject of
        false -> _assert_subject;
        _assert_fail@1 ->
            erlang:error(#{gleam_error => let_assert,
                        message => <<"Pattern match failed, no pattern matched the value."/utf8>>,
                        file => <<?FILEPATH/utf8>>,
                        module => <<"http_server_mock/matcher_test"/utf8>>,
                        function => <<"apply_string_matcher_suffix_test"/utf8>>,
                        line => 256,
                        value => _assert_fail@1,
                        start => 6553,
                        'end' => 6624,
                        pattern_start => 6564,
                        pattern_end => 6569})
    end.

-file("test/http_server_mock/matcher_test.gleam", 259).
-spec apply_string_matcher_any_test() -> boolean().
apply_string_matcher_any_test() ->
    case http_server_mock@matcher:apply_string_matcher(any_string, <<""/utf8>>) of
        true -> nil;
        _assert_fail ->
            erlang:error(#{gleam_error => let_assert,
                        message => <<"Pattern match failed, no pattern matched the value."/utf8>>,
                        file => <<?FILEPATH/utf8>>,
                        module => <<"http_server_mock/matcher_test"/utf8>>,
                        function => <<"apply_string_matcher_any_test"/utf8>>,
                        line => 260,
                        value => _assert_fail,
                        start => 6671,
                        'end' => 6732,
                        pattern_start => 6682,
                        pattern_end => 6686})
    end,
    _assert_subject = http_server_mock@matcher:apply_string_matcher(
        any_string,
        <<"anything"/utf8>>
    ),
    case _assert_subject of
        true -> _assert_subject;
        _assert_fail@1 ->
            erlang:error(#{gleam_error => let_assert,
                        message => <<"Pattern match failed, no pattern matched the value."/utf8>>,
                        file => <<?FILEPATH/utf8>>,
                        module => <<"http_server_mock/matcher_test"/utf8>>,
                        function => <<"apply_string_matcher_any_test"/utf8>>,
                        line => 261,
                        value => _assert_fail@1,
                        start => 6735,
                        'end' => 6804,
                        pattern_start => 6746,
                        pattern_end => 6750})
    end.
