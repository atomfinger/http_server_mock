-module(http_server_mock@internal@server_impl).
-compile([no_auto_import, nowarn_unused_vars, nowarn_unused_function, nowarn_nomatch, inline]).
-define(FILEPATH, "src/http_server_mock/internal/server_impl.gleam").
-export([start_server/1, stop_server/1, add_stub/2, remove_stub/2, clear_stubs/1, get_stubs/1, get_requests/1, clear_requests/1]).
-export_type([server_state/0, server_message/0, handle/0]).

-type server_state() :: {server_state,
        list(http_server_mock@types:stub()),
        list(http_server_mock@types:recorded_request()),
        gleam@dict:dict(binary(), binary())}.

-type server_message() :: {add_stub,
        http_server_mock@types:stub(),
        gleam@erlang@process:subject(binary())} |
    {remove_stub, binary(), gleam@erlang@process:subject(nil)} |
    {clear_stubs, gleam@erlang@process:subject(nil)} |
    {get_stubs, gleam@erlang@process:subject(binary())} |
    {match_request,
        http_server_mock@types:recorded_request(),
        gleam@erlang@process:subject(gleam@option:option(http_server_mock@types:response_definition()))} |
    {get_requests, gleam@erlang@process:subject(binary())} |
    {clear_requests, gleam@erlang@process:subject(nil)} |
    shutdown.

-type handle() :: {handle,
        gleam@erlang@process:subject(server_message()),
        gleam@erlang@process:pid_()}.

-file("src/http_server_mock/internal/server_impl.gleam", 356).
-spec build_response(http_server_mock@types:response_definition()) -> gleam@http@response:response(mist:response_data()).
build_response(Response_def) ->
    Body_tree = case erlang:element(4, Response_def) of
        no_body ->
            gleam@bytes_tree:new();

        {string_body, Text} ->
            gleam_stdlib:wrap_list(Text);

        {raw_json_body, Json_text} ->
            gleam_stdlib:wrap_list(Json_text);

        {bytes_body, Bytes} ->
            gleam@bytes_tree:from_bit_array(Bytes)
    end,
    Base_response = begin
        _pipe = gleam@http@response:new(erlang:element(2, Response_def)),
        gleam@http@response:set_body(_pipe, {bytes, Body_tree})
    end,
    gleam@list:fold(
        erlang:element(3, Response_def),
        Base_response,
        fun(Current_response, Header_pair) ->
            {Key, Value} = Header_pair,
            gleam@http@response:set_header(Current_response, Key, Value)
        end
    ).

-file("src/http_server_mock/internal/server_impl.gleam", 379).
-spec json_response(binary(), integer()) -> gleam@http@response:response(mist:response_data()).
json_response(Body, Status) ->
    _pipe = gleam@http@response:new(Status),
    _pipe@1 = gleam@http@response:set_header(
        _pipe,
        <<"content-type"/utf8>>,
        <<"application/json"/utf8>>
    ),
    gleam@http@response:set_body(_pipe@1, {bytes, gleam_stdlib:wrap_list(Body)}).

-file("src/http_server_mock/internal/server_impl.gleam", 433).
-spec now_ms() -> integer().
now_ms() ->
    erlang:system_time(erlang:binary_to_atom(<<"millisecond"/utf8>>)).

-file("src/http_server_mock/internal/server_impl.gleam", 428).
-spec new_id() -> binary().
new_id() ->
    <<"req_"/utf8, (erlang:integer_to_binary(erlang:unique_integer()))/binary>>.

-file("src/http_server_mock/internal/server_impl.gleam", 239).
-spec read_body_string(
    gleam@http@request:request(mist@internal@http:connection())
) -> binary().
read_body_string(Mist_request) ->
    case mist:read_body(Mist_request, 4194304) of
        {ok, Request_with_body} ->
            _pipe = erlang:element(4, Request_with_body),
            _pipe@1 = gleam@bit_array:to_string(_pipe),
            gleam@result:unwrap(_pipe@1, <<""/utf8>>);

        {error, _} ->
            <<""/utf8>>
    end.

-file("src/http_server_mock/internal/server_impl.gleam", 250).
-spec handle_stub(
    gleam@erlang@process:subject(server_message()),
    gleam@http@request:request(mist@internal@http:connection())
) -> gleam@http@response:response(mist:response_data()).
handle_stub(Subject, Mist_request) ->
    Body_string = read_body_string(Mist_request),
    Headers_dict = gleam@list:fold(
        erlang:element(3, Mist_request),
        maps:new(),
        fun(Header_dict, Header_pair) ->
            {Key, Value} = Header_pair,
            gleam@dict:insert(Header_dict, string:lowercase(Key), Value)
        end
    ),
    Recorded_request = {recorded_request,
        new_id(),
        erlang:element(2, Mist_request),
        erlang:element(8, Mist_request),
        erlang:element(9, Mist_request),
        Headers_dict,
        Body_string,
        now_ms(),
        none},
    case gleam@erlang@process:call(
        Subject,
        5000,
        fun(Reply_subject) ->
            {match_request, Recorded_request, Reply_subject}
        end
    ) of
        none ->
            json_response(
                <<<<"{\"status\":404,\"message\":\"No stub matched\",\"path\":\""/utf8,
                        (erlang:element(8, Mist_request))/binary>>/binary,
                    "\"}"/utf8>>,
                404
            );

        {some, Response_def} ->
            case erlang:element(5, Response_def) of
                {some, Milliseconds} ->
                    timer:sleep(Milliseconds);

                none ->
                    nil
            end,
            build_response(Response_def)
    end.

-file("src/http_server_mock/internal/server_impl.gleam", 297).
-spec handle_admin(
    gleam@erlang@process:subject(server_message()),
    gleam@http@request:request(mist@internal@http:connection())
) -> gleam@http@response:response(mist:response_data()).
handle_admin(Subject, Mist_request) ->
    Body_string = read_body_string(Mist_request),
    Path = erlang:element(8, Mist_request),
    Method = erlang:element(2, Mist_request),
    case {Method, Path} of
        {get, <<"/__admin/health"/utf8>>} ->
            json_response(<<"{\"status\":\"ok\"}"/utf8>>, 200);

        {get, <<"/__admin/stubs"/utf8>>} ->
            json_response(
                gleam@erlang@process:call(
                    Subject,
                    5000,
                    fun(Reply_subject) -> {get_stubs, Reply_subject} end
                ),
                200
            );

        {post, <<"/__admin/stubs"/utf8>>} ->
            case http_server_mock@internal@json_codec:decode_stub(Body_string) of
                {error, Error_message} ->
                    json_response(
                        <<<<"{\"error\":\""/utf8, Error_message/binary>>/binary,
                            "\"}"/utf8>>,
                        400
                    );

                {ok, Stub} ->
                    Stub_id = gleam@erlang@process:call(
                        Subject,
                        5000,
                        fun(Reply_subject@1) ->
                            {add_stub, Stub, Reply_subject@1}
                        end
                    ),
                    json_response(
                        <<<<"{\"id\":\""/utf8, Stub_id/binary>>/binary,
                            "\"}"/utf8>>,
                        201
                    )
            end;

        {delete, <<"/__admin/stubs"/utf8>>} ->
            gleam@erlang@process:call(
                Subject,
                5000,
                fun(Reply_subject@2) -> {clear_stubs, Reply_subject@2} end
            ),
            json_response(<<"{\"status\":\"ok\"}"/utf8>>, 200);

        {get, <<"/__admin/requests"/utf8>>} ->
            json_response(
                gleam@erlang@process:call(
                    Subject,
                    5000,
                    fun(Reply_subject@3) -> {get_requests, Reply_subject@3} end
                ),
                200
            );

        {delete, <<"/__admin/requests"/utf8>>} ->
            gleam@erlang@process:call(
                Subject,
                5000,
                fun(Reply_subject@4) -> {clear_requests, Reply_subject@4} end
            ),
            json_response(<<"{\"status\":\"ok\"}"/utf8>>, 200);

        {_, _} ->
            json_response(<<"{\"error\":\"Not found\"}"/utf8>>, 404)
    end.

-file("src/http_server_mock/internal/server_impl.gleam", 228).
-spec handle_http(
    gleam@erlang@process:subject(server_message()),
    gleam@http@request:request(mist@internal@http:connection())
) -> gleam@http@response:response(mist:response_data()).
handle_http(Subject, Mist_request) ->
    case gleam_stdlib:string_starts_with(
        erlang:element(8, Mist_request),
        <<"/__admin"/utf8>>
    ) of
        true ->
            handle_admin(Subject, Mist_request);

        false ->
            handle_stub(Subject, Mist_request)
    end.

-file("src/http_server_mock/internal/server_impl.gleam", 404).
-spec advance_scenario(
    gleam@dict:dict(binary(), binary()),
    http_server_mock@types:stub()
) -> gleam@dict:dict(binary(), binary()).
advance_scenario(Scenarios, Stub) ->
    case erlang:element(6, Stub) of
        none ->
            Scenarios;

        {some, Scenario_state} ->
            case erlang:element(4, Scenario_state) of
                none ->
                    Scenarios;

                {some, New_state} ->
                    gleam@dict:insert(
                        Scenarios,
                        erlang:element(2, Scenario_state),
                        New_state
                    )
            end
    end.

-file("src/http_server_mock/internal/server_impl.gleam", 389).
-spec insert_stub(
    list(http_server_mock@types:stub()),
    http_server_mock@types:stub()
) -> list(http_server_mock@types:stub()).
insert_stub(Stubs, New_stub) ->
    Without_existing = gleam@list:filter(
        Stubs,
        fun(Stub) -> erlang:element(2, Stub) /= erlang:element(2, New_stub) end
    ),
    gleam@list:sort(
        [New_stub | Without_existing],
        fun(Left, Right) ->
            case erlang:element(3, Left) < erlang:element(3, Right) of
                true ->
                    lt;

                false ->
                    case erlang:element(3, Left) > erlang:element(3, Right) of
                        true ->
                            gt;

                        false ->
                            eq
                    end
            end
        end
    ).

-file("src/http_server_mock/internal/server_impl.gleam", 149).
-spec handle_message(server_state(), server_message()) -> gleam@otp@actor:next(server_state(), server_message()).
handle_message(State, Message) ->
    case Message of
        shutdown ->
            gleam@otp@actor:stop();

        {add_stub, Stub, Reply_subject} ->
            gleam@erlang@process:send(Reply_subject, erlang:element(2, Stub)),
            gleam@otp@actor:continue(
                {server_state,
                    insert_stub(erlang:element(2, State), Stub),
                    erlang:element(3, State),
                    erlang:element(4, State)}
            );

        {remove_stub, Id, Reply_subject@1} ->
            gleam@erlang@process:send(Reply_subject@1, nil),
            gleam@otp@actor:continue(
                {server_state,
                    gleam@list:filter(
                        erlang:element(2, State),
                        fun(Stub@1) -> erlang:element(2, Stub@1) /= Id end
                    ),
                    erlang:element(3, State),
                    erlang:element(4, State)}
            );

        {clear_stubs, Reply_subject@2} ->
            gleam@erlang@process:send(Reply_subject@2, nil),
            gleam@otp@actor:continue(
                {server_state,
                    [],
                    erlang:element(3, State),
                    erlang:element(4, State)}
            );

        {get_stubs, Reply_subject@3} ->
            gleam@erlang@process:send(
                Reply_subject@3,
                http_server_mock@internal@json_codec:encode_stubs(
                    erlang:element(2, State)
                )
            ),
            gleam@otp@actor:continue(State);

        {match_request, Recorded_request, Reply_subject@4} ->
            case http_server_mock@internal@router:find_match(
                erlang:element(2, State),
                erlang:element(4, State),
                Recorded_request
            ) of
                none ->
                    Recorded = {recorded_request,
                        erlang:element(2, Recorded_request),
                        erlang:element(3, Recorded_request),
                        erlang:element(4, Recorded_request),
                        erlang:element(5, Recorded_request),
                        erlang:element(6, Recorded_request),
                        erlang:element(7, Recorded_request),
                        erlang:element(8, Recorded_request),
                        none},
                    gleam@erlang@process:send(Reply_subject@4, none),
                    gleam@otp@actor:continue(
                        {server_state,
                            erlang:element(2, State),
                            [Recorded | erlang:element(3, State)],
                            erlang:element(4, State)}
                    );

                {some, {Stub@2, Response_def}} ->
                    Recorded@1 = {recorded_request,
                        erlang:element(2, Recorded_request),
                        erlang:element(3, Recorded_request),
                        erlang:element(4, Recorded_request),
                        erlang:element(5, Recorded_request),
                        erlang:element(6, Recorded_request),
                        erlang:element(7, Recorded_request),
                        erlang:element(8, Recorded_request),
                        {some, erlang:element(2, Stub@2)}},
                    Updated_scenarios = advance_scenario(
                        erlang:element(4, State),
                        Stub@2
                    ),
                    gleam@erlang@process:send(
                        Reply_subject@4,
                        {some, Response_def}
                    ),
                    gleam@otp@actor:continue(
                        {server_state,
                            erlang:element(2, State),
                            [Recorded@1 | erlang:element(3, State)],
                            Updated_scenarios}
                    )
            end;

        {get_requests, Reply_subject@5} ->
            gleam@erlang@process:send(
                Reply_subject@5,
                http_server_mock@internal@json_codec:encode_recorded_requests(
                    erlang:element(3, State)
                )
            ),
            gleam@otp@actor:continue(State);

        {clear_requests, Reply_subject@6} ->
            gleam@erlang@process:send(Reply_subject@6, nil),
            gleam@otp@actor:continue(
                {server_state,
                    erlang:element(2, State),
                    [],
                    erlang:element(4, State)}
            )
    end.

-file("src/http_server_mock/internal/server_impl.gleam", 51).
-spec start_server(integer()) -> {ok, {integer(), gleam@dynamic:dynamic_()}} |
    {error, binary()}.
start_server(Port) ->
    Initial_state = {server_state, [], [], maps:new()},
    gleam@result:'try'(
        begin
            _pipe = gleam@otp@actor:new(Initial_state),
            _pipe@1 = gleam@otp@actor:on_message(_pipe, fun handle_message/2),
            _pipe@2 = gleam@otp@actor:start(_pipe@1),
            gleam@result:map_error(
                _pipe@2,
                fun(_) -> <<"Failed to start state actor"/utf8>> end
            )
        end,
        fun(Started) ->
            Subject = erlang:element(3, Started),
            Port_channel = gleam@erlang@process:new_subject(),
            Port_selector = begin
                _pipe@3 = gleam_erlang_ffi:new_selector(),
                gleam@erlang@process:select(_pipe@3, Port_channel)
            end,
            gleam@result:'try'(
                begin
                    _pipe@4 = mist:new(
                        fun(Mist_request) ->
                            handle_http(Subject, Mist_request)
                        end
                    ),
                    _pipe@5 = mist:port(_pipe@4, Port),
                    _pipe@6 = mist:bind(_pipe@5, <<"0.0.0.0"/utf8>>),
                    _pipe@7 = mist:after_start(
                        _pipe@6,
                        fun(Actual_port, _, _) ->
                            gleam@erlang@process:send(Port_channel, Actual_port)
                        end
                    ),
                    _pipe@8 = mist:start(_pipe@7),
                    gleam@result:map_error(
                        _pipe@8,
                        fun(_) -> <<"Failed to start HTTP server"/utf8>> end
                    )
                end,
                fun(Mist_started) ->
                    Actual_port@1 = case gleam_erlang_ffi:select(
                        Port_selector,
                        5000
                    ) of
                        {ok, Assigned_port} ->
                            Assigned_port;

                        {error, nil} ->
                            Port
                    end,
                    Server_handle = {handle,
                        Subject,
                        erlang:element(2, Mist_started)},
                    {ok, {Actual_port@1, gleam_stdlib:identity(Server_handle)}}
                end
            )
        end
    ).

-file("src/http_server_mock/internal/server_impl.gleam", 87).
-spec stop_server(gleam@dynamic:dynamic_()) -> nil.
stop_server(Handle) ->
    Server_handle = gleam_stdlib:identity(Handle),
    gleam@erlang@process:send(erlang:element(2, Server_handle), shutdown),
    gleam@erlang@process:send_exit(erlang:element(3, Server_handle)).

-file("src/http_server_mock/internal/server_impl.gleam", 94).
-spec add_stub(gleam@dynamic:dynamic_(), binary()) -> {ok, binary()} |
    {error, binary()}.
add_stub(Handle, Stub_json) ->
    Server_handle = gleam_stdlib:identity(Handle),
    case http_server_mock@internal@json_codec:decode_stub(Stub_json) of
        {error, Error_message} ->
            {error, <<"Invalid stub JSON: "/utf8, Error_message/binary>>};

        {ok, Stub} ->
            Stub_id = gleam@erlang@process:call(
                erlang:element(2, Server_handle),
                5000,
                fun(Reply_subject) -> {add_stub, Stub, Reply_subject} end
            ),
            {ok, Stub_id}
    end.

-file("src/http_server_mock/internal/server_impl.gleam", 109).
-spec remove_stub(gleam@dynamic:dynamic_(), binary()) -> nil.
remove_stub(Handle, Id) ->
    Server_handle = gleam_stdlib:identity(Handle),
    gleam@erlang@process:call(
        erlang:element(2, Server_handle),
        5000,
        fun(Reply_subject) -> {remove_stub, Id, Reply_subject} end
    ).

-file("src/http_server_mock/internal/server_impl.gleam", 117).
-spec clear_stubs(gleam@dynamic:dynamic_()) -> nil.
clear_stubs(Handle) ->
    Server_handle = gleam_stdlib:identity(Handle),
    gleam@erlang@process:call(
        erlang:element(2, Server_handle),
        5000,
        fun(Reply_subject) -> {clear_stubs, Reply_subject} end
    ).

-file("src/http_server_mock/internal/server_impl.gleam", 125).
-spec get_stubs(gleam@dynamic:dynamic_()) -> binary().
get_stubs(Handle) ->
    Server_handle = gleam_stdlib:identity(Handle),
    gleam@erlang@process:call(
        erlang:element(2, Server_handle),
        5000,
        fun(Reply_subject) -> {get_stubs, Reply_subject} end
    ).

-file("src/http_server_mock/internal/server_impl.gleam", 133).
-spec get_requests(gleam@dynamic:dynamic_()) -> binary().
get_requests(Handle) ->
    Server_handle = gleam_stdlib:identity(Handle),
    gleam@erlang@process:call(
        erlang:element(2, Server_handle),
        5000,
        fun(Reply_subject) -> {get_requests, Reply_subject} end
    ).

-file("src/http_server_mock/internal/server_impl.gleam", 141).
-spec clear_requests(gleam@dynamic:dynamic_()) -> nil.
clear_requests(Handle) ->
    Server_handle = gleam_stdlib:identity(Handle),
    gleam@erlang@process:call(
        erlang:element(2, Server_handle),
        5000,
        fun(Reply_subject) -> {clear_requests, Reply_subject} end
    ).
