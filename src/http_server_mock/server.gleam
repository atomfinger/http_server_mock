import gleam/dynamic.{type Dynamic}
import gleam/int
import http_server_mock/json_codec
import http_server_mock/types.{type RecordedRequest, type Stub}

/// Phantom type indicating a `MockServer` is currently running.
/// Used as a type parameter — never instantiated directly.
pub type Started

/// Phantom type indicating a `MockServer` has been stopped.
/// Used as a type parameter — never instantiated directly.
pub type Stopped

/// An opaque handle to a mock HTTP server.
///
/// The phantom type parameter encodes the server's state:
/// - `MockServer(Started)` — the server is running and ready to accept requests.
/// - `MockServer(Stopped)` — the server has been shut down.
///
/// Functions that interact with the server require `MockServer(Started)`,
/// so passing a stopped server is a compile-time error.
pub opaque type MockServer(state) {
  MockServer(port: Int, handle: Dynamic)
}

pub fn port(mock_server: MockServer(Started)) -> Int {
  mock_server.port
}

pub fn base_url(mock_server: MockServer(Started)) -> String {
  "http://localhost:" <> int.to_string(mock_server.port)
}

pub fn start(port_number: Int) -> Result(MockServer(Started), String) {
  case do_start(port_number) {
    Ok(#(actual_port, handle)) -> Ok(MockServer(actual_port, handle))
    Error(error_message) -> Error(error_message)
  }
}

pub fn stop(mock_server: MockServer(Started)) -> MockServer(Stopped) {
  do_stop(mock_server.handle)
  MockServer(mock_server.port, mock_server.handle)
}

pub fn register(
  mock_server: MockServer(Started),
  stub: Stub,
) -> Result(Stub, String) {
  let stub_json = json_codec.encode_stub(stub)
  case do_add_stub(mock_server.handle, stub_json) {
    Ok(_) -> Ok(stub)
    Error(error_message) -> Error(error_message)
  }
}

pub fn remove_stub(mock_server: MockServer(Started), id: String) -> Nil {
  do_remove_stub(mock_server.handle, id)
}

pub fn reset_stubs(mock_server: MockServer(Started)) -> Nil {
  do_clear_stubs(mock_server.handle)
}

pub fn get_stubs(mock_server: MockServer(Started)) -> Result(List(Stub), String) {
  do_get_stubs(mock_server.handle)
  |> json_codec.decode_stubs
}

pub fn recorded_requests(
  mock_server: MockServer(Started),
) -> Result(List(RecordedRequest), String) {
  mock_server.handle
  |> do_get_requests
  |> json_codec.decode_recorded_requests
}

pub fn reset_requests(mock_server: MockServer(Started)) -> Nil {
  do_clear_requests(mock_server.handle)
}

pub fn reset(mock_server: MockServer(Started)) -> Nil {
  do_clear_stubs(mock_server.handle)
  do_clear_requests(mock_server.handle)
}

@external(erlang, "http_server_mock@server_impl", "start_server")
@external(javascript, "./server_ffi.mjs", "startServer")
fn do_start(port: Int) -> Result(#(Int, Dynamic), String)

@external(erlang, "http_server_mock@server_impl", "stop_server")
@external(javascript, "./server_ffi.mjs", "stopServer")
fn do_stop(handle: Dynamic) -> Nil

@external(erlang, "http_server_mock@server_impl", "add_stub")
@external(javascript, "./server_ffi.mjs", "addStub")
fn do_add_stub(handle: Dynamic, stub_json: String) -> Result(String, String)

@external(erlang, "http_server_mock@server_impl", "remove_stub")
@external(javascript, "./server_ffi.mjs", "removeStub")
fn do_remove_stub(handle: Dynamic, id: String) -> Nil

@external(erlang, "http_server_mock@server_impl", "clear_stubs")
@external(javascript, "./server_ffi.mjs", "clearStubs")
fn do_clear_stubs(handle: Dynamic) -> Nil

@external(erlang, "http_server_mock@server_impl", "get_stubs")
@external(javascript, "./server_ffi.mjs", "getStubs")
fn do_get_stubs(handle: Dynamic) -> String

@external(erlang, "http_server_mock@server_impl", "get_requests")
@external(javascript, "./server_ffi.mjs", "getRequests")
fn do_get_requests(handle: Dynamic) -> String

@external(erlang, "http_server_mock@server_impl", "clear_requests")
@external(javascript, "./server_ffi.mjs", "clearRequests")
fn do_clear_requests(handle: Dynamic) -> Nil
