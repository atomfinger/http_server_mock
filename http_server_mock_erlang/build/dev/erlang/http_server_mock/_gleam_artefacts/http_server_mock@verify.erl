-module(http_server_mock@verify).
-compile([no_auto_import, nowarn_unused_vars, nowarn_unused_function, nowarn_nomatch, inline]).
-define(FILEPATH, "src/http_server_mock/verify.gleam").
-export([called/2, called_times/3, called_at_least/3, never_called/2]).

-if(?OTP_RELEASE >= 27).
-define(MODULEDOC(Str), -moduledoc(Str)).
-define(DOC(Str), -doc(Str)).
-else.
-define(MODULEDOC(Str), -compile([])).
-define(DOC(Str), -compile([])).
-endif.

?MODULEDOC(
    " Assertion helpers for verifying that the mock server received the expected\n"
    " requests.\n"
    "\n"
    " Each function accepts a running server and a `RequestMatcher` describing\n"
    " which requests to count. On failure the functions panic with a descriptive\n"
    " message that includes the matcher, the expected and actual counts, and a\n"
    " list of all recorded requests.\n"
    "\n"
    " ```gleam\n"
    " verify.called_times(server, m, 1)\n"
    " verify.never_called(server, other_matcher)\n"
    " ```\n"
).

-file("src/http_server_mock/verify.gleam", 153).
-spec format_requests(list(http_server_mock@types:recorded_request())) -> binary().
format_requests(Recorded_requests) ->
    case Recorded_requests of
        [] ->
            <<"  (none)"/utf8>>;

        _ ->
            _pipe = Recorded_requests,
            _pipe@2 = gleam@list:map(
                _pipe,
                fun(Recorded_request) ->
                    <<<<<<<<"  "/utf8,
                                    (begin
                                        _pipe@1 = gleam@http:method_to_string(
                                            erlang:element(3, Recorded_request)
                                        ),
                                        string:uppercase(_pipe@1)
                                    end)/binary>>/binary,
                                " "/utf8>>/binary,
                            (erlang:element(4, Recorded_request))/binary>>/binary,
                        (case erlang:element(5, Recorded_request) of
                            none ->
                                <<""/utf8>>;

                            {some, Query_string} ->
                                <<"?"/utf8, Query_string/binary>>
                        end)/binary>>
                end
            ),
            gleam@string:join(_pipe@2, <<"\n"/utf8>>)
    end.

-file("src/http_server_mock/verify.gleam", 137).
-spec format_matcher(http_server_mock@types:request_matcher()) -> binary().
format_matcher(Request_matcher) ->
    Method@1 = case erlang:element(2, Request_matcher) of
        none ->
            <<"ANY"/utf8>>;

        {some, Method} ->
            _pipe = gleam@http:method_to_string(Method),
            string:uppercase(_pipe)
    end,
    Path@1 = case erlang:element(3, Request_matcher) of
        none ->
            <<"ANY PATH"/utf8>>;

        {some, {exact, Path}} ->
            Path;

        {some, {contains, Fragment}} ->
            <<"CONTAINS "/utf8, Fragment/binary>>;

        {some, {prefix, Prefix}} ->
            <<"PREFIX "/utf8, Prefix/binary>>;

        {some, {suffix, Suffix}} ->
            <<"SUFFIX "/utf8, Suffix/binary>>;

        {some, any_string} ->
            <<"ANY PATH"/utf8>>
    end,
    <<<<<<"Matcher: "/utf8, Method@1/binary>>/binary, " "/utf8>>/binary,
        Path@1/binary>>.

-file("src/http_server_mock/verify.gleam", 129).
-spec fetch_requests(
    http_server_mock@internal@server:mock_server(http_server_mock@internal@server:started())
) -> list(http_server_mock@types:recorded_request()).
fetch_requests(Mock_server) ->
    case http_server_mock@internal@server:recorded_requests(Mock_server) of
        {ok, Requests} ->
            Requests;

        {error, Reason} ->
            erlang:error(#{gleam_error => panic,
                    message => (<<"Failed to fetch recorded requests: "/utf8,
                        Reason/binary>>),
                    file => <<?FILEPATH/utf8>>,
                    module => <<"http_server_mock/verify"/utf8>>,
                    function => <<"fetch_requests"/utf8>>,
                    line => 133})
    end.

-file("src/http_server_mock/verify.gleam", 27).
?DOC(
    " Asserts that at least one recorded request matches `request_matcher`.\n"
    "\n"
    " Returns the matching requests so you can chain further assertions.\n"
    " Panics with a descriptive message if no matching request was recorded.\n"
).
-spec called(
    http_server_mock@internal@server:mock_server(http_server_mock@internal@server:started()),
    http_server_mock@types:request_matcher()
) -> list(http_server_mock@types:recorded_request()).
called(Mock_server, Request_matcher) ->
    Recorded_requests = fetch_requests(Mock_server),
    Matched = gleam@list:filter(
        Recorded_requests,
        fun(_capture) ->
            http_server_mock@matcher:matches(Request_matcher, _capture)
        end
    ),
    case Matched of
        [] ->
            erlang:error(#{gleam_error => panic,
                    message => (<<<<<<"Expected at least one matching request but got none.\n"/utf8,
                                (format_matcher(Request_matcher))/binary>>/binary,
                            "\nRecorded requests:\n"/utf8>>/binary,
                        (format_requests(Recorded_requests))/binary>>),
                    file => <<?FILEPATH/utf8>>,
                    module => <<"http_server_mock/verify"/utf8>>,
                    function => <<"called"/utf8>>,
                    line => 36});

        _ ->
            Matched
    end.

-file("src/http_server_mock/verify.gleam", 50).
?DOC(
    " Asserts that exactly `count` recorded requests match `request_matcher`.\n"
    "\n"
    " Returns the matching requests so you can chain further assertions.\n"
    " Panics with a descriptive message if the actual count differs from `count`.\n"
).
-spec called_times(
    http_server_mock@internal@server:mock_server(http_server_mock@internal@server:started()),
    http_server_mock@types:request_matcher(),
    integer()
) -> list(http_server_mock@types:recorded_request()).
called_times(Mock_server, Request_matcher, Count) ->
    Recorded_requests = fetch_requests(Mock_server),
    Matched = gleam@list:filter(
        Recorded_requests,
        fun(_capture) ->
            http_server_mock@matcher:matches(Request_matcher, _capture)
        end
    ),
    Matched_count = erlang:length(Matched),
    case Matched_count =:= Count of
        true ->
            Matched;

        false ->
            erlang:error(#{gleam_error => panic,
                    message => (<<<<<<<<<<<<<<"Expected "/utf8,
                                                (erlang:integer_to_binary(Count))/binary>>/binary,
                                            " matching request(s) but got "/utf8>>/binary,
                                        (erlang:integer_to_binary(Matched_count))/binary>>/binary,
                                    ".\n"/utf8>>/binary,
                                (format_matcher(Request_matcher))/binary>>/binary,
                            "\nRecorded requests:\n"/utf8>>/binary,
                        (format_requests(Recorded_requests))/binary>>),
                    file => <<?FILEPATH/utf8>>,
                    module => <<"http_server_mock/verify"/utf8>>,
                    function => <<"called_times"/utf8>>,
                    line => 62})
    end.

-file("src/http_server_mock/verify.gleam", 79).
?DOC(
    " Asserts that at least `count` recorded requests match `request_matcher`.\n"
    "\n"
    " Returns the matching requests so you can chain further assertions.\n"
    " Panics with a descriptive message if fewer than `count` requests matched.\n"
).
-spec called_at_least(
    http_server_mock@internal@server:mock_server(http_server_mock@internal@server:started()),
    http_server_mock@types:request_matcher(),
    integer()
) -> list(http_server_mock@types:recorded_request()).
called_at_least(Mock_server, Request_matcher, Count) ->
    Recorded_requests = fetch_requests(Mock_server),
    Matched = gleam@list:filter(
        Recorded_requests,
        fun(_capture) ->
            http_server_mock@matcher:matches(Request_matcher, _capture)
        end
    ),
    Matched_count = erlang:length(Matched),
    case Matched_count >= Count of
        true ->
            Matched;

        false ->
            erlang:error(#{gleam_error => panic,
                    message => (<<<<<<<<<<<<<<"Expected at least "/utf8,
                                                (erlang:integer_to_binary(Count))/binary>>/binary,
                                            " matching request(s) but got "/utf8>>/binary,
                                        (erlang:integer_to_binary(Matched_count))/binary>>/binary,
                                    ".\n"/utf8>>/binary,
                                (format_matcher(Request_matcher))/binary>>/binary,
                            "\nRecorded requests:\n"/utf8>>/binary,
                        (format_requests(Recorded_requests))/binary>>),
                    file => <<?FILEPATH/utf8>>,
                    module => <<"http_server_mock/verify"/utf8>>,
                    function => <<"called_at_least"/utf8>>,
                    line => 91})
    end.

-file("src/http_server_mock/verify.gleam", 108).
?DOC(
    " Asserts that no recorded request matches `request_matcher`.\n"
    "\n"
    " Panics with a descriptive message (including the unexpected requests) if\n"
    " any matching request was recorded.\n"
).
-spec never_called(
    http_server_mock@internal@server:mock_server(http_server_mock@internal@server:started()),
    http_server_mock@types:request_matcher()
) -> nil.
never_called(Mock_server, Request_matcher) ->
    Recorded_requests = fetch_requests(Mock_server),
    Matched = gleam@list:filter(
        Recorded_requests,
        fun(_capture) ->
            http_server_mock@matcher:matches(Request_matcher, _capture)
        end
    ),
    case Matched of
        [] ->
            nil;

        _ ->
            erlang:error(#{gleam_error => panic,
                    message => (<<<<<<<<<<"Expected no matching requests but got "/utf8,
                                        (erlang:integer_to_binary(
                                            erlang:length(Matched)
                                        ))/binary>>/binary,
                                    ".\n"/utf8>>/binary,
                                (format_matcher(Request_matcher))/binary>>/binary,
                            "\nMatched requests:\n"/utf8>>/binary,
                        (format_requests(Matched))/binary>>),
                    file => <<?FILEPATH/utf8>>,
                    module => <<"http_server_mock/verify"/utf8>>,
                    function => <<"never_called"/utf8>>,
                    line => 118})
    end.
