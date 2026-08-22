# http_server_mock_js

JavaScript/Node.js runtime for [http_server_mock](https://hex.pm/packages/http_server_mock): a WireMock-style HTTP mock server library for Gleam. This package provides the server adapter that runs on the JavaScript target using Node.js's `http` module in a Worker thread.

You need both this package and `http_server_mock` to use the library. See the [http_server_mock README](https://github.com/atomfinger/http_server_mock#readme) for the full API documentation.

## Installation

```sh
gleam add http_server_mock http_server_mock_js
```

Make sure your `gleam.toml` targets JavaScript:

```toml
[javascript]
target = "javascript"
```

## Usage

Pass the adapter from this package to `http_server_mock.new/1`:

```gleam
import gleam/http
import gleam/http/response
import gleam/list
import http_server_mock
import http_server_mock_js

pub fn my_test() {
  use server <- http_server_mock.with_stubs(
    http_server_mock.new(http_server_mock_js.server()),
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

## License

MIT
