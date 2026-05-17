//// Start a mock HTTP server, register stubs that describe how it should respond
//// to incoming requests, make real HTTP calls against it from your tests, then
//// inspect the recorded call history to verify what happened.
////
//// ```gleam
//// import gleam/http
//// import http_server_mock
//// import http_server_mock/matcher
//// import http_server_mock/response
//// import http_server_mock/stub
//// import http_server_mock/verify
////
//// pub fn my_test() {
////   let server =
////     http_server_mock.new()
////     |> http_server_mock.start()
////     |> http_server_mock.with_stub(
////       matcher.new() |> matcher.method(http.Get) |> matcher.path("/ping"),
////       response.ok(),
////     )
////
////   // ... make HTTP requests to http_server_mock.base_url(server) ...
////
////   verify.called_times(server, matcher.new() |> matcher.path("/ping"), 1)
////   http_server_mock.stop(server)
//// }
//// ```

import gleam/list
import gleam/option
import http_server_mock/internal/server.{type MockServer}
import http_server_mock/types.{type RecordedRequest, type Stub}

/// Phantom type re-exported for use in type annotations.
/// A `MockServer(NotStarted)` has been configured but not yet started.
pub type NotStarted =
  server.NotStarted

/// Phantom type re-exported for use in type annotations.
/// A `MockServer(Started)` is running and ready to accept requests.
pub type Started =
  server.Started

/// Phantom type re-exported for use in type annotations.
/// A `MockServer(Stopped)` has been shut down and cannot accept requests.
pub type Stopped =
  server.Stopped

/// Creates a new server with default configuration (random free port).
///
/// Chain `with_port` to override the port, then call `start` to launch.
///
/// ```gleam
/// let server =
///   http_server_mock.new()
///   |> http_server_mock.start()
/// ```
pub fn new() -> MockServer(NotStarted) {
  server.new()
}

/// Overrides the port the server will bind to when started.
///
/// Prefer the default (port 0) in tests so servers never conflict with each
/// other or with other processes on the machine.
pub fn with_port(
  mock_server: MockServer(NotStarted),
  port: Int,
) -> MockServer(NotStarted) {
  server.with_port(mock_server, port)
}

/// Starts the mock HTTP server.
///
/// Panics if the server could not be started (for example, if the requested
/// port is already in use).
///
/// Call `stop` when the server is no longer needed.
pub fn start(mock_server: MockServer(NotStarted)) -> MockServer(Started) {
  case server.start(mock_server) {
    Ok(started) -> started
    Error(reason) -> panic as { "Failed to start mock server: " <> reason }
  }
}

/// Stops the mock server and releases the port it was bound to.
///
/// The returned `MockServer(Stopped)` cannot be passed to any function that
/// requires a running server, making accidental post-stop use a compile error.
pub fn stop(mock_server: MockServer(Started)) -> MockServer(Stopped) {
  server.stop(mock_server)
}

/// Returns the base URL of the mock server, e.g. `"http://localhost:54321"`.
///
/// Append your path to this when constructing request URLs in tests.
pub fn base_url(mock_server: MockServer(Started)) -> String {
  server.base_url(mock_server)
}

/// Registers a stub with the server.
///
/// Build a `Stub` using `stub_builder.new() |> stub_builder.matching(...) |> stub_builder.responding_with(...) |> stub_builder.build()`,
/// or construct one directly from `http_server_mock/types.{Stub}`.
///
/// Returns `Ok(Nil)` on success, or `Error(reason)` if the stub could not be
/// registered.
pub fn add_stub(
  mock_server: MockServer(Started),
  stub: Stub,
) -> Result(Nil, String) {
  case server.register(mock_server, stub) {
    Ok(_) -> Ok(Nil)
    Error(reason) -> Error(reason)
  }
}

/// Registers a stub with the server and returns the server for chaining.
///
/// Build a `Stub` with `stub_builder` and pass it in:
///
/// ```gleam
/// let server =
///   http_server_mock.new()
///   |> http_server_mock.start()
///   |> http_server_mock.with_stub(
///     stub_builder.new()
///     |> stub_builder.matching(matcher.new() |> matcher.path("/ping"))
///     |> stub_builder.responding_with(response.ok())
///     |> stub_builder.build(),
///   )
/// ```
///
/// Panics on registration failure. Use `add_stub` if you need to handle the error.
pub fn with_stub(
  mock_server: MockServer(Started),
  stub: Stub,
) -> MockServer(Started) {
  case server.register(mock_server, stub) {
    Ok(_) -> mock_server
    Error(reason) -> panic as { "Failed to register stub: " <> reason }
  }
}

/// Removes the stub with the given ID from the server.
///
/// Has no effect if no stub with that ID exists.
pub fn remove_stub(mock_server: MockServer(Started), id: String) -> Nil {
  server.remove_stub(mock_server, id)
}

/// Removes all registered stubs from the server.
///
/// Requests made after this call will return 404 until new stubs are registered.
pub fn reset_stubs(mock_server: MockServer(Started)) -> Nil {
  server.reset_stubs(mock_server)
}

/// Returns all requests the server has received since it started (or since the
/// last call to `reset_requests` or `reset`).
///
/// Each `RecordedRequest` includes the method, path, query string, headers,
/// body, timestamp, and the ID of the stub that matched it (if any).
pub fn recorded_requests(
  mock_server: MockServer(Started),
) -> Result(List(RecordedRequest), String) {
  server.recorded_requests(mock_server)
}

/// Clears the server's recorded request history.
///
/// Useful when you want to assert on requests made during a specific part of a
/// test without including earlier setup requests in the count.
pub fn reset_requests(mock_server: MockServer(Started)) -> Nil {
  server.reset_requests(mock_server)
}

/// Removes all stubs and clears the recorded request history in one call.
pub fn reset(mock_server: MockServer(Started)) -> Nil {
  server.reset(mock_server)
}

/// Returns all requests the server received that did not match any registered stub.
///
/// Useful for diagnosing test failures: if a request you expected to be handled
/// shows up here, it means no stub matched it — check the matcher configuration.
///
/// Each `RecordedRequest` includes the method, path, query string, headers,
/// body, and timestamp. The `matched_stub_id` field will always be `None` for
/// these requests.
pub fn unmatched_requests(
  mock_server: MockServer(Started),
) -> Result(List(RecordedRequest), String) {
  case server.recorded_requests(mock_server) {
    Ok(requests) ->
      Ok(list.filter(requests, fn(req) { req.matched_stub_id == option.None }))
    Error(reason) -> Error(reason)
  }
}
