# http_server_mock

A WireMock-style HTTP mock server library for Gleam, running on both Erlang and JavaScript targets. Start a real HTTP server in your tests, register stubs that describe how it should respond, make real HTTP calls against it, then inspect recorded requests to verify what happened.

## Installation

Add the core package and a runtime package for your target:

**Erlang:**
```sh
gleam add http_server_mock http_server_mock_erlang
```

**JavaScript:**
```sh
gleam add http_server_mock http_server_mock_js
```

## Quick start

```gleam
import gleam/http
import http_server_mock
import http_server_mock_erlang  // or http_server_mock_js
import http_server_mock/matcher
import http_server_mock/response
import http_server_mock/stub_builder
import http_server_mock/verify

pub fn my_test() {
  let server =
    http_server_mock.new(http_server_mock_erlang.server())
    |> http_server_mock.with_stub(
      stub_builder.new()
      |> stub_builder.matching(
        matcher.new()
        |> matcher.method(http.Get)
        |> matcher.path("/greet"),
      )
      |> stub_builder.responding_with(
        response.new()
        |> response.status(200)
        |> response.body("hello"),
      )
      |> stub_builder.build(),
    )
    |> http_server_mock.start()

  // Make real HTTP calls against the server
  let url = http_server_mock.base_url(server) <> "/greet"
  // ... your HTTP client call here ...

  verify.called(server, matcher.new() |> matcher.path("/greet"))

  http_server_mock.stop(server)
}
```

## Server lifecycle

```gleam
// Create — picks a random free port by default
let server = http_server_mock.new(adapter)

// Optionally pin a port
let server = http_server_mock.new(adapter) |> http_server_mock.with_port(8080)

// Start
let server = http_server_mock.start(server)

// Get the base URL for your HTTP client
let url = http_server_mock.base_url(server)  // "http://localhost:54321"

// Stop
let server = http_server_mock.stop(server)
```

Phantom types (`NotStarted`, `Started`, `Stopped`) enforce correct usage at compile time — passing a stopped server to `add_stub` or `base_url` is a type error.

## Stubs

### Registering stubs

```gleam
// Panics on failure — use for chaining during setup
http_server_mock.with_stub(server, stub)

// Returns Result — use when you want to handle failure
http_server_mock.add_stub(server, stub)

// Remove by ID
http_server_mock.remove_stub(server, stub_id)

// Remove all
http_server_mock.reset_stubs(server)
```

### Building a stub

```gleam
stub_builder.new()
|> stub_builder.matching(request_matcher)
|> stub_builder.responding_with(response_definition)
|> stub_builder.with_id("my-stub")       // optional custom ID
|> stub_builder.with_priority(1)          // lower wins; default is 5
|> stub_builder.build()
```

## Matchers

Start with `matcher.new()` (matches everything) and add constraints:

```gleam
matcher.new()
|> matcher.method(http.Post)
|> matcher.path("/users")
|> matcher.path_contains("/users")                    // substring
|> matcher.path_matching(types.Prefix("/api/"))       // StringMatcher
|> matcher.query_param("page", types.Exactly("2"))
|> matcher.header("Authorization", types.Prefix("Bearer "))
|> matcher.body_json("{\"key\":\"value\"}")           // exact JSON body
```

## Responses

```gleam
response.new()                            // 200, no headers, no body
|> response.status(201)
|> response.body("plain text")
|> response.json_body("{\"id\":1}")       // sets Content-Type: application/json
|> response.header("X-Custom", "value")
|> response.delay(200)                    // milliseconds

response.ok()                             // shorthand for 200 with no body
```

## Verification

Verify functions assert and return the matched recorded requests, or panic with a descriptive message.

```gleam
verify.called(server, matcher)                  // at least once
verify.called_times(server, matcher, 3)         // exactly 3 times
verify.called_at_least(server, matcher, 2)      // at least 2 times
verify.never_called(server, matcher)            // zero times
```

### Inspecting recorded requests

```gleam
let assert Ok(requests) = http_server_mock.recorded_requests(server)
let assert Ok(unmatched) = http_server_mock.unmatched_requests(server)

http_server_mock.reset_requests(server)    // clear history
http_server_mock.reset(server)             // clear stubs + history
```

## Scenarios (stateful stubs)

Scenarios let you model sequences of responses from the same endpoint.

```gleam
let initial_stub =
  stub_builder.new()
  |> stub_builder.matching(matcher.new() |> matcher.path("/state"))
  |> stub_builder.responding_with(response.new() |> response.body("first"))
  |> stub_builder.in_scenario("my-scenario")
  |> stub_builder.when_state_is(types.ScenarioStarted)
  |> stub_builder.then_transition_to("second-call")
  |> stub_builder.build()

let second_stub =
  stub_builder.new()
  |> stub_builder.matching(matcher.new() |> matcher.path("/state"))
  |> stub_builder.responding_with(response.new() |> response.body("second"))
  |> stub_builder.in_scenario("my-scenario")
  |> stub_builder.when_state_is("second-call")
  |> stub_builder.build()
```

## Runtimes

| Package | Target | Underlying server |
|---|---|---|
| `http_server_mock_erlang` | Erlang/OTP | mist + OTP actor |
| `http_server_mock_js` | JavaScript | Node.js `http` module in a Worker thread |

Pass the adapter from the runtime package to `http_server_mock.new/1`:

```gleam
// Erlang
http_server_mock.new(http_server_mock_erlang.server())

// JavaScript
http_server_mock.new(http_server_mock_js.server())
```

## License

MIT
