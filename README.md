# http_server_mock

[![Package Version](https://img.shields.io/hexpm/v/http_server_mock)](https://hex.pm/packages/http_server_mock)
[![Hex Docs](https://img.shields.io/badge/hex-docs-ffaff3)](https://hexdocs.pm/http_server_mock/)

A WireMock-style HTTP mock server for Gleam integration tests. Start a real
HTTP server in your test, tell it what to respond to, make requests against it,
and verify what was called — on both Erlang and JavaScript targets.

```sh
gleam add --dev http_server_mock
```

## Quick start

```gleam
pub fn weather_api_test() {
  let assert Ok(server) = http_server_mock.start(http_server_mock.default_config())

  // Describe what to match and what to respond with.
  let get_weather =
    matcher.new()
    |> matcher.method(http.Get)
    |> matcher.path("/weather")
    |> matcher.query_param("city", "Oslo")

  let assert Ok(_) =
    http_server_mock.register(
      server,
      stub.new(
        get_weather,
        response.new()
          |> response.status(200)
          |> response.json_body("{\"temp\": 12, \"unit\": \"C\"}"),
      ),
    )

  // Point your code under test at the mock server.
  let base_url = http_server_mock.base_url(server)
  let result = my_weather_client.fetch(base_url, "Oslo")

  // Assert the response and verify the call was made exactly once.
  let assert Ok(weather) = result
  let assert 12 = weather.temp

  let assert Ok(requests) = http_server_mock.recorded_requests(server)
  verify.called_times(requests, get_weather, 1)

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
let assert Ok(requests) = http_server_mock.recorded_requests(server)

// Must have been called exactly once
verify.called_times(requests, my_matcher, 1)

// Must have been called at least twice
verify.called_at_least(requests, my_matcher, 2)

// Must never have been called
verify.never_called(requests, my_matcher)
```

All `verify` functions panic with a human-readable message on failure, listing
the matcher, the expected count, and every request the server actually received.

### Stateful sequences with scenarios

When you need the same endpoint to return different responses on successive
calls — for example to simulate a job that starts processing and then
completes — use scenarios.

```gleam
let poll = matcher.new() |> matcher.method(http.Get) |> matcher.path("/job/1")

// First call: job is still running, transition to "done".
let assert Ok(_) =
  http_server_mock.register(
    server,
    stub.new(poll, response.new() |> response.body("running"))
      |> stub.in_scenario("job-1")
      |> stub.then_transition_to("done"),
  )

// Second call (once state is "done"): job is complete.
let assert Ok(_) =
  http_server_mock.register(
    server,
    stub.new(poll, response.new() |> response.body("complete"))
      |> stub.in_scenario("job-1")
      |> stub.when_state_is("done"),
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
- **Port 0.** `default_config()` binds to a random free port, so multiple
  servers can run concurrently without conflicts.
- **Admin API.** A built-in `/__admin/` HTTP interface lets you manage stubs
  and inspect requests over HTTP if you prefer that to the Gleam API.

## Development

```sh
gleam test                        # Erlang target
gleam test --target javascript    # JavaScript target
```
