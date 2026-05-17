-module(http_server_mock@internal@router).
-compile([no_auto_import, nowarn_unused_vars, nowarn_unused_function, nowarn_nomatch, inline]).
-define(FILEPATH, "src/http_server_mock/internal/router.gleam").
-export([score/3, find_match/3]).

-if(?OTP_RELEASE >= 27).
-define(MODULEDOC(Str), -moduledoc(Str)).
-define(DOC(Str), -doc(Str)).
-else.
-define(MODULEDOC(Str), -compile([])).
-define(DOC(Str), -compile([])).
-endif.

?MODULEDOC(false).

-file("src/http_server_mock/internal/router.gleam", 96).
?DOC(false).
-spec compare_ints(integer(), integer()) -> gleam@order:order().
compare_ints(Left, Right) ->
    case Left < Right of
        true ->
            lt;

        false ->
            case Left > Right of
                true ->
                    gt;

                false ->
                    eq
            end
    end.

-file("src/http_server_mock/internal/router.gleam", 73).
?DOC(false).
-spec compute_score(
    http_server_mock@types:request_matcher(),
    http_server_mock@types:recorded_request()
) -> integer().
compute_score(Request_matcher, _) ->
    Method_score = case erlang:element(2, Request_matcher) of
        {some, _} ->
            100;

        none ->
            0
    end,
    Path_score = case erlang:element(3, Request_matcher) of
        none ->
            0;

        {some, {exact, _}} ->
            80;

        {some, _} ->
            40
    end,
    Query_score = erlang:length(erlang:element(4, Request_matcher)) * 20,
    Header_score = erlang:length(erlang:element(5, Request_matcher)) * 10,
    Body_score = case erlang:element(6, Request_matcher) of
        any_body ->
            0;

        {exact_body, _} ->
            50;

        {contains_body, _} ->
            30;

        {json_body, _} ->
            30
    end,
    (((Method_score + Path_score) + Query_score) + Header_score) + Body_score.

-file("src/http_server_mock/internal/router.gleam", 52).
?DOC(false).
-spec scenario_matches(
    http_server_mock@types:stub(),
    gleam@dict:dict(binary(), binary())
) -> boolean().
scenario_matches(Stub, Scenarios) ->
    case erlang:element(6, Stub) of
        none ->
            true;

        {some, Scenario_state} ->
            Current = gleam_stdlib:map_get(
                Scenarios,
                erlang:element(2, Scenario_state)
            ),
            case erlang:element(3, Scenario_state) of
                none ->
                    case Current of
                        {error, nil} ->
                            true;

                        {ok, _} ->
                            false
                    end;

                {some, Required} ->
                    case Current of
                        {ok, State} ->
                            State =:= Required;

                        {error, nil} ->
                            false
                    end
            end
    end.

-file("src/http_server_mock/internal/router.gleam", 38).
?DOC(false).
-spec score(
    http_server_mock@types:stub(),
    gleam@dict:dict(binary(), binary()),
    http_server_mock@types:recorded_request()
) -> gleam@option:option(integer()).
score(Stub, Scenarios, Recorded_request) ->
    case scenario_matches(Stub, Scenarios) andalso http_server_mock@matcher:matches(
        erlang:element(4, Stub),
        Recorded_request
    ) of
        false ->
            none;

        true ->
            {some, compute_score(erlang:element(4, Stub), Recorded_request)}
    end.

-file("src/http_server_mock/internal/router.gleam", 10).
?DOC(false).
-spec find_match(
    list(http_server_mock@types:stub()),
    gleam@dict:dict(binary(), binary()),
    http_server_mock@types:recorded_request()
) -> gleam@option:option({http_server_mock@types:stub(),
    http_server_mock@types:response_definition()}).
find_match(Stubs, Scenarios, Recorded_request) ->
    Scored = begin
        _pipe = Stubs,
        _pipe@1 = gleam@list:map(
            _pipe,
            fun(Stub) -> {score(Stub, Scenarios, Recorded_request), Stub} end
        ),
        _pipe@2 = gleam@list:filter(
            _pipe@1,
            fun(Pair) -> gleam@option:is_some(erlang:element(1, Pair)) end
        ),
        _pipe@3 = gleam@list:map(
            _pipe@2,
            fun(Pair@1) ->
                {Score_option, Stub@1} = Pair@1,
                Score_value@1 = case Score_option of
                    {some, Score_value} -> Score_value;
                    _assert_fail ->
                        erlang:error(#{gleam_error => let_assert,
                                    message => <<"Pattern match failed, no pattern matched the value."/utf8>>,
                                    file => <<?FILEPATH/utf8>>,
                                    module => <<"http_server_mock/internal/router"/utf8>>,
                                    function => <<"find_match"/utf8>>,
                                    line => 21,
                                    value => _assert_fail,
                                    start => 628,
                                    'end' => 671,
                                    pattern_start => 639,
                                    pattern_end => 656})
                end,
                {Score_value@1, Stub@1}
            end
        ),
        gleam@list:sort(
            _pipe@3,
            fun(Left, Right) ->
                {Left_score, Left_stub} = Left,
                {Right_score, Right_stub} = Right,
                case erlang:element(3, Left_stub) =:= erlang:element(
                    3,
                    Right_stub
                ) of
                    true ->
                        gleam@order:negate(
                            compare_ints(Left_score, Right_score)
                        );

                    false ->
                        compare_ints(
                            erlang:element(3, Left_stub),
                            erlang:element(3, Right_stub)
                        )
                end
            end
        )
    end,
    case Scored of
        [] ->
            none;

        [{_, Stub@2} | _] ->
            {some, {Stub@2, erlang:element(5, Stub@2)}}
    end.
