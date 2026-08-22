//// The opaque `MockServer` handle: a thin wrapper pairing a runtime's
//// `Dynamic` handle with the `ServerAdapter` that knows how to drive it.
//// Every function here just forwards to the adapter - this module's only
//// job is to hide `Dynamic` and the adapter from `http_server_mock.gleam`,
//// which is the public surface these functions get re-exported through.

import gleam/dynamic.{type Dynamic}
import gleam/http/request.{type Request}
import gleam/int
import http_server_mock/internal/router.{type Stub}
import http_server_mock/internal/server_adapter.{type ServerAdapter}

pub opaque type MockServer {
  MockServer(port: Int, handle: Dynamic, adapter: ServerAdapter)
}

pub fn start(
  adapter: ServerAdapter,
  port: Int,
  stubs: List(Stub),
) -> Result(MockServer, String) {
  case adapter.start(port, stubs) {
    Ok(#(actual_port, handle)) -> Ok(MockServer(actual_port, handle, adapter))
    Error(reason) -> Error(reason)
  }
}

pub fn base_url(mock_server: MockServer) -> String {
  "http://localhost:" <> int.to_string(mock_server.port)
}

pub fn stop(mock_server: MockServer) -> Nil {
  mock_server.adapter.stop(mock_server.handle)
}

/// Always `Ok(Nil)`: registering a live closure into a runtime's own state
/// (an OTP actor's mailbox, or a plain JS object on the main thread) can't
/// fail the way registering JSON-encoded stub data over an FFI boundary
/// used to. Kept as a `Result` rather than `Nil` for symmetry with `start`,
/// in case a future adapter has a real failure mode here.
pub fn add_stub(mock_server: MockServer, stub: Stub) -> Result(Nil, String) {
  mock_server.adapter.add_stub(mock_server.handle, stub)
  Ok(Nil)
}

pub fn remove_stub(mock_server: MockServer, stub: Stub) -> Nil {
  mock_server.adapter.remove_stub(mock_server.handle, stub)
}

pub fn reset_stubs(mock_server: MockServer) -> Nil {
  mock_server.adapter.clear_stubs(mock_server.handle)
}

pub fn received(mock_server: MockServer) -> List(Request(String)) {
  mock_server.adapter.get_requests(mock_server.handle)
}

pub fn unmatched_requests(mock_server: MockServer) -> List(Request(String)) {
  mock_server.adapter.get_unmatched_requests(mock_server.handle)
}

pub fn received_by(
  mock_server: MockServer,
  stub: Stub,
) -> List(Request(String)) {
  mock_server.adapter.get_requests_by_stub(mock_server.handle, stub)
}

pub fn reset_requests(mock_server: MockServer) -> Nil {
  mock_server.adapter.clear_requests(mock_server.handle)
}

pub fn reset(mock_server: MockServer) -> Nil {
  mock_server.adapter.clear_stubs(mock_server.handle)
  mock_server.adapter.clear_requests(mock_server.handle)
}
