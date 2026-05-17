import gleam/dynamic.{type Dynamic}
import http_server_mock/server_adapter.{type ServerAdapter, ServerAdapter}

/// Returns the Erlang/OTP server adapter.
///
/// Pass this to `http_server_mock.new/1` to create a mock server backed by an
/// OTP actor and a mist HTTP server:
///
/// ```gleam
/// let server =
///   http_server_mock.new(http_server_mock_erlang.server())
///   |> http_server_mock.start()
/// ```
pub fn server() -> ServerAdapter {
  ServerAdapter(
    start: do_start,
    stop: do_stop,
    add_stub: do_add_stub,
    remove_stub: do_remove_stub,
    clear_stubs: do_clear_stubs,
    get_stubs: do_get_stubs,
    get_requests: do_get_requests,
    clear_requests: do_clear_requests,
  )
}

@external(erlang, "http_server_mock@internal@server_impl", "start_server")
fn do_start(port: Int) -> Result(#(Int, Dynamic), String)

@external(erlang, "http_server_mock@internal@server_impl", "stop_server")
fn do_stop(handle: Dynamic) -> Nil

@external(erlang, "http_server_mock@internal@server_impl", "add_stub")
fn do_add_stub(handle: Dynamic, stub_json: String) -> Result(String, String)

@external(erlang, "http_server_mock@internal@server_impl", "remove_stub")
fn do_remove_stub(handle: Dynamic, id: String) -> Nil

@external(erlang, "http_server_mock@internal@server_impl", "clear_stubs")
fn do_clear_stubs(handle: Dynamic) -> Nil

@external(erlang, "http_server_mock@internal@server_impl", "get_stubs")
fn do_get_stubs(handle: Dynamic) -> String

@external(erlang, "http_server_mock@internal@server_impl", "get_requests")
fn do_get_requests(handle: Dynamic) -> String

@external(erlang, "http_server_mock@internal@server_impl", "clear_requests")
fn do_clear_requests(handle: Dynamic) -> Nil
