//// Start a mock HTTP server, describe how it should respond to incoming
//// requests with plain Gleam functions, make real HTTP calls against it from
//// your tests, then inspect what it received.
////
//// Pass a runtime adapter from `http_server_mock_erlang` or
//// `http_server_mock_js` to `new/1` to select the underlying server
//// implementation.
////
//// ```gleam
//// import gleam/http
//// import gleam/http/request
//// import gleam/http/response
//// import gleam/list
//// import http_server_mock
//// import http_server_mock_erlang
////
//// pub fn my_test() {
////   use server <- http_server_mock.with_handler(
////     http_server_mock.new(http_server_mock_erlang.server()),
////     fn(req) {
////       case req.method, request.path_segments(req) {
////         http.Get, ["greet"] ->
////           response.new(200) |> response.set_body("hello") |> Ok
////         _ -> Error(http_server_mock.UnexpectedRequest(req))
////       }
////     },
////   )
////
////   let url = http_server_mock.base_url(server) <> "/greet"
////   // ... make a real HTTP call against `url` ...
////
////   assert list.length(http_server_mock.received(server)) == 1
//// }
//// ```

import gleam/http/request.{type Request}
import gleam/http/response.{type Response}
import http_server_mock/internal/router
import http_server_mock/internal/server
import http_server_mock/internal/server_adapter

/// Re-exported for use in type annotations by runtime packages and users.
/// Constructed by a runtime package (e.g. `http_server_mock_erlang.server()`)
/// and passed to `new`.
pub type ServerAdapter =
  server_adapter.ServerAdapter

/// An opaque handle to a running mock server. Only meaningful while the
/// server is running: once `stop` has been called (or the `use` scope that
/// started it has returned), don't use the value again.
pub type MockServer =
  server.MockServer

/// A single routing rule: `matches` decides whether it applies to an
/// incoming request, and it's paired with a fixed `Response(String)` to send
/// back when it does. `matches` is an ordinary Gleam function written with
/// `case`/pattern matching over `gleam/http/request` helpers.
pub type Stub =
  router.Stub

/// Wrapped in `Error` and returned by a `with_handler` handler when it had no case
/// for the incoming request.
pub type UnexpectedRequest {
  UnexpectedRequest(request: Request(String))
}

/// Configuration for a mock server, built with `new` and `with_port`.
pub opaque type Config {
  Config(port: Int, adapter: ServerAdapter)
}

/// Creates a default configuration using the given runtime adapter, e.g.
/// `http_server_mock_erlang.server()`.
///
/// The server binds to a free port chosen by the operating system unless
/// overridden with `with_port`. This is the default so that concurrent
/// tests never clash over a port.
pub fn new(adapter: ServerAdapter) -> Config {
  Config(port: 0, adapter: adapter)
}

/// Overrides the port the server will bind to. Prefer the default in tests.
pub fn with_port(config: Config, port: Int) -> Config {
  Config(..config, port: port)
}

/// Creates a stub: `matches` decides whether it applies to a request,
/// `response` is what to send back when it does.
///
/// A stub's response is a fixed value, not computed from the request: the
/// test that builds the stub already controls every value that ends up in
/// the request it's matching, so it already has everything it needs to
/// build the response too. Different responses for different inputs are
/// different stubs with narrower `matches` predicates, not one stub
/// branching internally.
///
/// When more than one registered stub matches the same request, the one
/// registered first wins.
pub fn stub(
  matches: fn(Request(String)) -> Bool,
  response: Response(String),
) -> Stub {
  router.Stub(handle: fn(request) {
    case matches(request) {
      True -> Ok(response)
      False -> Error(Nil)
    }
  })
}

/// Starts a server whose behaviour is entirely described by `handler`.
/// `callback` receives the running server and is everything that runs while
/// it's up - with the `use` syntax below, that's the rest of the enclosing
/// function. The server is only stopped once `callback` returns, right
/// before this function hands back its result:
///
/// ```gleam
/// pub fn my_test() {
///   use server <- http_server_mock.with_handler(config, fn(req) {
///     case req.method, request.path_segments(req) {
///       http.Get, ["greet"] -> response.new(200) |> response.set_body("hi") |> Ok
///       _ -> Error(http_server_mock.UnexpectedRequest(req))
///     }
///   })
///
///   // Everything from here to the end of this function is `callback` - the
///   // server is running for all of it, so this is where you make requests
///   // and assert on the results.
///   let response = my_http_client.get(http_server_mock.base_url(server) <> "/greet")
///   assert response.body == "hi"
///
///   // The server stops right here, as this function returns - not before.
/// }
/// ```
pub fn with_handler(
  config: Config,
  handler: fn(Request(String)) -> Result(Response(String), UnexpectedRequest),
  callback: fn(MockServer) -> a,
) -> a {
  let catch_all =
    router.Stub(handle: fn(request) {
      case handler(request) {
        Ok(response) -> Ok(response)
        Error(UnexpectedRequest(_)) -> Error(Nil)
      }
    })
  with_stubs(config, [catch_all], callback)
}

/// Starts a server with a fixed initial stub list. `callback` receives the
/// running server and is everything that runs while it's up - with the
/// `use` syntax below, that's the rest of the enclosing function. The
/// server is only stopped once `callback` returns, right before this
/// function hands back its result:
///
/// ```gleam
/// pub fn my_test() {
///   let ping =
///     http_server_mock.stub(
///       fn(req) { req.path == "/ping" },
///       response.new(200) |> response.set_body("pong"),
///     )
///   use server <- http_server_mock.with_stubs(config, [ping])
///
///   // Everything from here to the end of this function is `callback` - the
///   // server is running for all of it, so this is where you make requests
///   // and assert on the results.
///   let response = my_http_client.get(http_server_mock.base_url(server) <> "/ping")
///   assert response.body == "pong"
///
///   // The server stops right here, as this function returns - not before.
/// }
/// ```
pub fn with_stubs(
  config: Config,
  stubs: List(Stub),
  callback: fn(MockServer) -> a,
) -> a {
  case start_with_stubs(config, stubs) {
    Error(reason) -> panic as { "Failed to start mock server: " <> reason }
    Ok(mock_server) -> {
      let result = callback(mock_server)
      stop(mock_server)
      result
    }
  }
}

/// Starts a server with no initial stubs. Prefer `with_stubs`/`with_handler` unless
/// your test can't be structured as a `use` block (for example, `gleeunit`
/// setup/teardown pairs). You are responsible for calling `stop` yourself.
pub fn start(config: Config) -> Result(MockServer, String) {
  start_with_stubs(config, [])
}

/// Like `start`, but with an initial stub list.
pub fn start_with_stubs(
  config: Config,
  stubs: List(Stub),
) -> Result(MockServer, String) {
  server.start(config.adapter, config.port, stubs)
}

/// Stops the mock server and releases the port it was bound to.
///
/// If the code running inside a `with_handler`/`with_stubs` block panics before
/// returning, `stop` is not guaranteed to run. The server process is only
/// cleaned up when the test runner process exits.
pub fn stop(mock_server: MockServer) -> Nil {
  server.stop(mock_server)
}

/// Registers an additional stub with a running server.
pub fn add_stub(mock_server: MockServer, stub: Stub) -> Result(Nil, String) {
  server.add_stub(mock_server, stub)
}

/// Removes a specific stub from a running server. Pass the exact `Stub`
/// value you originally registered (the one returned by `stub`) - not a
/// freshly-built stub with equivalent-looking logic, since two
/// separately-created stubs are never considered equal even if they behave
/// the same. Has no effect if that stub isn't currently registered.
pub fn remove_stub(mock_server: MockServer, stub: Stub) -> Nil {
  server.remove_stub(mock_server, stub)
}

/// Removes all registered stubs. Requests made after this call return 404
/// until new stubs are registered.
pub fn reset_stubs(mock_server: MockServer) -> Nil {
  server.reset_stubs(mock_server)
}

/// Clears the server's recorded request history.
pub fn reset_requests(mock_server: MockServer) -> Nil {
  server.reset_requests(mock_server)
}

/// Removes all stubs and clears the recorded request history in one call.
pub fn reset(mock_server: MockServer) -> Nil {
  server.reset_stubs(mock_server)
  server.reset_requests(mock_server)
}

/// Returns the base URL of the running server, e.g. `"http://localhost:54321"`.
pub fn base_url(mock_server: MockServer) -> String {
  server.base_url(mock_server)
}

/// Returns every request the server has received since it started (or since
/// the last `reset_requests`/`reset`), in the order they arrived.
///
/// Write your own assertions against the result, e.g.
/// `assert list.length(http_server_mock.received(server)) == 1`.
pub fn received(mock_server: MockServer) -> List(Request(String)) {
  server.received(mock_server)
}

/// Returns every request the server received that did not match any stub (or
/// that a `with_handler` handler had no case for). Useful for diagnosing why an
/// expected response never came back: if a request you expected to be
/// handled shows up here, check your `matches`/handler logic.
pub fn unmatched_requests(mock_server: MockServer) -> List(Request(String)) {
  server.unmatched_requests(mock_server)
}

/// Returns every request that matched the given stub, in the order they
/// arrived. Pass the exact `Stub` value you registered, the same one
/// `remove_stub` expects - a freshly-built stub with equivalent-looking
/// logic is never considered equal to it, even if it behaves the same.
///
/// This saves re-writing a stub's `matches` predicate a second time in the
/// test body just to filter `received`:
///
/// ```gleam
/// let ping = http_server_mock.stub(fn(req) { req.path == "/ping" }, response.new(200))
/// use server <- http_server_mock.with_stubs(config, [ping])
/// // ...
/// assert list.length(http_server_mock.received_by(server, ping)) == 1
/// ```
pub fn received_by(
  mock_server: MockServer,
  stub: Stub,
) -> List(Request(String)) {
  server.received_by(mock_server, stub)
}
