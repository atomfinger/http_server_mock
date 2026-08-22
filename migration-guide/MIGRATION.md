# Migrating from http_server_mock 1.x to 2.0.0

2.0.0 is a breaking rewrite of the public API. There's no automated
codemod: the API shape changed too much for a mechanical find/replace,
but every 1.x concept maps onto something in 2.0.0. This guide goes through
each one with before/after code.

Background: 2.0.0 responds to [review feedback](https://github.com/gleam-lang/awesome-gleam/pull/259)
from the Gleam core team on this library's awesome-gleam submission: fewer
modules to learn, `gleam_http` types instead of a competing response type,
plain pattern matching instead of a matcher DSL, and no panicking assertions
inside library code.

## Contents

1. [Imports collapse to one module](#1-imports-collapse-to-one-module)
2. [Matchers become plain functions](#2-matchers-become-plain-functions)
3. [Responses become plain values](#3-responses-become-plain-values)
4. [Building and registering stubs](#4-building-and-registering-stubs)
5. [Server lifecycle: `use` instead of `start`/`stop`](#5-server-lifecycle-use-instead-of-startstop)
6. [`verify` is gone: assert it yourself](#6-verify-is-gone-assert-it-yourself)
7. [Recorded requests](#7-recorded-requests)
8. [Scenarios (stateful sequences) are gone](#8-scenarios-stateful-sequences-are-gone)
9. [Admin HTTP endpoints](#9-admin-http-endpoints)
10. [The `with_handler` handler (new in 2.0.0)](#10-the-with_handler-handler-new-in-200)
11. [JS runtime](#11-js-runtime)
12. [Quick reference table](#12-quick-reference-table)

---

## 1. Imports collapse to one module

1.x spread the API across five modules you had to import together:

```gleam
// 1.x
import http_server_mock
import http_server_mock_erlang
import http_server_mock/matcher
import http_server_mock/response
import http_server_mock/stub_builder
import http_server_mock/verify
```

2.0.0 has one public module in core, plus the runtime package:

```gleam
// 2.0.0
import gleam/http/request
import gleam/http/response
import http_server_mock
import http_server_mock_erlang
```

`http_server_mock/types`, `http_server_mock/matcher`, `http_server_mock/response`,
`http_server_mock/stub_builder`, and `http_server_mock/verify` no longer exist.
Everything (`Config`, `Stub`, `MockServer`, `with_handler`, `with_stubs`, `stub`,
`received`, ...) is exported directly from `http_server_mock`.

## 2. Matchers become plain functions

The `matcher` module and its `StringMatcher`/`BodyMatcher` types are gone.
A matcher is now `fn(Request(String)) -> Bool`, written with ordinary Gleam
and `gleam/http/request` helpers.

```gleam
// 1.x
matcher.new()
|> matcher.method(http.Get)
|> matcher.path("/search")
|> matcher.query_param("q", "gleam")
```

```gleam
// 2.0.0
fn(req) {
  req.method == http.Get
  && req.path == "/search"
  && request.get_query(req) == Ok([#("q", "gleam")])
}
```

For three or more conditions, a `case` expression with multiple subjects
usually reads better than a long `&&` chain:

```gleam
// 2.0.0: equivalent to the matcher above, using pattern matching
fn(req) {
  case req.method, req.path, request.get_query(req) {
    http.Get, "/search", Ok([#("q", "gleam")]) -> True
    _, _, _ -> False
  }
}
```

Common 1.x matcher calls and their 2.0.0 equivalents:

| 1.x | 2.0.0 |
|---|---|
| `matcher.method(http.Post)` | `req.method == http.Post` |
| `matcher.path("/users/42")` | `req.path == "/users/42"` |
| `matcher.path_contains("users")` | `string.contains(req.path, "users")` |
| `matcher.path_matching(types.Prefix("/api/"))` | `string.starts_with(req.path, "/api/")` |
| `matcher.query_param("q", "gleam")` | `request.get_query(req) == Ok([#("q", "gleam")])` (or `list.key_find` on the result if you only care about one param among others) |
| `matcher.header("authorization", "Bearer secret")` | `request.get_header(req, "authorization") == Ok("Bearer secret")` |
| `matcher.body_equal_to("...")` | `req.body == "..."` |
| `matcher.body_containing("important")` | `string.contains(req.body, "important")` |
| `matcher.body_json("{\"a\":1}")` (whitespace-insensitive) | parse both sides with `gleam/json` and compare the decoded values: this is also a correctness fix, since 1.x's whitespace-insensitive comparison was a naive string strip that could mismatch on JSON containing whitespace inside string values |

There's no `matcher.new()` "matches everything" starting point to build on,
just write `fn(_req) { True }` if you genuinely want a catch-all, though
usually you want at least a path check.

## 3. Responses become plain values

The `response` module and `ResponseDefinition`/`ResponseBody` types are
gone. A response is a plain `gleam/http/response.Response(String)`, and
critically **it's a value, not a function**: see [section 4](#4-building-and-registering-stubs)
for why.

```gleam
// 1.x
response.new()
|> response.status(201)
|> response.header("x-request-id", "abc123")
|> response.json_body("{\"id\":1,\"status\":\"created\"}")
```

```gleam
// 2.0.0
response.new(201)
|> response.set_header("x-request-id", "abc123")
|> response.set_header("content-type", "application/json")
|> response.set_body("{\"id\":1,\"status\":\"created\"}")
```

Notes:

- `response.new(status)` takes the status code directly; there's no
  separate `response.status(...)` step.
- `response.json_body(...)` used to set `content-type: application/json`
  for you. `response.set_body` doesn't set headers, so add that header
  yourself if you need it (most test assertions don't check content-type,
  so you often don't need to).
- The canned responses (`response.ok()`, `response.not_found()`,
  `response.server_error()`, `response.created()`, ...) are gone. Use
  `response.new(200)`, `response.new(404)`, etc. directly: that's already
  one call, so the shorthand wasn't saving much.
- `response.delay(milliseconds)` (simulating a slow response) has no 2.0.0
  equivalent. It's not currently supported; if you need it, you'll have to
  build your own delay into a `with_handler` handler's surrounding test code.
- Binary/`BytesBody` responses: 1.x had a `BytesBody(BitArray)` variant
  that nothing actually constructed and that got silently dropped when
  crossing the FFI boundary: it never really worked. 2.0.0 doesn't
  special-case binary bodies; everything is `Response(String)`.

## 4. Building and registering stubs

This is the biggest conceptual change. `stub_builder` (and its three
phantom type parameters enforcing "matcher set" / "response set" / "in a
scenario") is gone, replaced by a single function:

```gleam
// 1.x
let my_stub =
  stub_builder.new()
  |> stub_builder.matching(
    matcher.new() |> matcher.method(http.Get) |> matcher.path("/ping"),
  )
  |> stub_builder.responding_with(response.ok())
  |> stub_builder.with_id("my-stub")
  |> stub_builder.with_priority(1)
  |> stub_builder.build()
```

```gleam
// 2.0.0
let my_stub =
  http_server_mock.stub(
    fn(req) { req.method == http.Get && req.path == "/ping" },
    response.new(200),
  )
```

`with_id` and `with_priority` have no 2.0.0 equivalent, and there's no
`Stub.id`/`Stub.priority` field to migrate onto. Both existed in 1.x to
support removing a specific stub later and controlling match order among
overlapping stubs. 2.0.0 covers both without needing either concept:

- **Removing a specific stub:** `remove_stub` now takes the `Stub` value
  itself instead of a string id (see [section 4a](#4a-removing-a-specific-stub)
  below).
- **Match order:** when more than one registered stub matches the same
  request, the one registered first wins, full stop. There's no priority
  number to set: put the stub you want to win earlier in the list you pass
  to `with_stubs`, or call `add_stub` in the order you want.

**Why `stub`'s second argument is a value, not a function of the request:**
the test that builds a stub already controls every value that ends up in
whatever request it's matching, so it already has everything it needs to
build the response too. If you find yourself wanting to compute the
response from the incoming request (e.g. "echo this back"), ask whether the
test already knows that value: it almost always does, since the test is
the one that constructed the request in the first place. Different
responses for different inputs are different stubs with narrower `matches`
predicates, not one stub branching internally:

```gleam
// 2.0.0: two stubs instead of one branching stub
[
  http_server_mock.stub(
    fn(req) { req.path == "/users/1" },
    response.new(200) |> response.set_body("{\"id\":1,\"name\":\"Alice\"}"),
  ),
  http_server_mock.stub(
    fn(req) { req.path == "/users/2" },
    response.new(200) |> response.set_body("{\"id\":2,\"name\":\"Bob\"}"),
  ),
]
```

The one case this doesn't cover, reflecting data whose exact shape only the
*code under test* knows (not the test itself, like verifying an HTTP
client's own serialization round-trips correctly), is what
[`with_handler`](#10-the-with_handler-handler-new-in-200) is for, since its handler
already has to be a function of the request to do its own routing.

### 4a. Removing a specific stub

1.x used `remove_stub(server, id)`, matching by the string id set via
`with_id` (or an auto-generated one). 2.0.0 has no `id` field at all:
`remove_stub` takes the `Stub` value itself.

```gleam
// 1.x
let my_stub = stub_builder.new() |> ... |> stub_builder.with_id("my-stub") |> stub_builder.build()
http_server_mock.with_stub(server, my_stub)
// ... later ...
http_server_mock.remove_stub(server, "my-stub")
```

```gleam
// 2.0.0
let my_stub = http_server_mock.stub(matches, response)
http_server_mock.add_stub(server, my_stub)
// ... later ...
http_server_mock.remove_stub(server, my_stub)
```

Pass the exact `Stub` value you registered, not a freshly-built stub with
equivalent-looking logic: two separately-created stubs are never considered
equal even if they behave the same, so keep the original value around (in a
variable, as here) if you'll need to remove it later.

Registering stubs:

```gleam
// 1.x
http_server_mock.with_stub(server, my_stub)       // panics on failure
http_server_mock.add_stub(server, my_stub)        // returns Result

// 2.0.0
http_server_mock.add_stub(server, my_stub)        // returns Result(Nil, String)
```

`with_stub` (the panicking variant) has no 2.0.0 equivalent: `add_stub`'s
`Result` is now the only path. Most of the time you won't call `add_stub`
directly at all: pass your stubs as a list to `with_stubs` when starting the
server (see the next section).

## 5. Server lifecycle: `use` instead of `start`/`stop`

1.x used phantom types (`NotStarted`, `Started`, `Stopped`) to make
start/stop ordering a compile-time property:

```gleam
// 1.x
let server =
  http_server_mock.new(http_server_mock_erlang.server())
  |> http_server_mock.start()
  |> http_server_mock.with_stub(my_stub)

// ... use server ...

http_server_mock.stop(server)
```

2.0.0 drops the phantom types entirely and uses `use` to scope the server's
lifetime instead: the server can't outlive the block that started it:

```gleam
// 2.0.0
use server <- http_server_mock.with_stubs(
  http_server_mock.new(http_server_mock_erlang.server()),
  [my_stub],
)

// ... use server ... (this is the rest of your test function body)
```

`with_stubs` starts the server, runs the rest of your function as the
callback, and stops the server when it returns: no explicit `stop` needed
for the common case. `NotStarted`/`Started`/`Stopped` no longer exist as
types; `MockServer` is a single opaque type regardless of whether the server
is running.

**Escape hatch:** if your test can't be structured as a `use` block (for
example, `gleeunit` setup/teardown pairs that split start and stop across
two different functions), `start`/`start_with_stubs`/`stop` still exist:

```gleam
// 2.0.0: manual lifecycle
let assert Ok(server) =
  http_server_mock.start_with_stubs(config, [my_stub])
// ...
http_server_mock.stop(server)
```

**Known limitation:** unlike the phantom-typed 1.x design (which only
prevented *compile-time* misuse, not runtime leaks), if the code inside a
`with_stubs`/`with_handler` block panics before returning, `stop` is not
guaranteed to run: the server process is only cleaned up when the test
runner exits. This is a documented trade-off for 2.0.0, not a regression:
1.x had the identical gap for a panicking test body between manual `start`
and `stop` calls.

## 6. `verify` is gone: assert it yourself

The `verify` module and all four of its functions (`called`,
`called_times`, `called_at_least`, `never_called`) are deleted. They used to
panic with a custom message on failure; that's exactly the pattern Gleam's
own conventions discourage ("hiding test assertions" inside library code).

```gleam
// 1.x
verify.called_times(server, my_matcher, 3)
verify.never_called(server, other_matcher)
```

```gleam
// 2.0.0
import gleam/list

let matching_calls =
  list.filter(http_server_mock.received(server), fn(req) {
    req.path == "/orders"
  })
assert list.length(matching_calls) == 3

let other_calls =
  list.filter(http_server_mock.received(server), fn(req) {
    req.path == "/other"
  })
assert other_calls == []
```

`http_server_mock.received(server)` returns every request the server has
seen, as plain `List(Request(String))`. Filter it however precisely you
need to, then use Gleam's built-in `assert`: it gives you a clear
`left`/`right` diff on failure without any library help needed, and you get
to choose exactly how precise the check is (there's no `called_at_most`
equivalent to reach for in 1.x either: with `received`, `list.length(...) <= n`
is one line).

There's no direct migration for `called`'s "return the matched requests so
you can chain further assertions" behavior: just keep the filtered list in
a variable and inspect it yourself:

```gleam
// 2.0.0
let assert [only_request] =
  list.filter(http_server_mock.received(server), fn(req) { req.path == "/orders" })
assert only_request.body == "{\"item\":\"book\"}"
```

## 7. Recorded requests

`RecordedRequest` (with its `id`, `timestamp_ms`, and `matched_stub_id`
fields) is gone. Recorded requests are plain `gleam/http/request.Request(String)`
values.

```gleam
// 1.x
pub type RecordedRequest {
  RecordedRequest(
    id: String,
    method: Method,
    path: String,
    query: Option(String),
    headers: Dict(String, String),
    body: String,
    timestamp_ms: Int,
    matched_stub_id: Option(String),
  )
}

let assert Ok(requests) = http_server_mock.recorded_requests(server)
let assert Ok(unmatched) = http_server_mock.unmatched_requests(server)
```

```gleam
// 2.0.0
pub type Request(body) {
  Request(
    method: Method,
    headers: List(#(String, String)),
    body: body,
    scheme: Scheme,
    host: String,
    port: Option(Int),
    path: String,
    query: Option(String),
  )
}

let requests = http_server_mock.received(server)          // no Result wrapper
let unmatched = http_server_mock.unmatched_requests(server) // no Result wrapper
```

Two things changed here beyond the type:

- **`recorded_requests` was renamed to `received`.**
- **Both functions dropped the `Result` wrapper.** In 1.x they could fail
  with a transport error (`Result(List(RecordedRequest), String)`); in
  2.0.0 they just return the list. If you have `let assert Ok(...) = ...`
  around either call, drop the `let assert Ok(...)` and use the value
  directly.
- **`timestamp_ms` and `matched_stub_id` have no replacement.** They were
  judged not useful to test writers: the header/body/method/path/query
  data test authors actually assert on is all still there. If you were
  relying on `matched_stub_id` to check *which* stub fired, restructure the
  test to check the response instead (since the whole point of a stub is
  "if this response came back, this stub matched").
- **`headers` changed from `Dict(String, String)` to `List(#(String, String))`**,
  matching `gleam_http`'s `Request` type. Use `request.get_header(req, "key")`
  (case-insensitive lookup, returns `Result(String, Nil)`) instead of
  `dict.get`.

## 8. Scenarios (stateful sequences) are gone

1.x let a stub belong to a named "scenario," matching only when that
scenario was in a given state and optionally transitioning it afterward, so
the same endpoint could answer differently across successive calls (e.g. a
job that starts "pending" and later returns "complete"):

```gleam
// 1.x
stub_builder.new()
|> stub_builder.matching(poll_matcher)
|> stub_builder.responding_with(response.new() |> response.body("running"))
|> stub_builder.in_scenario("job-1")
|> stub_builder.then_transition_to("done")
|> stub_builder.build()
```

2.0.0 has no equivalent: `in_scenario`, `when_state_is`, and
`then_transition_to` don't exist, and `Stub` has no scenario field to build
one from directly. This is a real feature loss, cut deliberately rather
than carried over in its 1.x shape while the API around it was already
changing so much - it may come back later in whatever shape fits best then.

If you need stateful sequences today, model it yourself: swap the
registered stub after the triggering request fires (`add_stub` a
replacement, `remove_stub` the old one), or close over your own mutable
state in a `with_handler` handler's `matches`/response logic.

Separately, match order changed too: 1.x scored stubs by matcher
specificity (an exact-path match outranked a "contains" match, for
example) to break ties between equal-priority stubs, with `with_priority`
letting you override that. Since matching is now an opaque closure rather
than inspectable matcher data, there's no way to compute that specificity
anymore, and `with_priority` doesn't exist either: 2.0.0 always picks the
first registered stub that matches, full stop. If you need a specific stub
to win over another when both could match the same request, register it
first (or `add_stub` it before the other).

## 9. Admin HTTP endpoints

1.x exposed `/__admin/stubs` (GET/POST/DELETE, JSON) and `/__admin/requests`
(GET/DELETE, JSON) alongside the mock server's own routes, for external
introspection without going through the Gleam API.

2.0.0 removes all of them, on both runtimes, including `/__admin/health`.
Stubs are live Gleam closures now, not JSON-representable data, so there's
nothing to list or add over HTTP. Use the Gleam-level functions instead:

| 1.x | 2.0.0 |
|---|---|
| `GET /__admin/stubs` | no equivalent: stubs aren't introspectable from outside the process |
| `POST /__admin/stubs` | `http_server_mock.add_stub(server, stub)` |
| `DELETE /__admin/stubs` | `http_server_mock.reset_stubs(server)` |
| `GET /__admin/requests` | `http_server_mock.received(server)` |
| `DELETE /__admin/requests` | `http_server_mock.reset_requests(server)` |
| `GET /__admin/health` | no equivalent: check `http_server_mock.base_url` responds however you'd check any server is up |

A proper admin HTTP surface may return in a future release, but 2.0.0
deliberately doesn't ship a partial one (health-only, or working on one
runtime and not the other).

## 10. The `with_handler` handler (new in 2.0.0)

There's no 1.x equivalent to migrate *from* here: `with_handler` is new: but if
you're restructuring tests during a migration, it's worth knowing about.
For a single endpoint with no cross-request state, a handler function is
often less ceremony than a one-item stub list:

```gleam
// 2.0.0
use server <- http_server_mock.with_handler(config, fn(req) {
  case req.method, request.path_segments(req) {
    http.Get, ["greet"] ->
      response.new(200) |> response.set_body("hello") |> Ok
    _, _ -> Error(http_server_mock.UnexpectedRequest(req))
  }
})
```

Reach for `with_stubs` instead when you have more than a couple of
independent routes: matching several unrelated cases is meaningfully
harder to read inside one `case` expression than as separate stubs.

## 11. JS runtime

If you use `http_server_mock_js`: the public API (`http_server_mock.with_handler`,
`with_stubs`, `stub`, `received`, ...) is identical to the Erlang runtime —
none of the migration steps above differ by target. Under the hood, the JS
runtime's implementation changed completely (the Worker thread is now a
dumb HTTP transport that forwards requests to the main thread, where the
real stub closures live, instead of holding JSON-serialized stub data
itself). You don't need to do anything differently in your own code for
this; it's mentioned here only because if you had any code reaching into
`http_server_mock_js`'s `internal/` modules directly (unsupported, but
technically possible in Gleam), those internals were rewritten from
scratch and none of the old function names or shapes survived.

If you write your own "synchronous-looking" HTTP test client on the JS
target (a `Worker` + busy spin-wait, the way this library's own test suite
fakes `httpc.send`-style calls), see `http_server_mock_js`'s README for a
requirement this introduces: that spin loop must cooperate with the mock
server's own callback channel via `internal/sync_pump.mjs`'s `pumpAll()`,
or the two can deadlock.

## 12. Quick reference table

| 1.x | 2.0.0 |
|---|---|
| `import http_server_mock/matcher` | deleted: write `fn(Request(String)) -> Bool` |
| `import http_server_mock/response` | deleted: use `gleam/http/response` |
| `import http_server_mock/stub_builder` | deleted: use `http_server_mock.stub` |
| `import http_server_mock/verify` | deleted: assert on `http_server_mock.received` yourself |
| `import http_server_mock/types` | deleted: types are inline in `http_server_mock` or `gleam_http` |
| `matcher.new() \|> matcher.path(...) \|> ...` | `fn(req) { req.path == "..." }` |
| `response.new() \|> response.body(...) \|> ...` | `response.new(200) \|> response.set_body(...)` |
| `stub_builder.new() \|> ... \|> stub_builder.build()` | `http_server_mock.stub(matches, response)` |
| `http_server_mock.with_stub(server, stub)` (panics) | `http_server_mock.add_stub(server, stub)` (returns `Result`) |
| `http_server_mock.new(adapter) \|> http_server_mock.start()` | `use server <- http_server_mock.with_stubs(config, stubs)` |
| `NotStarted`/`Started`/`Stopped` phantom types | gone: lifecycle is scoped by `use` instead |
| `http_server_mock.recorded_requests(server)` (`Result`) | `http_server_mock.received(server)` (plain list) |
| `RecordedRequest` (`id`, `timestamp_ms`, `matched_stub_id`, ...) | `gleam/http/request.Request(String)` |
| `verify.called(server, matcher)` | `list.filter(http_server_mock.received(server), ...)` + `assert` |
| `verify.called_times(server, matcher, n)` | `assert list.length(filtered) == n` |
| `verify.called_at_least(server, matcher, n)` | `assert list.length(filtered) >= n` |
| `verify.never_called(server, matcher)` | `assert filtered == []` |
| `/__admin/stubs` (HTTP JSON) | `add_stub`/`reset_stubs` (Gleam API only) |
| `/__admin/requests` (HTTP JSON) | `received`/`reset_requests` (Gleam API only) |
| `/__admin/health` (HTTP JSON) | no equivalent |
| `stub_builder.with_id("x")` + `remove_stub(server, "x")` | keep the `Stub` value and call `remove_stub(server, that_value)` |
| `stub_builder.with_priority(n)` (specificity-based tie-break) | none: first registered stub that matches always wins |
