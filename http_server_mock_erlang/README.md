# http_server_mock_erlang

Erlang/OTP runtime for [http_server_mock](https://hex.pm/packages/http_server_mock): a WireMock-style HTTP mock server library for Gleam. This package provides the server adapter that runs on the Erlang target using [mist](https://hex.pm/packages/mist) and OTP actors.

You need both this package and `http_server_mock` to use the library. See the [http_server_mock README](https://github.com/atomfinger/http_server_mock#readme) for the full API documentation.

## Installation

```sh
gleam add http_server_mock http_server_mock_erlang
```

## Usage

Pass the adapter from this package to `http_server_mock.new/1`:

```gleam
import gleam/http
import gleam/http/response
import gleam/list
import http_server_mock
import http_server_mock_erlang

pub fn my_test() {
  use server <- http_server_mock.with_stubs(
    http_server_mock.new(http_server_mock_erlang.server()),
    [
      http_server_mock.stub(
        fn(req) { req.method == http.Get && req.path == "/hello" },
        response.new(200) |> response.set_body("world"),
      ),
    ],
  )

  let url = http_server_mock.base_url(server) <> "/hello"
  // ... make HTTP calls ...

  assert list.length(http_server_mock.received(server)) == 1
}
```

## Design notes for this runtime

- Stubs are stored as live Gleam closures directly in the OTP actor's state
  (`server_impl.gleam`): no serialization needed, since the actor and the
  test process run on the same node.
- `simple`/`with_stubs` stop the server after `callback` returns normally.
  If the callback panics, `stop` is not guaranteed to run: the actor and its
  linked mist listener are cleaned up when the test runner's BEAM VM exits,
  not immediately. Full panic-safe cleanup (e.g. via process linking/monitors
  around the calling test process) is a possible fast-follow, not implemented
  in 2.0.0.
- The `/__admin/*` HTTP endpoints from 1.x (`/__admin/stubs`,
  `/__admin/requests`, `/__admin/health`) are all gone for now. Stubs are
  closures, not JSON-representable, so there's nothing to list/add/delete
  over HTTP; use the Gleam-level `http_server_mock.received`/
  `unmatched_requests` functions instead of `/__admin/requests`. A proper
  admin HTTP surface (likely just introspection, since stubs can't be
  serialized) may come back in a future release, but 2.0.0 doesn't ship a
  partial one.

## License

MIT
