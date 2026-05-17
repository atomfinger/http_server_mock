-module(http_server_mock@matcher).
-compile([no_auto_import, nowarn_unused_vars, nowarn_unused_function, nowarn_nomatch, inline]).
-define(FILEPATH, "src/http_server_mock/matcher.gleam").
-export([new/0, method/2, path/2, path_matching/2, path_contains/2, query_param/3, query_param_matching/3, header/3, header_matching/3, body_equal_to/2, body_containing/2, body_json/2, body_matcher/2, apply_string_matcher/2, matches/2]).

-if(?OTP_RELEASE >= 27).
-define(MODULEDOC(Str), -moduledoc(Str)).
-define(DOC(Str), -doc(Str)).
-else.
-define(MODULEDOC(Str), -compile([])).
-define(DOC(Str), -compile([])).
-endif.

?MODULEDOC(
    " Builder for `RequestMatcher` — the rules that decide whether an incoming\n"
    " request should be handled by a given stub.\n"
    "\n"
    " Start with `new()` and pipe through the constraint functions you need.\n"
    " Constraints that are not set match anything, so a `new()` with no\n"
    " constraints will match every request.\n"
    "\n"
    " ```gleam\n"
    " let m =\n"
    "   matcher.new()\n"
    "   |> matcher.method(http.Post)\n"
    "   |> matcher.path(\"/orders\")\n"
    "   |> matcher.header(\"x-api-key\", \"secret\")\n"
    "   |> matcher.body_json(\"{\\\"amount\\\":100}\")\n"
    " ```\n"
).

-file("src/http_server_mock/matcher.gleam", 29).
?DOC(" Returns a new `RequestMatcher` with no constraints — matches every request.\n").
-spec new() -> http_server_mock@types:request_matcher().
new() ->
    {request_matcher, none, none, [], [], any_body}.

-file("src/http_server_mock/matcher.gleam", 40).
?DOC(" Constrains the matcher to only match requests with the given HTTP method.\n").
-spec method(http_server_mock@types:request_matcher(), gleam@http:method()) -> http_server_mock@types:request_matcher().
method(Request_matcher, Method) ->
    {request_matcher,
        {some, Method},
        erlang:element(3, Request_matcher),
        erlang:element(4, Request_matcher),
        erlang:element(5, Request_matcher),
        erlang:element(6, Request_matcher)}.

-file("src/http_server_mock/matcher.gleam", 51).
?DOC(
    " Constrains the matcher to only match requests whose path is exactly equal\n"
    " to `path`.\n"
    "\n"
    " Use `path_matching` or `path_contains` for partial matches.\n"
).
-spec path(http_server_mock@types:request_matcher(), binary()) -> http_server_mock@types:request_matcher().
path(Request_matcher, Path) ->
    {request_matcher,
        erlang:element(2, Request_matcher),
        {some, {exact, Path}},
        erlang:element(4, Request_matcher),
        erlang:element(5, Request_matcher),
        erlang:element(6, Request_matcher)}.

-file("src/http_server_mock/matcher.gleam", 60).
?DOC(
    " Constrains the matcher to only match requests whose path satisfies the\n"
    " given `StringMatcher`.\n"
    "\n"
    " Use this when you need `Contains`, `Prefix`, or `Suffix` path matching\n"
    " instead of an exact match.\n"
).
-spec path_matching(
    http_server_mock@types:request_matcher(),
    http_server_mock@types:string_matcher()
) -> http_server_mock@types:request_matcher().
path_matching(Request_matcher, String_matcher) ->
    {request_matcher,
        erlang:element(2, Request_matcher),
        {some, String_matcher},
        erlang:element(4, Request_matcher),
        erlang:element(5, Request_matcher),
        erlang:element(6, Request_matcher)}.

-file("src/http_server_mock/matcher.gleam", 69).
?DOC(
    " Constrains the matcher to only match requests whose path contains\n"
    " `fragment` as a substring.\n"
).
-spec path_contains(http_server_mock@types:request_matcher(), binary()) -> http_server_mock@types:request_matcher().
path_contains(Request_matcher, Fragment) ->
    {request_matcher,
        erlang:element(2, Request_matcher),
        {some, {contains, Fragment}},
        erlang:element(4, Request_matcher),
        erlang:element(5, Request_matcher),
        erlang:element(6, Request_matcher)}.

-file("src/http_server_mock/matcher.gleam", 80).
?DOC(
    " Constrains the matcher to only match requests that have the query parameter\n"
    " `key` set to exactly `value`.\n"
    "\n"
    " Can be called multiple times to require several query parameters.\n"
).
-spec query_param(http_server_mock@types:request_matcher(), binary(), binary()) -> http_server_mock@types:request_matcher().
query_param(Request_matcher, Key, Value) ->
    {request_matcher,
        erlang:element(2, Request_matcher),
        erlang:element(3, Request_matcher),
        [{Key, {exact, Value}} | erlang:element(4, Request_matcher)],
        erlang:element(5, Request_matcher),
        erlang:element(6, Request_matcher)}.

-file("src/http_server_mock/matcher.gleam", 95).
?DOC(
    " Constrains the matcher to only match requests that have the query parameter\n"
    " `key` satisfying the given `StringMatcher`.\n"
    "\n"
    " Can be called multiple times to require several query parameters.\n"
).
-spec query_param_matching(
    http_server_mock@types:request_matcher(),
    binary(),
    http_server_mock@types:string_matcher()
) -> http_server_mock@types:request_matcher().
query_param_matching(Request_matcher, Key, String_matcher) ->
    {request_matcher,
        erlang:element(2, Request_matcher),
        erlang:element(3, Request_matcher),
        [{Key, String_matcher} | erlang:element(4, Request_matcher)],
        erlang:element(5, Request_matcher),
        erlang:element(6, Request_matcher)}.

-file("src/http_server_mock/matcher.gleam", 110).
?DOC(
    " Constrains the matcher to only match requests that have the header `key`\n"
    " set to exactly `value`. Header names are compared case-insensitively.\n"
    "\n"
    " Can be called multiple times to require several headers.\n"
).
-spec header(http_server_mock@types:request_matcher(), binary(), binary()) -> http_server_mock@types:request_matcher().
header(Request_matcher, Key, Value) ->
    {request_matcher,
        erlang:element(2, Request_matcher),
        erlang:element(3, Request_matcher),
        erlang:element(4, Request_matcher),
        [{string:lowercase(Key), {exact, Value}} |
            erlang:element(5, Request_matcher)],
        erlang:element(6, Request_matcher)}.

-file("src/http_server_mock/matcher.gleam", 126).
?DOC(
    " Constrains the matcher to only match requests that have the header `key`\n"
    " satisfying the given `StringMatcher`. Header names are compared\n"
    " case-insensitively.\n"
    "\n"
    " Can be called multiple times to require several headers.\n"
).
-spec header_matching(
    http_server_mock@types:request_matcher(),
    binary(),
    http_server_mock@types:string_matcher()
) -> http_server_mock@types:request_matcher().
header_matching(Request_matcher, Key, String_matcher) ->
    {request_matcher,
        erlang:element(2, Request_matcher),
        erlang:element(3, Request_matcher),
        erlang:element(4, Request_matcher),
        [{string:lowercase(Key), String_matcher} |
            erlang:element(5, Request_matcher)],
        erlang:element(6, Request_matcher)}.

-file("src/http_server_mock/matcher.gleam", 139).
?DOC(
    " Constrains the matcher to only match requests whose body is exactly equal\n"
    " to `body`.\n"
).
-spec body_equal_to(http_server_mock@types:request_matcher(), binary()) -> http_server_mock@types:request_matcher().
body_equal_to(Request_matcher, Body) ->
    {request_matcher,
        erlang:element(2, Request_matcher),
        erlang:element(3, Request_matcher),
        erlang:element(4, Request_matcher),
        erlang:element(5, Request_matcher),
        {exact_body, Body}}.

-file("src/http_server_mock/matcher.gleam", 148).
?DOC(
    " Constrains the matcher to only match requests whose body contains\n"
    " `fragment` as a substring.\n"
).
-spec body_containing(http_server_mock@types:request_matcher(), binary()) -> http_server_mock@types:request_matcher().
body_containing(Request_matcher, Fragment) ->
    {request_matcher,
        erlang:element(2, Request_matcher),
        erlang:element(3, Request_matcher),
        erlang:element(4, Request_matcher),
        erlang:element(5, Request_matcher),
        {contains_body, Fragment}}.

-file("src/http_server_mock/matcher.gleam", 158).
?DOC(
    " Constrains the matcher to only match requests whose body is semantically\n"
    " equal to `json` when both are parsed as JSON (whitespace and key order are\n"
    " ignored).\n"
).
-spec body_json(http_server_mock@types:request_matcher(), binary()) -> http_server_mock@types:request_matcher().
body_json(Request_matcher, Json) ->
    {request_matcher,
        erlang:element(2, Request_matcher),
        erlang:element(3, Request_matcher),
        erlang:element(4, Request_matcher),
        erlang:element(5, Request_matcher),
        {json_body, Json}}.

-file("src/http_server_mock/matcher.gleam", 169).
?DOC(
    " Constrains the matcher using a custom `BodyMatcher`.\n"
    "\n"
    " Use this when none of the convenience functions (`body_equal_to`,\n"
    " `body_containing`, `body_json`) cover your use case.\n"
).
-spec body_matcher(
    http_server_mock@types:request_matcher(),
    http_server_mock@types:body_matcher()
) -> http_server_mock@types:request_matcher().
body_matcher(Request_matcher, Body_matcher) ->
    {request_matcher,
        erlang:element(2, Request_matcher),
        erlang:element(3, Request_matcher),
        erlang:element(4, Request_matcher),
        erlang:element(5, Request_matcher),
        Body_matcher}.

-file("src/http_server_mock/matcher.gleam", 282).
-spec normalize_json(binary()) -> binary().
normalize_json(Json_string) ->
    _pipe = Json_string,
    _pipe@1 = gleam@string:replace(_pipe, <<" "/utf8>>, <<""/utf8>>),
    _pipe@2 = gleam@string:replace(_pipe@1, <<"\n"/utf8>>, <<""/utf8>>),
    _pipe@3 = gleam@string:replace(_pipe@2, <<"\t"/utf8>>, <<""/utf8>>),
    gleam@string:replace(_pipe@3, <<"\r"/utf8>>, <<""/utf8>>).

-file("src/http_server_mock/matcher.gleam", 241).
-spec body_matches(http_server_mock@types:body_matcher(), binary()) -> boolean().
body_matches(Expected, Actual) ->
    case Expected of
        any_body ->
            true;

        {exact_body, Body} ->
            Actual =:= Body;

        {contains_body, Fragment} ->
            gleam_stdlib:contains_string(Actual, Fragment);

        {json_body, Expected_json} ->
            normalize_json(Actual) =:= normalize_json(Expected_json)
    end.

-file("src/http_server_mock/matcher.gleam", 254).
?DOC(
    " Applies a `StringMatcher` to `value`, returning `True` if it matches.\n"
    "\n"
    " Exposed for use in custom filtering logic over `recorded_requests`.\n"
).
-spec apply_string_matcher(http_server_mock@types:string_matcher(), binary()) -> boolean().
apply_string_matcher(String_matcher, Value) ->
    case String_matcher of
        {exact, Expected} ->
            Value =:= Expected;

        {contains, Fragment} ->
            gleam_stdlib:contains_string(Value, Fragment);

        {prefix, Prefix} ->
            gleam_stdlib:string_starts_with(Value, Prefix);

        {suffix, Suffix} ->
            gleam_stdlib:string_ends_with(Value, Suffix);

        any_string ->
            true
    end.

-file("src/http_server_mock/matcher.gleam", 228).
-spec headers_match(
    list({binary(), http_server_mock@types:string_matcher()}),
    gleam@dict:dict(binary(), binary())
) -> boolean().
headers_match(Expected, Actual) ->
    gleam@list:all(
        Expected,
        fun(Header_pair) ->
            {Key, String_matcher} = Header_pair,
            case gleam_stdlib:map_get(Actual, string:lowercase(Key)) of
                {ok, Value} ->
                    apply_string_matcher(String_matcher, Value);

                {error, nil} ->
                    String_matcher =:= any_string
            end
        end
    ).

-file("src/http_server_mock/matcher.gleam", 267).
-spec parse_query(gleam@option:option(binary())) -> list({binary(), binary()}).
parse_query(Query_string) ->
    case Query_string of
        none ->
            [];

        {some, Query} ->
            _pipe = Query,
            _pipe@1 = gleam@string:split(_pipe, <<"&"/utf8>>),
            gleam@list:filter_map(
                _pipe@1,
                fun(Part) -> case gleam@string:split_once(Part, <<"="/utf8>>) of
                        {ok, {Key, Value}} ->
                            {ok, {Key, Value}};

                        {error, nil} ->
                            {ok, {Part, <<""/utf8>>}}
                    end end
            )
    end.

-file("src/http_server_mock/matcher.gleam", 209).
-spec query_params_match(
    list({binary(), http_server_mock@types:string_matcher()}),
    gleam@option:option(binary())
) -> boolean().
query_params_match(Expected, Query_string) ->
    case Expected of
        [] ->
            true;

        _ ->
            Params = parse_query(Query_string),
            gleam@list:all(
                Expected,
                fun(Query_param_pair) ->
                    {Key, String_matcher} = Query_param_pair,
                    case gleam@list:key_find(Params, Key) of
                        {ok, Value} ->
                            apply_string_matcher(String_matcher, Value);

                        {error, nil} ->
                            String_matcher =:= any_string
                    end
                end
            )
    end.

-file("src/http_server_mock/matcher.gleam", 199).
-spec path_matches(
    gleam@option:option(http_server_mock@types:string_matcher()),
    binary()
) -> boolean().
path_matches(Expected, Actual) ->
    case Expected of
        none ->
            true;

        {some, String_matcher} ->
            apply_string_matcher(String_matcher, Actual)
    end.

-file("src/http_server_mock/matcher.gleam", 192).
-spec method_matches(
    gleam@option:option(gleam@http:method()),
    gleam@http:method()
) -> boolean().
method_matches(Expected, Actual) ->
    case Expected of
        none ->
            true;

        {some, Method} ->
            Method =:= Actual
    end.

-file("src/http_server_mock/matcher.gleam", 181).
?DOC(
    " Returns `True` if `recorded_request` satisfies all constraints on\n"
    " `request_matcher`.\n"
    "\n"
    " This is the same matching logic the server uses internally. You can call it\n"
    " directly when filtering `recorded_requests` for custom assertions.\n"
).
-spec matches(
    http_server_mock@types:request_matcher(),
    http_server_mock@types:recorded_request()
) -> boolean().
matches(Request_matcher, Recorded_request) ->
    (((method_matches(
        erlang:element(2, Request_matcher),
        erlang:element(3, Recorded_request)
    )
    andalso path_matches(
        erlang:element(3, Request_matcher),
        erlang:element(4, Recorded_request)
    ))
    andalso query_params_match(
        erlang:element(4, Request_matcher),
        erlang:element(5, Recorded_request)
    ))
    andalso headers_match(
        erlang:element(5, Request_matcher),
        erlang:element(6, Recorded_request)
    ))
    andalso body_matches(
        erlang:element(6, Request_matcher),
        erlang:element(7, Recorded_request)
    ).
