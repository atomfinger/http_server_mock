import * as $list from "../gleam_stdlib/gleam/list.mjs";
import * as $option from "../gleam_stdlib/gleam/option.mjs";
import { Ok, makeError } from "./gleam.mjs";
import * as $server from "./http_server_mock/internal/server.mjs";
import * as $server_adapter from "./http_server_mock/server_adapter.mjs";
import * as $types from "./http_server_mock/types.mjs";

const FILEPATH = "src/http_server_mock.gleam";

/**
 * Creates a new server with default configuration (random free port).
 *
 * Pass the adapter from your runtime package — `http_server_mock_erlang.server()`
 * or `http_server_mock_js.server()` — then chain `start` to launch.
 *
 * ```gleam
 * let server =
 *   http_server_mock.new(http_server_mock_erlang.server())
 *   |> http_server_mock.start()
 * ```
 */
export function new$(adapter) {
  return $server.new$(adapter);
}

/**
 * Overrides the port the server will bind to when started.
 *
 * Prefer the default (port 0) in tests so servers never conflict with each
 * other or with other processes on the machine.
 */
export function with_port(mock_server, port) {
  return $server.with_port(mock_server, port);
}

/**
 * Starts the mock HTTP server.
 *
 * Panics if the server could not be started (for example, if the requested
 * port is already in use).
 *
 * Call `stop` when the server is no longer needed.
 */
export function start(mock_server) {
  let $ = $server.start(mock_server);
  if ($ instanceof Ok) {
    let started = $[0];
    return started;
  } else {
    let reason = $[0];
    throw makeError(
      "panic",
      FILEPATH,
      "http_server_mock",
      94,
      "start",
      ("Failed to start mock server: " + reason),
      {}
    )
  }
}

/**
 * Stops the mock server and releases the port it was bound to.
 *
 * The returned `MockServer(Stopped)` cannot be passed to any function that
 * requires a running server, making accidental post-stop use a compile error.
 */
export function stop(mock_server) {
  return $server.stop(mock_server);
}

/**
 * Returns the base URL of the mock server, e.g. `"http://localhost:54321"`.
 *
 * Append your path to this when constructing request URLs in tests.
 */
export function base_url(mock_server) {
  return $server.base_url(mock_server);
}

/**
 * Registers a stub with the server.
 *
 * Build a `Stub` using `stub_builder.new() |> stub_builder.matching(...) |> stub_builder.responding_with(...) |> stub_builder.build()`,
 * or construct one directly from `http_server_mock/types.{Stub}`.
 *
 * Returns `Ok(Nil)` on success, or `Error(reason)` if the stub could not be
 * registered.
 */
export function add_stub(mock_server, stub) {
  let $ = $server.register(mock_server, stub);
  if ($ instanceof Ok) {
    return new Ok(undefined);
  } else {
    return $;
  }
}

/**
 * Registers a stub with the server and returns the server for chaining.
 *
 * Build a `Stub` with `stub_builder` and pass it in:
 *
 * ```gleam
 * let server =
 *   http_server_mock.new()
 *   |> http_server_mock.start()
 *   |> http_server_mock.with_stub(
 *     stub_builder.new()
 *     |> stub_builder.matching(matcher.new() |> matcher.path("/ping"))
 *     |> stub_builder.responding_with(response.ok())
 *     |> stub_builder.build(),
 *   )
 * ```
 *
 * Panics on registration failure. Use `add_stub` if you need to handle the error.
 */
export function with_stub(mock_server, stub) {
  let $ = $server.register(mock_server, stub);
  if ($ instanceof Ok) {
    return mock_server;
  } else {
    let reason = $[0];
    throw makeError(
      "panic",
      FILEPATH,
      "http_server_mock",
      153,
      "with_stub",
      ("Failed to register stub: " + reason),
      {}
    )
  }
}

/**
 * Removes the stub with the given ID from the server.
 *
 * Has no effect if no stub with that ID exists.
 */
export function remove_stub(mock_server, id) {
  return $server.remove_stub(mock_server, id);
}

/**
 * Removes all registered stubs from the server.
 *
 * Requests made after this call will return 404 until new stubs are registered.
 */
export function reset_stubs(mock_server) {
  return $server.reset_stubs(mock_server);
}

/**
 * Returns all requests the server has received since it started (or since the
 * last call to `reset_requests` or `reset`).
 *
 * Each `RecordedRequest` includes the method, path, query string, headers,
 * body, timestamp, and the ID of the stub that matched it (if any).
 */
export function recorded_requests(mock_server) {
  return $server.recorded_requests(mock_server);
}

/**
 * Clears the server's recorded request history.
 *
 * Useful when you want to assert on requests made during a specific part of a
 * test without including earlier setup requests in the count.
 */
export function reset_requests(mock_server) {
  return $server.reset_requests(mock_server);
}

/**
 * Removes all stubs and clears the recorded request history in one call.
 */
export function reset(mock_server) {
  return $server.reset(mock_server);
}

/**
 * Returns all requests the server received that did not match any registered stub.
 *
 * Useful for diagnosing test failures: if a request you expected to be handled
 * shows up here, it means no stub matched it — check the matcher configuration.
 *
 * Each `RecordedRequest` includes the method, path, query string, headers,
 * body, and timestamp. The `matched_stub_id` field will always be `None` for
 * these requests.
 */
export function unmatched_requests(mock_server) {
  let $ = $server.recorded_requests(mock_server);
  if ($ instanceof Ok) {
    let requests = $[0];
    return new Ok(
      $list.filter(
        requests,
        (req) => { return req.matched_stub_id instanceof $option.None; },
      ),
    );
  } else {
    return $;
  }
}
