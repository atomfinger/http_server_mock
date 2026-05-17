-module(http_server_mock@internal@server).
-compile([no_auto_import, nowarn_unused_vars, nowarn_unused_function, nowarn_nomatch, inline]).
-define(FILEPATH, "src/http_server_mock/internal/server.gleam").
-export([new/1, with_port/2, start/1, port/1, base_url/1, stop/1, register/2, remove_stub/2, reset_stubs/1, get_stubs/1, recorded_requests/1, reset_requests/1, reset/1]).
-export_type([not_started/0, started/0, stopped/0, mock_server/1]).

-if(?OTP_RELEASE >= 27).
-define(MODULEDOC(Str), -moduledoc(Str)).
-define(DOC(Str), -doc(Str)).
-else.
-define(MODULEDOC(Str), -compile([])).
-define(DOC(Str), -compile([])).
-endif.

?MODULEDOC(false).

-type not_started() :: any().

-type started() :: any().

-type stopped() :: any().

-opaque mock_server(ALX) :: {mock_server_not_started,
        integer(),
        http_server_mock@server_adapter:server_adapter()} |
    {mock_server_started,
        integer(),
        gleam@dynamic:dynamic_(),
        http_server_mock@server_adapter:server_adapter()} |
    {mock_server_stopped, integer()} |
    {gleam_phantom, ALX}.

-file("src/http_server_mock/internal/server.gleam", 22).
?DOC(false).
-spec new(http_server_mock@server_adapter:server_adapter()) -> mock_server(not_started()).
new(Adapter) ->
    {mock_server_not_started, 0, Adapter}.

-file("src/http_server_mock/internal/server.gleam", 26).
?DOC(false).
-spec with_port(mock_server(not_started()), integer()) -> mock_server(not_started()).
with_port(Mock_server, Port_number) ->
    Adapter@1 = case Mock_server of
        {mock_server_not_started, _, Adapter} -> Adapter;
        _assert_fail ->
            erlang:error(#{gleam_error => let_assert,
                        message => <<"Pattern match failed, no pattern matched the value."/utf8>>,
                        file => <<?FILEPATH/utf8>>,
                        module => <<"http_server_mock/internal/server"/utf8>>,
                        function => <<"with_port"/utf8>>,
                        line => 30,
                        value => _assert_fail,
                        start => 899,
                        'end' => 956,
                        pattern_start => 910,
                        pattern_end => 942})
    end,
    {mock_server_not_started, Port_number, Adapter@1}.

-file("src/http_server_mock/internal/server.gleam", 34).
?DOC(false).
-spec start(mock_server(not_started())) -> {ok, mock_server(started())} |
    {error, binary()}.
start(Mock_server) ->
    {Port@1, Adapter@1} = case Mock_server of
        {mock_server_not_started, Port, Adapter} -> {Port, Adapter};
        _assert_fail ->
            erlang:error(#{gleam_error => let_assert,
                        message => <<"Pattern match failed, no pattern matched the value."/utf8>>,
                        file => <<?FILEPATH/utf8>>,
                        module => <<"http_server_mock/internal/server"/utf8>>,
                        function => <<"start"/utf8>>,
                        line => 37,
                        value => _assert_fail,
                        start => 1118,
                        'end' => 1178,
                        pattern_start => 1129,
                        pattern_end => 1164})
    end,
    case (erlang:element(2, Adapter@1))(Port@1) of
        {ok, {Actual_port, Handle}} ->
            {ok, {mock_server_started, Actual_port, Handle, Adapter@1}};

        {error, Reason} ->
            {error, Reason}
    end.

-file("src/http_server_mock/internal/server.gleam", 45).
?DOC(false).
-spec port(mock_server(started())) -> integer().
port(Mock_server) ->
    Port@1 = case Mock_server of
        {mock_server_started, Port, _, _} -> Port;
        _assert_fail ->
            erlang:error(#{gleam_error => let_assert,
                        message => <<"Pattern match failed, no pattern matched the value."/utf8>>,
                        file => <<?FILEPATH/utf8>>,
                        module => <<"http_server_mock/internal/server"/utf8>>,
                        function => <<"port"/utf8>>,
                        line => 46,
                        value => _assert_fail,
                        start => 1399,
                        'end' => 1453,
                        pattern_start => 1410,
                        pattern_end => 1439})
    end,
    Port@1.

-file("src/http_server_mock/internal/server.gleam", 50).
?DOC(false).
-spec base_url(mock_server(started())) -> binary().
base_url(Mock_server) ->
    Port@1 = case Mock_server of
        {mock_server_started, Port, _, _} -> Port;
        _assert_fail ->
            erlang:error(#{gleam_error => let_assert,
                        message => <<"Pattern match failed, no pattern matched the value."/utf8>>,
                        file => <<?FILEPATH/utf8>>,
                        module => <<"http_server_mock/internal/server"/utf8>>,
                        function => <<"base_url"/utf8>>,
                        line => 51,
                        value => _assert_fail,
                        start => 1528,
                        'end' => 1582,
                        pattern_start => 1539,
                        pattern_end => 1568})
    end,
    <<"http://localhost:"/utf8, (erlang:integer_to_binary(Port@1))/binary>>.

-file("src/http_server_mock/internal/server.gleam", 55).
?DOC(false).
-spec stop(mock_server(started())) -> mock_server(stopped()).
stop(Mock_server) ->
    {Port@1, Handle@1, Adapter@1} = case Mock_server of
        {mock_server_started, Port, Handle, Adapter} -> {Port, Handle, Adapter};
        _assert_fail ->
            erlang:error(#{gleam_error => let_assert,
                        message => <<"Pattern match failed, no pattern matched the value."/utf8>>,
                        file => <<?FILEPATH/utf8>>,
                        module => <<"http_server_mock/internal/server"/utf8>>,
                        function => <<"stop"/utf8>>,
                        line => 56,
                        value => _assert_fail,
                        start => 1704,
                        'end' => 1769,
                        pattern_start => 1715,
                        pattern_end => 1755})
    end,
    (erlang:element(3, Adapter@1))(Handle@1),
    {mock_server_stopped, Port@1}.

-file("src/http_server_mock/internal/server.gleam", 61).
?DOC(false).
-spec register(mock_server(started()), http_server_mock@types:stub()) -> {ok,
        http_server_mock@types:stub()} |
    {error, binary()}.
register(Mock_server, Stub) ->
    {Handle@1, Adapter@1} = case Mock_server of
        {mock_server_started, _, Handle, Adapter} -> {Handle, Adapter};
        _assert_fail ->
            erlang:error(#{gleam_error => let_assert,
                        message => <<"Pattern match failed, no pattern matched the value."/utf8>>,
                        file => <<?FILEPATH/utf8>>,
                        module => <<"http_server_mock/internal/server"/utf8>>,
                        function => <<"register"/utf8>>,
                        line => 65,
                        value => _assert_fail,
                        start => 1919,
                        'end' => 1981,
                        pattern_start => 1930,
                        pattern_end => 1967})
    end,
    Stub_json = http_server_mock@internal@json_codec:encode_stub(Stub),
    case (erlang:element(4, Adapter@1))(Handle@1, Stub_json) of
        {ok, _} ->
            {ok, Stub};

        {error, Reason} ->
            {error, Reason}
    end.

-file("src/http_server_mock/internal/server.gleam", 73).
?DOC(false).
-spec remove_stub(mock_server(started()), binary()) -> nil.
remove_stub(Mock_server, Id) ->
    {Handle@1, Adapter@1} = case Mock_server of
        {mock_server_started, _, Handle, Adapter} -> {Handle, Adapter};
        _assert_fail ->
            erlang:error(#{gleam_error => let_assert,
                        message => <<"Pattern match failed, no pattern matched the value."/utf8>>,
                        file => <<?FILEPATH/utf8>>,
                        module => <<"http_server_mock/internal/server"/utf8>>,
                        function => <<"remove_stub"/utf8>>,
                        line => 74,
                        value => _assert_fail,
                        start => 2214,
                        'end' => 2276,
                        pattern_start => 2225,
                        pattern_end => 2262})
    end,
    (erlang:element(5, Adapter@1))(Handle@1, Id).

-file("src/http_server_mock/internal/server.gleam", 78).
?DOC(false).
-spec reset_stubs(mock_server(started())) -> nil.
reset_stubs(Mock_server) ->
    {Handle@1, Adapter@1} = case Mock_server of
        {mock_server_started, _, Handle, Adapter} -> {Handle, Adapter};
        _assert_fail ->
            erlang:error(#{gleam_error => let_assert,
                        message => <<"Pattern match failed, no pattern matched the value."/utf8>>,
                        file => <<?FILEPATH/utf8>>,
                        module => <<"http_server_mock/internal/server"/utf8>>,
                        function => <<"reset_stubs"/utf8>>,
                        line => 79,
                        value => _assert_fail,
                        start => 2378,
                        'end' => 2440,
                        pattern_start => 2389,
                        pattern_end => 2426})
    end,
    (erlang:element(6, Adapter@1))(Handle@1).

-file("src/http_server_mock/internal/server.gleam", 83).
?DOC(false).
-spec get_stubs(mock_server(started())) -> {ok,
        list(http_server_mock@types:stub())} |
    {error, binary()}.
get_stubs(Mock_server) ->
    {Handle@1, Adapter@1} = case Mock_server of
        {mock_server_started, _, Handle, Adapter} -> {Handle, Adapter};
        _assert_fail ->
            erlang:error(#{gleam_error => let_assert,
                        message => <<"Pattern match failed, no pattern matched the value."/utf8>>,
                        file => <<?FILEPATH/utf8>>,
                        module => <<"http_server_mock/internal/server"/utf8>>,
                        function => <<"get_stubs"/utf8>>,
                        line => 86,
                        value => _assert_fail,
                        start => 2564,
                        'end' => 2626,
                        pattern_start => 2575,
                        pattern_end => 2612})
    end,
    _pipe = (erlang:element(7, Adapter@1))(Handle@1),
    http_server_mock@internal@json_codec:decode_stubs(_pipe).

-file("src/http_server_mock/internal/server.gleam", 91).
?DOC(false).
-spec recorded_requests(mock_server(started())) -> {ok,
        list(http_server_mock@types:recorded_request())} |
    {error, binary()}.
recorded_requests(Mock_server) ->
    {Handle@1, Adapter@1} = case Mock_server of
        {mock_server_started, _, Handle, Adapter} -> {Handle, Adapter};
        _assert_fail ->
            erlang:error(#{gleam_error => let_assert,
                        message => <<"Pattern match failed, no pattern matched the value."/utf8>>,
                        file => <<?FILEPATH/utf8>>,
                        module => <<"http_server_mock/internal/server"/utf8>>,
                        function => <<"recorded_requests"/utf8>>,
                        line => 94,
                        value => _assert_fail,
                        start => 2796,
                        'end' => 2858,
                        pattern_start => 2807,
                        pattern_end => 2844})
    end,
    _pipe = Handle@1,
    _pipe@1 = (erlang:element(8, Adapter@1))(_pipe),
    http_server_mock@internal@json_codec:decode_recorded_requests(_pipe@1).

-file("src/http_server_mock/internal/server.gleam", 100).
?DOC(false).
-spec reset_requests(mock_server(started())) -> nil.
reset_requests(Mock_server) ->
    {Handle@1, Adapter@1} = case Mock_server of
        {mock_server_started, _, Handle, Adapter} -> {Handle, Adapter};
        _assert_fail ->
            erlang:error(#{gleam_error => let_assert,
                        message => <<"Pattern match failed, no pattern matched the value."/utf8>>,
                        file => <<?FILEPATH/utf8>>,
                        module => <<"http_server_mock/internal/server"/utf8>>,
                        function => <<"reset_requests"/utf8>>,
                        line => 101,
                        value => _assert_fail,
                        start => 3005,
                        'end' => 3067,
                        pattern_start => 3016,
                        pattern_end => 3053})
    end,
    (erlang:element(9, Adapter@1))(Handle@1).

-file("src/http_server_mock/internal/server.gleam", 105).
?DOC(false).
-spec reset(mock_server(started())) -> nil.
reset(Mock_server) ->
    {Handle@1, Adapter@1} = case Mock_server of
        {mock_server_started, _, Handle, Adapter} -> {Handle, Adapter};
        _assert_fail ->
            erlang:error(#{gleam_error => let_assert,
                        message => <<"Pattern match failed, no pattern matched the value."/utf8>>,
                        file => <<?FILEPATH/utf8>>,
                        module => <<"http_server_mock/internal/server"/utf8>>,
                        function => <<"reset"/utf8>>,
                        line => 106,
                        value => _assert_fail,
                        start => 3162,
                        'end' => 3224,
                        pattern_start => 3173,
                        pattern_end => 3210})
    end,
    (erlang:element(6, Adapter@1))(Handle@1),
    (erlang:element(9, Adapter@1))(Handle@1).
