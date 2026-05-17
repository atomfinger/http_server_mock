//// The main entry point for `http_server_mock`.
////
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
////   let assert Ok(server) = http_server_mock.start(http_server_mock.default_config())
////
////   let m = matcher.new() |> matcher.method(http.Get) |> matcher.path("/ping")
////   let assert Ok(_) = http_server_mock.register(server, stub.new(m, response.ok()))
////
////   // ... make HTTP requests to http_server_mock.base_url(server) ...
////
////   let assert Ok(requests) = http_server_mock.recorded_requests(server)
////   verify.called_times(requests, m, 1)
////   http_server_mock.stop(server)
//// }
//// ```

import gleam/list
import http_server_mock/playback
import http_server_mock/server.{type MockServer}
import http_server_mock/types.{type RecordedRequest, type Stub}

/// Phantom type re-exported for use in type annotations.
/// A `MockServer(Started)` is running and ready to accept requests.
pub type Started =
  server.Started

/// Phantom type re-exported for use in type annotations.
/// A `MockServer(Stopped)` has been shut down and cannot accept requests.
pub type Stopped =
  server.Stopped

/// Configuration for a mock server.
pub type Config {
  Config(port: Int)
}

/// Returns a default configuration that binds to a random free port.
///
/// Use this in tests so servers never conflict with each other or with other
/// processes on the machine.
pub fn default_config() -> Config {
  Config(port: 0)
}

/// Returns a configuration that binds to the given port number.
///
/// Prefer `default_config` in tests; use this only when you need a fixed port,
/// for example to match a URL hardcoded in external configuration.
pub fn with_port(_config: Config, port: Int) -> Config {
  Config(port: port)
}

/// Starts a mock HTTP server with the given configuration.
///
/// Returns `Ok(MockServer(Started))` on success or `Error(reason)` if the
/// server could not be started (for example, if the requested port is already
/// in use).
///
/// Call `stop` when the server is no longer needed.
pub fn start(config: Config) -> Result(MockServer(Started), String) {
  server.start(config.port)
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
/// When an incoming request matches the stub's `RequestMatcher`, the server
/// responds with the stub's `ResponseDefinition`. If multiple stubs match, the
/// one with the lowest priority value wins; ties are broken by specificity score.
///
/// Returns `Ok(stub)` on success, or `Error(reason)` if the stub could not be
/// registered.
pub fn register(
  mock_server: MockServer(Started),
  stub: Stub,
) -> Result(Stub, String) {
  server.register(mock_server, stub)
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

/// Loads stubs from a JSON file and registers them with the server.
///
/// The file must contain a JSON array of stub objects in the same format
/// produced by `http_server_mock/playback.save_stubs`.
///
/// Returns `Ok(Nil)` if all stubs were loaded and registered successfully, or
/// `Error(reason)` on the first failure.
pub fn load_stubs_from_file(
  mock_server: MockServer(Started),
  path: String,
) -> Result(Nil, String) {
  case playback.load_stubs(path) {
    Error(error_message) -> Error(error_message)
    Ok(stubs) -> {
      let errors =
        list.filter_map(stubs, fn(stub) {
          case server.register(mock_server, stub) {
            Ok(_) -> Error(Nil)
            Error(error_message) -> Ok(error_message)
          }
        })
      case errors {
        [] -> Ok(Nil)
        [first_error, ..] -> Error(first_error)
      }
    }
  }
}
