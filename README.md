# http_server_mock

[![Package Version](https://img.shields.io/hexpm/v/http_server_mock)](https://hex.pm/packages/http_server_mock)
[![Hex Docs](https://img.shields.io/badge/hex-docs-ffaff3)](https://hexdocs.pm/http_server_mock/)

A WireMock-style HTTP mock server for Gleam integration tests. Start a real
HTTP server in your test, tell it what to respond to, make requests against it,
and verify what was called — on both Erlang and JavaScript targets.

## Monorepo structure

This repository contains three Gleam packages:

| Folder | Hex package | Purpose |
|---|---|---|
| [`http_server_mock_core/`](./http_server_mock_core/) | `http_server_mock` | Core API: types, matchers, response builders, stub builder, verify helpers |
| [`http_server_mock_erlang/`](./http_server_mock_erlang/) | `http_server_mock_erlang` | Erlang/OTP runtime (OTP actor + mist HTTP server) |
| [`http_server_mock_js/`](./http_server_mock_js/) | `http_server_mock_js` | JavaScript/Node.js runtime (Worker thread HTTP server) |

## Installation

Add **both** the core package and your runtime package:

### Erlang target
```sh
gleam add --dev http_server_mock http_server_mock_erlang
```

### JavaScript target
```sh
gleam add --dev http_server_mock http_server_mock_js
```

## Quick start

```gleam
import gleam/http
import http_server_mock
import http_server_mock_erlang  // or http_server_mock_js for the JS target
import http_server_mock/matcher
import http_server_mock/response
import http_server_mock/stub_builder
import http_server_mock/verify

pub fn weather_api_test() {
  let weather_matcher =
    matcher.new()
    |> matcher.method(http.Get)
    |> matcher.path("/weather")
    |> matcher.query_param("city", "Oslo")

  let response = 
    response.new()
    |> response.status(200)
    |> response.json_body("{\"temp\": 12, \"unit\": \"C\"}")

  let stub =
    stub_builder.new()
    |> stub_builder.matching(weather_matcher)
    |> stub_builder.responding_with(response)
    |> stub_builder.build()

  let server =
    http_server_mock.new(http_server_mock_erlang.server())
    |> http_server_mock.start()
    |> http_server_mock.with_stub(stub)

  // Point your code under test at the mock server.
  let base_url = http_server_mock.base_url(server)
  let result = my_weather_client.fetch(base_url, "Oslo")

  // Assert the response and verify the call was made exactly once.
  let assert Ok(weather) = result
  assert weather.temp == 12

  verify.called_times(server, weather_matcher, 1)

  http_server_mock.stop(server)
}
```

## Examples

### Matching requests

Matchers compose with `|>`. Every constraint you add must be satisfied for the
stub to fire; constraints you omit match anything.

```gleam
// Exact path
matcher.new() |> matcher.path("/users/42")

// HTTP method + path + query parameter
matcher.new()
|> matcher.method(http.Get)
|> matcher.path("/search")
|> matcher.query_param("q", "gleam")

// POST with JSON body (whitespace and key order are ignored)
matcher.new()
|> matcher.method(http.Post)
|> matcher.path("/orders")
|> matcher.body_json("{\"item\": \"book\", \"qty\": 2}")

// Header present with a specific value
matcher.new()
|> matcher.header("authorization", "Bearer secret")
```

### Building stubs

Use `stub_builder` to construct a `Stub`, then pass it to `add_stub` or
`with_stub`. The phantom-typed builder catches a missing matcher or response
at compile time.

```gleam
import http_server_mock/stub_builder

// Build and register in one pipeline
let server =
  http_server_mock.new(http_server_mock_erlang.server())
  |> http_server_mock.start()
  |> http_server_mock.with_stub(
    stub_builder.new()
    |> stub_builder.matching(matcher.new() |> matcher.path("/ping"))
    |> stub_builder.responding_with(response.ok())
    |> stub_builder.build(),
  )

// Or build separately and register with error handling
let my_stub =
  stub_builder.new()
  |> stub_builder.matching(matcher.new() |> matcher.path("/ping"))
  |> stub_builder.responding_with(response.ok())
  |> stub_builder.build()

let assert Ok(_) = http_server_mock.add_stub(server, my_stub)
```

For full control you can also construct a `Stub` directly from
`http_server_mock/types`.

### Stubbing responses

```gleam
// Plain text, custom status
response.new()
|> response.status(201)
|> response.body("created")

// JSON (sets content-type: application/json automatically)
response.new()
|> response.json_body("{\"id\": 99}")

// Simulate a slow dependency
response.new()
|> response.status(503)
|> response.delay(2000)
```

### Verifying calls

```gleam
// Must have been called exactly once
verify.called_times(server, my_matcher, 1)

// Must have been called at least twice
verify.called_at_least(server, my_matcher, 2)

// Must never have been called
verify.never_called(server, my_matcher)
```

All `verify` functions panic with a human-readable message on failure, listing
the matcher, the expected count, and every request the server actually received.

### Inspecting unmatched requests

If a request arrives that no stub covers, the server returns 404 and still
records it. Use `unmatched_requests` to see exactly what came in — useful when
a verify assertion fails and you need to understand why nothing matched.

```gleam
let assert Ok(unmatched) = http_server_mock.unmatched_requests(server)
// Each RecordedRequest has: method, path, query, headers, body, timestamp_ms
```

### Stateful sequences with scenarios

When you need the same endpoint to return different responses on successive
calls — for example to simulate a job that starts processing and then
completes — use scenarios.

```gleam
let poll = matcher.new() |> matcher.method(http.Get) |> matcher.path("/job/1")

// First call: job is still running, transition to "done".
let assert Ok(_) =
  http_server_mock.add_stub(
    server,
    stub_builder.new()
      |> stub_builder.matching(poll)
      |> stub_builder.responding_with(response.new() |> response.body("running"))
      |> stub_builder.in_scenario("job-1")
      |> stub_builder.then_transition_to("done")
      |> stub_builder.build(),
  )

// Second call (once state is "done"): job is complete.
let assert Ok(_) =
  http_server_mock.add_stub(
    server,
    stub_builder.new()
      |> stub_builder.matching(poll)
      |> stub_builder.responding_with(response.new() |> response.body("complete"))
      |> stub_builder.in_scenario("job-1")
      |> stub_builder.when_state_is("done")
      |> stub_builder.build(),
  )
```

### Resetting between test phases

```gleam
// Remove all stubs but keep request history.
http_server_mock.reset_stubs(server)

// Clear request history but keep stubs.
http_server_mock.reset_requests(server)

// Clear everything at once.
http_server_mock.reset(server)
```

## Design

- **Both targets.** The server runs as an OTP process on Erlang and as a
  Node.js Worker thread on JavaScript. The public API is identical on both.
- **Port 0.** `new()` defaults to port 0, which lets the OS assign a free port,
  so multiple servers can run concurrently without conflicts.
- **Lifecycle as types.** `MockServer` uses phantom types (`NotStarted`,
  `Started`, `Stopped`) so passing a stopped server to `add_stub`, or calling
  `start` on an already-started server, is a compile error.
- **Type-safe stub builder.** `StubBuilder` tracks whether a matcher and
  response have been set via phantom types — calling `build()` on an incomplete
  builder is a compile error.

## Development

Run tests from the relevant sub-package directory:

```sh
cd http_server_mock_core   && gleam test   # core unit tests
cd http_server_mock_erlang && gleam test   # Erlang integration tests
cd http_server_mock_js     && gleam test   # JS integration tests (target set in gleam.toml)
```
