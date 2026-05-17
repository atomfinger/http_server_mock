import gleam/dynamic.{type Dynamic}
import gleam/int
import http_server_mock/internal/json_codec
import http_server_mock/server_adapter.{type ServerAdapter}
import http_server_mock/types.{type RecordedRequest, type Stub}

/// Phantom type indicating a `MockServer` has not yet been started.
pub type NotStarted

/// Phantom type indicating a `MockServer` is currently running.
pub type Started

/// Phantom type indicating a `MockServer` has been stopped.
pub type Stopped

pub opaque type MockServer(state) {
  MockServerNotStarted(port: Int, adapter: ServerAdapter)
  MockServerStarted(port: Int, handle: Dynamic, adapter: ServerAdapter)
  MockServerStopped(port: Int)
}

pub fn new(adapter: ServerAdapter) -> MockServer(NotStarted) {
  MockServerNotStarted(port: 0, adapter: adapter)
}

pub fn with_port(
  mock_server: MockServer(NotStarted),
  port_number: Int,
) -> MockServer(NotStarted) {
  let assert MockServerNotStarted(_, adapter) = mock_server
  MockServerNotStarted(port: port_number, adapter: adapter)
}

pub fn start(
  mock_server: MockServer(NotStarted),
) -> Result(MockServer(Started), String) {
  let assert MockServerNotStarted(port, adapter) = mock_server
  case adapter.start(port) {
    Ok(#(actual_port, handle)) ->
      Ok(MockServerStarted(actual_port, handle, adapter))
    Error(reason) -> Error(reason)
  }
}

pub fn port(mock_server: MockServer(Started)) -> Int {
  let assert MockServerStarted(port, _, _) = mock_server
  port
}

pub fn base_url(mock_server: MockServer(Started)) -> String {
  let assert MockServerStarted(port, _, _) = mock_server
  "http://localhost:" <> int.to_string(port)
}

pub fn stop(mock_server: MockServer(Started)) -> MockServer(Stopped) {
  let assert MockServerStarted(port, handle, adapter) = mock_server
  adapter.stop(handle)
  MockServerStopped(port)
}

pub fn register(
  mock_server: MockServer(Started),
  stub: Stub,
) -> Result(Stub, String) {
  let assert MockServerStarted(_, handle, adapter) = mock_server
  let stub_json = json_codec.encode_stub(stub)
  case adapter.add_stub(handle, stub_json) {
    Ok(_) -> Ok(stub)
    Error(reason) -> Error(reason)
  }
}

pub fn remove_stub(mock_server: MockServer(Started), id: String) -> Nil {
  let assert MockServerStarted(_, handle, adapter) = mock_server
  adapter.remove_stub(handle, id)
}

pub fn reset_stubs(mock_server: MockServer(Started)) -> Nil {
  let assert MockServerStarted(_, handle, adapter) = mock_server
  adapter.clear_stubs(handle)
}

pub fn get_stubs(
  mock_server: MockServer(Started),
) -> Result(List(Stub), String) {
  let assert MockServerStarted(_, handle, adapter) = mock_server
  adapter.get_stubs(handle)
  |> json_codec.decode_stubs
}

pub fn recorded_requests(
  mock_server: MockServer(Started),
) -> Result(List(RecordedRequest), String) {
  let assert MockServerStarted(_, handle, adapter) = mock_server
  handle
  |> adapter.get_requests
  |> json_codec.decode_recorded_requests
}

pub fn reset_requests(mock_server: MockServer(Started)) -> Nil {
  let assert MockServerStarted(_, handle, adapter) = mock_server
  adapter.clear_requests(handle)
}

pub fn reset(mock_server: MockServer(Started)) -> Nil {
  let assert MockServerStarted(_, handle, adapter) = mock_server
  adapter.clear_stubs(handle)
  adapter.clear_requests(handle)
}
