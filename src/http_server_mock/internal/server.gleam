import gleam/dynamic.{type Dynamic}
import gleam/int
import http_server_mock/internal/json_codec
import http_server_mock/types.{type RecordedRequest, type Stub}

/// Phantom type indicating a `MockServer` has not yet been started.
/// Used as a type parameter — never instantiated directly.
pub type NotStarted

/// Phantom type indicating a `MockServer` is currently running.
/// Used as a type parameter — never instantiated directly.
pub type Started

/// Phantom type indicating a `MockServer` has been stopped.
/// Used as a type parameter — never instantiated directly.
pub type Stopped

/// An opaque handle to a mock HTTP server.
///
/// The phantom type parameter encodes the server's state:
/// - `MockServer(NotStarted)` — configured but not yet running.
/// - `MockServer(Started)` — the server is running and ready to accept requests.
/// - `MockServer(Stopped)` — the server has been shut down.
///
/// State transitions are enforced at compile time: `start` only accepts
/// `NotStarted`, `with_stub` only accepts `Started`, and so on.
pub opaque type MockServer(state) {
  MockServerNotStarted(port: Int)
  MockServerStarted(port: Int, handle: Dynamic)
  MockServerStopped(port: Int)
}

/// Creates a new, unconfigured server that is not yet running.
///
/// Chain `with_port` to customise the port, then call `start` to launch it.
pub fn new() -> MockServer(NotStarted) {
  MockServerNotStarted(port: 0)
}

/// Overrides the port the server will bind to when started.
///
/// Pass `0` (the default) to let the OS assign a free port.
pub fn with_port(
  _mock_server: MockServer(NotStarted),
  port_number: Int,
) -> MockServer(NotStarted) {
  MockServerNotStarted(port: port_number)
}

pub fn start(
  mock_server: MockServer(NotStarted),
) -> Result(MockServer(Started), String) {
  let assert MockServerNotStarted(port) = mock_server
  case do_start(port) {
    Ok(#(actual_port, handle)) -> Ok(MockServerStarted(actual_port, handle))
    Error(error_message) -> Error(error_message)
  }
}

pub fn port(mock_server: MockServer(Started)) -> Int {
  let assert MockServerStarted(port, _) = mock_server
  port
}

pub fn base_url(mock_server: MockServer(Started)) -> String {
  let assert MockServerStarted(port, _) = mock_server
  "http://localhost:" <> int.to_string(port)
}

pub fn stop(mock_server: MockServer(Started)) -> MockServer(Stopped) {
  let assert MockServerStarted(port, handle) = mock_server
  do_stop(handle)
  MockServerStopped(port)
}

pub fn register(
  mock_server: MockServer(Started),
  stub: Stub,
) -> Result(Stub, String) {
  let assert MockServerStarted(_, handle) = mock_server
  let stub_json = json_codec.encode_stub(stub)
  case do_add_stub(handle, stub_json) {
    Ok(_) -> Ok(stub)
    Error(error_message) -> Error(error_message)
  }
}

pub fn remove_stub(mock_server: MockServer(Started), id: String) -> Nil {
  let assert MockServerStarted(_, handle) = mock_server
  do_remove_stub(handle, id)
}

pub fn reset_stubs(mock_server: MockServer(Started)) -> Nil {
  let assert MockServerStarted(_, handle) = mock_server
  do_clear_stubs(handle)
}

pub fn get_stubs(
  mock_server: MockServer(Started),
) -> Result(List(Stub), String) {
  let assert MockServerStarted(_, handle) = mock_server
  do_get_stubs(handle)
  |> json_codec.decode_stubs
}

pub fn recorded_requests(
  mock_server: MockServer(Started),
) -> Result(List(RecordedRequest), String) {
  let assert MockServerStarted(_, handle) = mock_server
  handle
  |> do_get_requests
  |> json_codec.decode_recorded_requests
}

pub fn reset_requests(mock_server: MockServer(Started)) -> Nil {
  let assert MockServerStarted(_, handle) = mock_server
  do_clear_requests(handle)
}

pub fn reset(mock_server: MockServer(Started)) -> Nil {
  let assert MockServerStarted(_, handle) = mock_server
  do_clear_stubs(handle)
  do_clear_requests(handle)
}

@external(erlang, "http_server_mock@internal@server_impl", "start_server")
@external(javascript, "./server_ffi.mjs", "startServer")
fn do_start(port: Int) -> Result(#(Int, Dynamic), String)

@external(erlang, "http_server_mock@internal@server_impl", "stop_server")
@external(javascript, "./server_ffi.mjs", "stopServer")
fn do_stop(handle: Dynamic) -> Nil

@external(erlang, "http_server_mock@internal@server_impl", "add_stub")
@external(javascript, "./server_ffi.mjs", "addStub")
fn do_add_stub(handle: Dynamic, stub_json: String) -> Result(String, String)

@external(erlang, "http_server_mock@internal@server_impl", "remove_stub")
@external(javascript, "./server_ffi.mjs", "removeStub")
fn do_remove_stub(handle: Dynamic, id: String) -> Nil

@external(erlang, "http_server_mock@internal@server_impl", "clear_stubs")
@external(javascript, "./server_ffi.mjs", "clearStubs")
fn do_clear_stubs(handle: Dynamic) -> Nil

@external(erlang, "http_server_mock@internal@server_impl", "get_stubs")
@external(javascript, "./server_ffi.mjs", "getStubs")
fn do_get_stubs(handle: Dynamic) -> String

@external(erlang, "http_server_mock@internal@server_impl", "get_requests")
@external(javascript, "./server_ffi.mjs", "getRequests")
fn do_get_requests(handle: Dynamic) -> String

@external(erlang, "http_server_mock@internal@server_impl", "clear_requests")
@external(javascript, "./server_ffi.mjs", "clearRequests")
fn do_clear_requests(handle: Dynamic) -> Nil
