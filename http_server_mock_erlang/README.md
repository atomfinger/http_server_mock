# http_server_mock_erlang

Erlang/OTP runtime for [http_server_mock](https://hex.pm/packages/http_server_mock) — a WireMock-style HTTP mock server library for Gleam. This package provides the server adapter that runs on the Erlang target using [mist](https://hex.pm/packages/mist) and OTP actors.

You need both this package and `http_server_mock` to use the library. See the [http_server_mock README](https://hex.pm/packages/http_server_mock) for the full API documentation.

## Installation

```sh
gleam add http_server_mock http_server_mock_erlang
```

## Usage

Pass the adapter from this package to `http_server_mock.new/1`:

```gleam
import gleam/http
import http_server_mock
import http_server_mock_erlang
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
        |> matcher.path("/hello"),
      )
      |> stub_builder.responding_with(
        response.new()
        |> response.status(200)
        |> response.body("world"),
      )
      |> stub_builder.build(),
    )
    |> http_server_mock.start()

  let url = http_server_mock.base_url(server) <> "/hello"
  // ... make HTTP calls ...

  verify.called(server, matcher.new() |> matcher.path("/hello"))

  http_server_mock.stop(server)
}
```

## License

MIT
