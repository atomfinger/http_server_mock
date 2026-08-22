# http_server_mock

[![Package Version](https://img.shields.io/hexpm/v/http_server_mock)](https://hex.pm/packages/http_server_mock)
[![Hex Docs](https://img.shields.io/badge/hex-docs-ffaff3)](https://hexdocs.pm/http_server_mock/)

A WireMock-style HTTP mock server for Gleam integration tests. Start a real
HTTP server in your test, describe how it should respond with plain Gleam
functions, make requests against it, and inspect what it received.

> **2.0.0 breaking change.** The matcher/response DSL, `stub_builder`, and
> `verify` modules are gone: stubs are now plain `fn(Request) -> Bool` /
> `fn(Request) -> Response` closures over `gleam/http`, and there's a single
> public module. See the [migration guide](./migration-guide/MIGRATION.md)
> for the full 1.x → 2.0.0 walkthrough.

## Monorepo structure

This repository contains three Gleam packages:

| Folder | Hex package | Purpose |
|---|---|---|
| [`http_server_mock_core/`](./http_server_mock_core/) | `http_server_mock` | Core API: a single public module |
| [`http_server_mock_erlang/`](./http_server_mock_erlang/) | `http_server_mock_erlang` | Erlang/OTP runtime (OTP actor + mist HTTP server) |
| [`http_server_mock_js/`](./http_server_mock_js/) | `http_server_mock_js` | JavaScript/Node.js runtime (Worker thread HTTP server) |

## Installation

```sh
# Erlang target
gleam add --dev http_server_mock http_server_mock_erlang

# JavaScript target
gleam add --dev http_server_mock http_server_mock_js
```

## Quick start

```gleam
import gleam/http
import gleam/http/request
import gleam/http/response
import gleam/list
import http_server_mock
import http_server_mock_erlang

pub fn weather_api_test() {
  use server <- http_server_mock.with_handler(
    http_server_mock.new(http_server_mock_erlang.server()),
    fn(req) {
      case req.method, request.path_segments(req), request.get_query(req) {
        http.Get, ["weather"], Ok([#("city", "Oslo")]) ->
          response.new(200)
          |> response.set_body("{\"temp\": 12, \"unit\": \"C\"}")
          |> Ok
        _, _, _ -> Error(http_server_mock.UnexpectedRequest(req))
      }
    },
  )

  // Point your code under test at the mock server.
  let base_url = http_server_mock.base_url(server)
  let result = my_weather_client.fetch(base_url, "Oslo")

  let assert Ok(weather) = result
  assert weather.temp == 12
  assert list.length(http_server_mock.received(server)) == 1
  // The server stops right here, as `weather_api_test` returns - not before.
}
```

Everything after the `use` line is the callback `with_handler` runs while
the server is up: the request, the assertions, all of it. The server is
only stopped once that callback returns, so there's no explicit
`start`/`stop` bookkeeping needed for the common case.

## Building stubs

`stub` pairs a `matches` predicate with a fixed `Response(String)` to send
back, both plain Gleam using `gleam/http/request` and `gleam/http/response`
directly. `with_stubs` takes a list of them, so a test can cover several
independent routes without one big `case` expression:

```gleam
pub fn ping_and_greet_test() {
  let ping =
    http_server_mock.stub(
      fn(req) { req.method == http.Get && req.path == "/ping" },
      response.new(200) |> response.set_body("pong"),
    )
  let greet =
    http_server_mock.stub(
      fn(req) { req.method == http.Post && req.path == "/greet" },
      response.new(200) |> response.set_body("hello!"),
    )

  use server <- http_server_mock.with_stubs(config, [ping, greet])
  let base_url = http_server_mock.base_url(server)

  let ping_response = my_http_client.get(base_url <> "/ping")
  assert ping_response.body == "pong"

  let greet_response = my_http_client.post(base_url <> "/greet", "{}")
  assert greet_response.body == "hello!"
}
```

A stub's response isn't computed from the request: the test that builds it
already controls every value that ends up in whatever request it's matching,
so it already has everything it needs to build the response too. Want a
different response for a different input? Register another stub with a
narrower `matches` predicate rather than branching inside one. (The one
thing this can't do, echoing back data whose exact shape only the code
under test knows and not the test itself, like verifying an HTTP client's
own serialization round-trips correctly, is what `with_handler`'s handler
is for, since it already has to be a function of the request to do its own
routing.)

Use `with_stubs` (rather than `with_handler`) when you have more than one
route: a single `with_handler` handler is a Gleam `case` expression, which
works well for one endpoint but gets unwieldy for a handful of independent
routes with their own match logic.

`matches` is a plain function, so matching on a query parameter or the
request body is just pattern matching over the values `gleam/http/request`
already exposes:

```gleam
let search =
  http_server_mock.stub(
    fn(req) {
      case req.path, request.get_query(req) {
        "/search", Ok([#("q", "gleam")]) -> True
        _, _ -> False
      }
    },
    response.new(200) |> response.set_body("found"),
  )
```

There's no built-in way to make the same endpoint answer differently across
*successive* calls (1.x's "scenarios" feature). If you need that, model it
yourself: `add_stub`/`remove_stub` a replacement stub after the request
that should trigger the transition, or wrap state in a closure your
`matches`/response construction can read. This may come back as a built-in
feature in a later release.

When more than one registered stub matches the same request, the one
registered first wins: there's no separate priority mechanism to reach
for, just put the stub you want to win earlier in the list.

To remove a specific stub later, pass the exact `Stub` value back to
`remove_stub`:

```gleam
let ping = http_server_mock.stub(matches, response)

use server <- http_server_mock.with_stubs(config, [ping])
// ...
http_server_mock.remove_stub(server, ping)
```

## Inspecting what the server received

```gleam
let requests = http_server_mock.received(server)
assert list.length(requests) == 1

// Requests that didn't match any stub (or that a `with_handler` handler
// had no case for): useful for diagnosing why an expected response never
// came back.
let unmatched = http_server_mock.unmatched_requests(server)
```

Both return plain `List(Request(String))`: write your own `assert`s with
whatever precision and failure message you want; the library doesn't wrap
this in an assertion helper.

To check calls against one specific stub without re-writing its `matches`
predicate, pass the exact `Stub` value back to `received_by`:

```gleam
let ping = http_server_mock.stub(matches, response)

use server <- http_server_mock.with_stubs(config, [ping])
// ...
assert list.length(http_server_mock.received_by(server, ping)) == 1
```

## Resetting between test phases

```gleam
http_server_mock.reset_stubs(server)     // remove all stubs, keep request history
http_server_mock.reset_requests(server)  // clear request history, keep stubs
http_server_mock.reset(server)           // both at once
```

## Escape hatch: manual start/stop

If your test can't be structured as a `use` block (for example, `gleeunit`
setup/teardown pairs), use `start`/`start_with_stubs` and call `stop`
yourself:

```gleam
let assert Ok(server) = http_server_mock.start_with_stubs(config, [my_stub])
// ...
http_server_mock.stop(server)
```

**Known limitation:** if the code between `start` and `stop` panics, `stop`
does not run: the server process is only cleaned up when the test runner
exits. `with_stubs`/`with_handler` have the same gap for a panicking test
body; this is a documented trade-off for 2.0.0, not a regression from
`use`. See the design notes in
[`http_server_mock_erlang`](./http_server_mock_erlang/) if you're picking
this apart.

## Runtimes

| Package | Target | Underlying server |
|---|---|---|
| `http_server_mock_erlang` | Erlang/OTP | mist + OTP actor |
| `http_server_mock_js` | JavaScript | Node.js `http` in a Worker thread |

## Development

Run tests from the relevant sub-package directory:

```sh
cd http_server_mock_core   && gleam test   # core unit tests
cd http_server_mock_erlang && gleam test   # Erlang integration tests
cd http_server_mock_js     && gleam test   # JS integration tests (target = "javascript" set in gleam.toml)
```
