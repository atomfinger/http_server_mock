-module(http_server_mock@internal@json_codec).
-compile([no_auto_import, nowarn_unused_vars, nowarn_unused_function, nowarn_nomatch, inline]).
-define(FILEPATH, "src/http_server_mock/internal/json_codec.gleam").
-export([encode_stub/1, encode_stubs/1, encode_recorded_request/1, encode_recorded_requests/1, decode_stub/1, decode_stubs/1, decode_recorded_requests/1]).

-if(?OTP_RELEASE >= 27).
-define(MODULEDOC(Str), -moduledoc(Str)).
-define(DOC(Str), -doc(Str)).
-else.
-define(MODULEDOC(Str), -compile([])).
-define(DOC(Str), -compile([])).
-endif.

?MODULEDOC(false).

-file("src/http_server_mock/internal/json_codec.gleam", 164).
?DOC(false).
-spec encode_scenario_json(http_server_mock@types:scenario_state()) -> gleam@json:json().
encode_scenario_json(Scenario_state) ->
    gleam@json:object(
        [{<<"name"/utf8>>, gleam@json:string(erlang:element(2, Scenario_state))},
            {<<"required_state"/utf8>>,
                case erlang:element(3, Scenario_state) of
                    none ->
                        gleam@json:null();

                    {some, State} ->
                        gleam@json:string(State)
                end},
            {<<"new_state"/utf8>>, case erlang:element(4, Scenario_state) of
                    none ->
                        gleam@json:null();

                    {some, State@1} ->
                        gleam@json:string(State@1)
                end}]
    ).

-file("src/http_server_mock/internal/json_codec.gleam", 147).
?DOC(false).
-spec encode_response_body_json(http_server_mock@types:response_body()) -> gleam@json:json().
encode_response_body_json(Body) ->
    case Body of
        no_body ->
            gleam@json:object(
                [{<<"type"/utf8>>, gleam@json:string(<<"none"/utf8>>)}]
            );

        {string_body, Text} ->
            gleam@json:object(
                [{<<"type"/utf8>>, gleam@json:string(<<"string"/utf8>>)},
                    {<<"value"/utf8>>, gleam@json:string(Text)}]
            );

        {raw_json_body, Json_text} ->
            gleam@json:object(
                [{<<"type"/utf8>>, gleam@json:string(<<"json"/utf8>>)},
                    {<<"value"/utf8>>, gleam@json:string(Json_text)}]
            );

        {bytes_body, _} ->
            gleam@json:object(
                [{<<"type"/utf8>>, gleam@json:string(<<"none"/utf8>>)}]
            )
    end.

-file("src/http_server_mock/internal/json_codec.gleam", 129).
?DOC(false).
-spec encode_response_def_json(http_server_mock@types:response_definition()) -> gleam@json:json().
encode_response_def_json(Response_def) ->
    gleam@json:object(
        [{<<"status"/utf8>>, gleam@json:int(erlang:element(2, Response_def))},
            {<<"headers"/utf8>>,
                gleam@json:array(
                    erlang:element(3, Response_def),
                    fun(Header_pair) ->
                        {Key, Value} = Header_pair,
                        gleam@json:object(
                            [{<<"key"/utf8>>, gleam@json:string(Key)},
                                {<<"value"/utf8>>, gleam@json:string(Value)}]
                        )
                    end
                )},
            {<<"body"/utf8>>,
                encode_response_body_json(erlang:element(4, Response_def))},
            {<<"delay_ms"/utf8>>, case erlang:element(5, Response_def) of
                    none ->
                        gleam@json:null();

                    {some, Milliseconds} ->
                        gleam@json:int(Milliseconds)
                end}]
    ).

-file("src/http_server_mock/internal/json_codec.gleam", 108).
?DOC(false).
-spec encode_body_matcher_json(http_server_mock@types:body_matcher()) -> gleam@json:json().
encode_body_matcher_json(Body_matcher) ->
    case Body_matcher of
        any_body ->
            gleam@json:object(
                [{<<"type"/utf8>>, gleam@json:string(<<"any"/utf8>>)}]
            );

        {exact_body, Value} ->
            gleam@json:object(
                [{<<"type"/utf8>>, gleam@json:string(<<"exact"/utf8>>)},
                    {<<"value"/utf8>>, gleam@json:string(Value)}]
            );

        {contains_body, Value@1} ->
            gleam@json:object(
                [{<<"type"/utf8>>, gleam@json:string(<<"contains"/utf8>>)},
                    {<<"value"/utf8>>, gleam@json:string(Value@1)}]
            );

        {json_body, Value@2} ->
            gleam@json:object(
                [{<<"type"/utf8>>, gleam@json:string(<<"json"/utf8>>)},
                    {<<"value"/utf8>>, gleam@json:string(Value@2)}]
            )
    end.

-file("src/http_server_mock/internal/json_codec.gleam", 82).
?DOC(false).
-spec encode_string_matcher_json(http_server_mock@types:string_matcher()) -> gleam@json:json().
encode_string_matcher_json(String_matcher) ->
    case String_matcher of
        {exact, Value} ->
            gleam@json:object(
                [{<<"type"/utf8>>, gleam@json:string(<<"exact"/utf8>>)},
                    {<<"value"/utf8>>, gleam@json:string(Value)}]
            );

        {contains, Value@1} ->
            gleam@json:object(
                [{<<"type"/utf8>>, gleam@json:string(<<"contains"/utf8>>)},
                    {<<"value"/utf8>>, gleam@json:string(Value@1)}]
            );

        {prefix, Value@2} ->
            gleam@json:object(
                [{<<"type"/utf8>>, gleam@json:string(<<"prefix"/utf8>>)},
                    {<<"value"/utf8>>, gleam@json:string(Value@2)}]
            );

        {suffix, Value@3} ->
            gleam@json:object(
                [{<<"type"/utf8>>, gleam@json:string(<<"suffix"/utf8>>)},
                    {<<"value"/utf8>>, gleam@json:string(Value@3)}]
            );

        any_string ->
            gleam@json:object(
                [{<<"type"/utf8>>, gleam@json:string(<<"any"/utf8>>)}]
            )
    end.

-file("src/http_server_mock/internal/json_codec.gleam", 48).
?DOC(false).
-spec encode_matcher_json(http_server_mock@types:request_matcher()) -> gleam@json:json().
encode_matcher_json(Request_matcher) ->
    gleam@json:object(
        [{<<"method"/utf8>>, case erlang:element(2, Request_matcher) of
                    none ->
                        gleam@json:null();

                    {some, Method} ->
                        gleam@json:string(gleam@http:method_to_string(Method))
                end}, {<<"path"/utf8>>,
                case erlang:element(3, Request_matcher) of
                    none ->
                        gleam@json:null();

                    {some, String_matcher} ->
                        encode_string_matcher_json(String_matcher)
                end}, {<<"query_params"/utf8>>,
                gleam@json:array(
                    erlang:element(4, Request_matcher),
                    fun(Query_param_pair) ->
                        {Key, String_matcher@1} = Query_param_pair,
                        gleam@json:object(
                            [{<<"key"/utf8>>, gleam@json:string(Key)},
                                {<<"matcher"/utf8>>,
                                    encode_string_matcher_json(String_matcher@1)}]
                        )
                    end
                )}, {<<"headers"/utf8>>,
                gleam@json:array(
                    erlang:element(5, Request_matcher),
                    fun(Header_pair) ->
                        {Key@1, String_matcher@2} = Header_pair,
                        gleam@json:object(
                            [{<<"key"/utf8>>, gleam@json:string(Key@1)},
                                {<<"matcher"/utf8>>,
                                    encode_string_matcher_json(String_matcher@2)}]
                        )
                    end
                )}, {<<"body"/utf8>>,
                encode_body_matcher_json(erlang:element(6, Request_matcher))}]
    ).

-file("src/http_server_mock/internal/json_codec.gleam", 35).
?DOC(false).
-spec encode_stub_json(http_server_mock@types:stub()) -> gleam@json:json().
encode_stub_json(Stub) ->
    gleam@json:object(
        [{<<"id"/utf8>>, gleam@json:string(erlang:element(2, Stub))},
            {<<"priority"/utf8>>, gleam@json:int(erlang:element(3, Stub))},
            {<<"request"/utf8>>, encode_matcher_json(erlang:element(4, Stub))},
            {<<"response"/utf8>>,
                encode_response_def_json(erlang:element(5, Stub))},
            {<<"scenario"/utf8>>, case erlang:element(6, Stub) of
                    none ->
                        gleam@json:null();

                    {some, Scenario_state} ->
                        encode_scenario_json(Scenario_state)
                end}]
    ).

-file("src/http_server_mock/internal/json_codec.gleam", 17).
?DOC(false).
-spec encode_stub(http_server_mock@types:stub()) -> binary().
encode_stub(Stub) ->
    _pipe = encode_stub_json(Stub),
    gleam@json:to_string(_pipe).

-file("src/http_server_mock/internal/json_codec.gleam", 21).
?DOC(false).
-spec encode_stubs(list(http_server_mock@types:stub())) -> binary().
encode_stubs(Stubs) ->
    _pipe = gleam@json:array(Stubs, fun encode_stub_json/1),
    gleam@json:to_string(_pipe).

-file("src/http_server_mock/internal/json_codec.gleam", 178).
?DOC(false).
-spec encode_recorded_request_json(http_server_mock@types:recorded_request()) -> gleam@json:json().
encode_recorded_request_json(Recorded_request) ->
    gleam@json:object(
        [{<<"id"/utf8>>, gleam@json:string(erlang:element(2, Recorded_request))},
            {<<"method"/utf8>>,
                gleam@json:string(
                    gleam@http:method_to_string(
                        erlang:element(3, Recorded_request)
                    )
                )},
            {<<"path"/utf8>>,
                gleam@json:string(erlang:element(4, Recorded_request))},
            {<<"query"/utf8>>, case erlang:element(5, Recorded_request) of
                    none ->
                        gleam@json:null();

                    {some, Query_string} ->
                        gleam@json:string(Query_string)
                end},
            {<<"headers"/utf8>>,
                gleam@json:object(
                    begin
                        _pipe = maps:to_list(
                            erlang:element(6, Recorded_request)
                        ),
                        gleam@list:map(
                            _pipe,
                            fun(Header_pair) ->
                                {Key, Value} = Header_pair,
                                {Key, gleam@json:string(Value)}
                            end
                        )
                    end
                )},
            {<<"body"/utf8>>,
                gleam@json:string(erlang:element(7, Recorded_request))},
            {<<"timestamp_ms"/utf8>>,
                gleam@json:int(erlang:element(8, Recorded_request))},
            {<<"matched_stub_id"/utf8>>,
                case erlang:element(9, Recorded_request) of
                    none ->
                        gleam@json:null();

                    {some, Stub_id} ->
                        gleam@json:string(Stub_id)
                end}]
    ).

-file("src/http_server_mock/internal/json_codec.gleam", 25).
?DOC(false).
-spec encode_recorded_request(http_server_mock@types:recorded_request()) -> binary().
encode_recorded_request(Recorded_request) ->
    _pipe = encode_recorded_request_json(Recorded_request),
    gleam@json:to_string(_pipe).

-file("src/http_server_mock/internal/json_codec.gleam", 29).
?DOC(false).
-spec encode_recorded_requests(list(http_server_mock@types:recorded_request())) -> binary().
encode_recorded_requests(Recorded_requests) ->
    _pipe = gleam@json:array(
        Recorded_requests,
        fun encode_recorded_request_json/1
    ),
    gleam@json:to_string(_pipe).

-file("src/http_server_mock/internal/json_codec.gleam", 401).
?DOC(false).
-spec map_decode_error({ok, EXU} | {error, gleam@json:decode_error()}) -> {ok,
        EXU} |
    {error, binary()}.
map_decode_error(Result) ->
    case Result of
        {ok, Value} ->
            {ok, Value};

        {error, unexpected_end_of_input} ->
            {error, <<"Unexpected end of input"/utf8>>};

        {error, {unexpected_byte, Byte}} ->
            {error, <<"Unexpected byte: "/utf8, Byte/binary>>};

        {error, {unexpected_sequence, Sequence}} ->
            {error, <<"Unexpected sequence: "/utf8, Sequence/binary>>};

        {error, {unable_to_decode, Decode_errors}} ->
            {error,
                <<"Decode error: "/utf8,
                    (begin
                        _pipe = gleam@list:map(
                            Decode_errors,
                            fun(Decode_error) ->
                                <<<<<<"expected "/utf8,
                                            (erlang:element(2, Decode_error))/binary>>/binary,
                                        " at "/utf8>>/binary,
                                    (erlang:integer_to_binary(
                                        erlang:length(
                                            erlang:element(4, Decode_error)
                                        )
                                    ))/binary>>
                            end
                        ),
                        gleam@string:join(_pipe, <<", "/utf8>>)
                    end)/binary>>}
    end.

-file("src/http_server_mock/internal/json_codec.gleam", 349).
?DOC(false).
-spec scenario_decoder() -> gleam@dynamic@decode:decoder(http_server_mock@types:scenario_state()).
scenario_decoder() ->
    gleam@dynamic@decode:field(
        <<"name"/utf8>>,
        {decoder, fun gleam@dynamic@decode:decode_string/1},
        fun(Name) ->
            gleam@dynamic@decode:field(
                <<"required_state"/utf8>>,
                gleam@dynamic@decode:optional(
                    {decoder, fun gleam@dynamic@decode:decode_string/1}
                ),
                fun(Required_state) ->
                    gleam@dynamic@decode:field(
                        <<"new_state"/utf8>>,
                        gleam@dynamic@decode:optional(
                            {decoder, fun gleam@dynamic@decode:decode_string/1}
                        ),
                        fun(New_state) ->
                            gleam@dynamic@decode:success(
                                {scenario_state,
                                    Name,
                                    Required_state,
                                    New_state}
                            )
                        end
                    )
                end
            )
        end
    ).

-file("src/http_server_mock/internal/json_codec.gleam", 333).
?DOC(false).
-spec response_body_decoder() -> gleam@dynamic@decode:decoder(http_server_mock@types:response_body()).
response_body_decoder() ->
    gleam@dynamic@decode:field(
        <<"type"/utf8>>,
        {decoder, fun gleam@dynamic@decode:decode_string/1},
        fun(Type_value) -> case Type_value of
                <<"none"/utf8>> ->
                    gleam@dynamic@decode:success(no_body);

                <<"string"/utf8>> ->
                    gleam@dynamic@decode:field(
                        <<"value"/utf8>>,
                        {decoder, fun gleam@dynamic@decode:decode_string/1},
                        fun(Value) ->
                            gleam@dynamic@decode:success({string_body, Value})
                        end
                    );

                <<"json"/utf8>> ->
                    gleam@dynamic@decode:field(
                        <<"value"/utf8>>,
                        {decoder, fun gleam@dynamic@decode:decode_string/1},
                        fun(Value@1) ->
                            gleam@dynamic@decode:success(
                                {raw_json_body, Value@1}
                            )
                        end
                    );

                _ ->
                    gleam@dynamic@decode:success(no_body)
            end end
    ).

-file("src/http_server_mock/internal/json_codec.gleam", 327).
?DOC(false).
-spec key_value_decoder() -> gleam@dynamic@decode:decoder({binary(), binary()}).
key_value_decoder() ->
    gleam@dynamic@decode:field(
        <<"key"/utf8>>,
        {decoder, fun gleam@dynamic@decode:decode_string/1},
        fun(Key) ->
            gleam@dynamic@decode:field(
                <<"value"/utf8>>,
                {decoder, fun gleam@dynamic@decode:decode_string/1},
                fun(Value) -> gleam@dynamic@decode:success({Key, Value}) end
            )
        end
    ).

-file("src/http_server_mock/internal/json_codec.gleam", 314).
?DOC(false).
-spec response_def_decoder() -> gleam@dynamic@decode:decoder(http_server_mock@types:response_definition()).
response_def_decoder() ->
    gleam@dynamic@decode:field(
        <<"status"/utf8>>,
        {decoder, fun gleam@dynamic@decode:decode_int/1},
        fun(Status) ->
            gleam@dynamic@decode:field(
                <<"headers"/utf8>>,
                gleam@dynamic@decode:list(key_value_decoder()),
                fun(Headers) ->
                    gleam@dynamic@decode:field(
                        <<"body"/utf8>>,
                        response_body_decoder(),
                        fun(Body) ->
                            gleam@dynamic@decode:field(
                                <<"delay_ms"/utf8>>,
                                gleam@dynamic@decode:optional(
                                    {decoder,
                                        fun gleam@dynamic@decode:decode_int/1}
                                ),
                                fun(Delay_ms) ->
                                    gleam@dynamic@decode:success(
                                        {response_definition,
                                            Status,
                                            Headers,
                                            Body,
                                            Delay_ms}
                                    )
                                end
                            )
                        end
                    )
                end
            )
        end
    ).

-file("src/http_server_mock/internal/json_codec.gleam", 294).
?DOC(false).
-spec body_matcher_decoder() -> gleam@dynamic@decode:decoder(http_server_mock@types:body_matcher()).
body_matcher_decoder() ->
    gleam@dynamic@decode:field(
        <<"type"/utf8>>,
        {decoder, fun gleam@dynamic@decode:decode_string/1},
        fun(Type_value) -> case Type_value of
                <<"any"/utf8>> ->
                    gleam@dynamic@decode:success(any_body);

                <<"exact"/utf8>> ->
                    gleam@dynamic@decode:field(
                        <<"value"/utf8>>,
                        {decoder, fun gleam@dynamic@decode:decode_string/1},
                        fun(Value) ->
                            gleam@dynamic@decode:success({exact_body, Value})
                        end
                    );

                <<"contains"/utf8>> ->
                    gleam@dynamic@decode:field(
                        <<"value"/utf8>>,
                        {decoder, fun gleam@dynamic@decode:decode_string/1},
                        fun(Value@1) ->
                            gleam@dynamic@decode:success(
                                {contains_body, Value@1}
                            )
                        end
                    );

                <<"json"/utf8>> ->
                    gleam@dynamic@decode:field(
                        <<"value"/utf8>>,
                        {decoder, fun gleam@dynamic@decode:decode_string/1},
                        fun(Value@2) ->
                            gleam@dynamic@decode:success({json_body, Value@2})
                        end
                    );

                _ ->
                    gleam@dynamic@decode:failure(
                        any_body,
                        <<"BodyMatcher type"/utf8>>
                    )
            end end
    ).

-file("src/http_server_mock/internal/json_codec.gleam", 270).
?DOC(false).
-spec string_matcher_decoder() -> gleam@dynamic@decode:decoder(http_server_mock@types:string_matcher()).
string_matcher_decoder() ->
    gleam@dynamic@decode:field(
        <<"type"/utf8>>,
        {decoder, fun gleam@dynamic@decode:decode_string/1},
        fun(Type_value) -> case Type_value of
                <<"any"/utf8>> ->
                    gleam@dynamic@decode:success(any_string);

                <<"exact"/utf8>> ->
                    gleam@dynamic@decode:field(
                        <<"value"/utf8>>,
                        {decoder, fun gleam@dynamic@decode:decode_string/1},
                        fun(Value) ->
                            gleam@dynamic@decode:success({exact, Value})
                        end
                    );

                <<"contains"/utf8>> ->
                    gleam@dynamic@decode:field(
                        <<"value"/utf8>>,
                        {decoder, fun gleam@dynamic@decode:decode_string/1},
                        fun(Value@1) ->
                            gleam@dynamic@decode:success({contains, Value@1})
                        end
                    );

                <<"prefix"/utf8>> ->
                    gleam@dynamic@decode:field(
                        <<"value"/utf8>>,
                        {decoder, fun gleam@dynamic@decode:decode_string/1},
                        fun(Value@2) ->
                            gleam@dynamic@decode:success({prefix, Value@2})
                        end
                    );

                <<"suffix"/utf8>> ->
                    gleam@dynamic@decode:field(
                        <<"value"/utf8>>,
                        {decoder, fun gleam@dynamic@decode:decode_string/1},
                        fun(Value@3) ->
                            gleam@dynamic@decode:success({suffix, Value@3})
                        end
                    );

                _ ->
                    gleam@dynamic@decode:failure(
                        any_string,
                        <<"StringMatcher type"/utf8>>
                    )
            end end
    ).

-file("src/http_server_mock/internal/json_codec.gleam", 264).
?DOC(false).
-spec key_matcher_decoder() -> gleam@dynamic@decode:decoder({binary(),
    http_server_mock@types:string_matcher()}).
key_matcher_decoder() ->
    gleam@dynamic@decode:field(
        <<"key"/utf8>>,
        {decoder, fun gleam@dynamic@decode:decode_string/1},
        fun(Key) ->
            gleam@dynamic@decode:field(
                <<"matcher"/utf8>>,
                string_matcher_decoder(),
                fun(String_matcher) ->
                    gleam@dynamic@decode:success({Key, String_matcher})
                end
            )
        end
    ).

-file("src/http_server_mock/internal/json_codec.gleam", 236).
?DOC(false).
-spec request_matcher_decoder() -> gleam@dynamic@decode:decoder(http_server_mock@types:request_matcher()).
request_matcher_decoder() ->
    gleam@dynamic@decode:field(
        <<"method"/utf8>>,
        gleam@dynamic@decode:optional(
            {decoder, fun gleam@dynamic@decode:decode_string/1}
        ),
        fun(Method_string) ->
            gleam@dynamic@decode:field(
                <<"path"/utf8>>,
                gleam@dynamic@decode:optional(string_matcher_decoder()),
                fun(Path_matcher) ->
                    gleam@dynamic@decode:field(
                        <<"query_params"/utf8>>,
                        gleam@dynamic@decode:list(key_matcher_decoder()),
                        fun(Query_params) ->
                            gleam@dynamic@decode:field(
                                <<"headers"/utf8>>,
                                gleam@dynamic@decode:list(key_matcher_decoder()),
                                fun(Headers) ->
                                    gleam@dynamic@decode:field(
                                        <<"body"/utf8>>,
                                        body_matcher_decoder(),
                                        fun(Body_matcher) ->
                                            gleam@dynamic@decode:success(
                                                {request_matcher,
                                                    case Method_string of
                                                        none ->
                                                            none;

                                                        {some, Method_str} ->
                                                            case gleam@http:parse_method(
                                                                Method_str
                                                            ) of
                                                                {ok, Method} ->
                                                                    {some,
                                                                        Method};

                                                                {error, nil} ->
                                                                    none
                                                            end
                                                    end,
                                                    Path_matcher,
                                                    Query_params,
                                                    Headers,
                                                    Body_matcher}
                                            )
                                        end
                                    )
                                end
                            )
                        end
                    )
                end
            )
        end
    ).

-file("src/http_server_mock/internal/json_codec.gleam", 218).
?DOC(false).
-spec stub_decoder() -> gleam@dynamic@decode:decoder(http_server_mock@types:stub()).
stub_decoder() ->
    gleam@dynamic@decode:field(
        <<"id"/utf8>>,
        {decoder, fun gleam@dynamic@decode:decode_string/1},
        fun(Id) ->
            gleam@dynamic@decode:field(
                <<"priority"/utf8>>,
                {decoder, fun gleam@dynamic@decode:decode_int/1},
                fun(Priority) ->
                    gleam@dynamic@decode:field(
                        <<"request"/utf8>>,
                        request_matcher_decoder(),
                        fun(Request_matcher) ->
                            gleam@dynamic@decode:field(
                                <<"response"/utf8>>,
                                response_def_decoder(),
                                fun(Response_def) ->
                                    gleam@dynamic@decode:field(
                                        <<"scenario"/utf8>>,
                                        gleam@dynamic@decode:optional(
                                            scenario_decoder()
                                        ),
                                        fun(Scenario_state) ->
                                            gleam@dynamic@decode:success(
                                                {stub,
                                                    Id,
                                                    Priority,
                                                    Request_matcher,
                                                    Response_def,
                                                    Scenario_state}
                                            )
                                        end
                                    )
                                end
                            )
                        end
                    )
                end
            )
        end
    ).

-file("src/http_server_mock/internal/json_codec.gleam", 208).
?DOC(false).
-spec decode_stub(binary()) -> {ok, http_server_mock@types:stub()} |
    {error, binary()}.
decode_stub(Json_string) ->
    _pipe = gleam@json:parse(Json_string, stub_decoder()),
    map_decode_error(_pipe).

-file("src/http_server_mock/internal/json_codec.gleam", 213).
?DOC(false).
-spec decode_stubs(binary()) -> {ok, list(http_server_mock@types:stub())} |
    {error, binary()}.
decode_stubs(Json_string) ->
    _pipe = gleam@json:parse(
        Json_string,
        gleam@dynamic@decode:list(stub_decoder())
    ),
    map_decode_error(_pipe).

-file("src/http_server_mock/internal/json_codec.gleam", 370).
?DOC(false).
-spec recorded_request_decoder() -> gleam@dynamic@decode:decoder(http_server_mock@types:recorded_request()).
recorded_request_decoder() ->
    gleam@dynamic@decode:field(
        <<"id"/utf8>>,
        {decoder, fun gleam@dynamic@decode:decode_string/1},
        fun(Id) ->
            gleam@dynamic@decode:field(
                <<"method"/utf8>>,
                {decoder, fun gleam@dynamic@decode:decode_string/1},
                fun(Method_string) ->
                    gleam@dynamic@decode:field(
                        <<"path"/utf8>>,
                        {decoder, fun gleam@dynamic@decode:decode_string/1},
                        fun(Path) ->
                            gleam@dynamic@decode:field(
                                <<"query"/utf8>>,
                                gleam@dynamic@decode:optional(
                                    {decoder,
                                        fun gleam@dynamic@decode:decode_string/1}
                                ),
                                fun(Query) ->
                                    gleam@dynamic@decode:field(
                                        <<"headers"/utf8>>,
                                        gleam@dynamic@decode:dict(
                                            {decoder,
                                                fun gleam@dynamic@decode:decode_string/1},
                                            {decoder,
                                                fun gleam@dynamic@decode:decode_string/1}
                                        ),
                                        fun(Headers) ->
                                            gleam@dynamic@decode:field(
                                                <<"body"/utf8>>,
                                                {decoder,
                                                    fun gleam@dynamic@decode:decode_string/1},
                                                fun(Body) ->
                                                    gleam@dynamic@decode:field(
                                                        <<"timestamp_ms"/utf8>>,
                                                        {decoder,
                                                            fun gleam@dynamic@decode:decode_int/1},
                                                        fun(Timestamp_ms) ->
                                                            gleam@dynamic@decode:field(
                                                                <<"matched_stub_id"/utf8>>,
                                                                gleam@dynamic@decode:optional(
                                                                    {decoder,
                                                                        fun gleam@dynamic@decode:decode_string/1}
                                                                ),
                                                                fun(
                                                                    Matched_stub_id
                                                                ) ->
                                                                    Method@1 = case gleam@http:parse_method(
                                                                        Method_string
                                                                    ) of
                                                                        {ok,
                                                                            Method} ->
                                                                            Method;

                                                                        {error,
                                                                            nil} ->
                                                                            get
                                                                    end,
                                                                    gleam@dynamic@decode:success(
                                                                        {recorded_request,
                                                                            Id,
                                                                            Method@1,
                                                                            Path,
                                                                            Query,
                                                                            Headers,
                                                                            Body,
                                                                            Timestamp_ms,
                                                                            Matched_stub_id}
                                                                    )
                                                                end
                                                            )
                                                        end
                                                    )
                                                end
                                            )
                                        end
                                    )
                                end
                            )
                        end
                    )
                end
            )
        end
    ).

-file("src/http_server_mock/internal/json_codec.gleam", 363).
?DOC(false).
-spec decode_recorded_requests(binary()) -> {ok,
        list(http_server_mock@types:recorded_request())} |
    {error, binary()}.
decode_recorded_requests(Json_string) ->
    _pipe = gleam@json:parse(
        Json_string,
        gleam@dynamic@decode:list(recorded_request_decoder())
    ),
    map_decode_error(_pipe).
