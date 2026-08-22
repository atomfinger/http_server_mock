import gleam/http
import gleam/http/request
import gleam/http/response
import gleam/httpc
import gleam/list
import gleam/string
import http_server_mock
import http_server_mock_erlang

type TestResponse {
  TestResponse(status: Int, headers: List(#(String, String)), body: String)
}

@external(javascript, "./integration_test_ffi.mjs", "syncGet")
fn get(url: String) -> TestResponse {
  let assert Ok(http_request) = request.to(url)
  let assert Ok(http_response) = httpc.send(http_request)
  TestResponse(
    status: http_response.status,
    headers: http_response.headers,
    body: http_response.body,
  )
}

@external(javascript, "./integration_test_ffi.mjs", "syncPost")
fn post(url: String, body: String, content_type: String) -> TestResponse {
  let assert Ok(base_request) = request.to(url)
  let assert Ok(http_response) =
    base_request
    |> request.set_method(http.Post)
    |> request.set_body(body)
    |> request.set_header("content-type", content_type)
    |> httpc.send
  TestResponse(
    status: http_response.status,
    headers: http_response.headers,
    body: http_response.body,
  )
}

fn config() -> http_server_mock.Config {
  http_server_mock.new(http_server_mock_erlang.server())
}

pub fn simple_get_stub_test() {
  use server <- http_server_mock.with_stubs(config(), [
    http_server_mock.stub(
      fn(req) { req.method == http.Get && req.path == "/hello" },
      response.new(200) |> response.set_body("world"),
    ),
  ])

  let http_response = get(http_server_mock.base_url(server) <> "/hello")
  assert http_response.status == 200
  assert http_response.body == "world"
}

pub fn unmatched_request_returns_404_test() {
  use server <- http_server_mock.with_stubs(config(), [])

  assert get(http_server_mock.base_url(server) <> "/no-such-path").status == 404
}

pub fn stub_with_response_headers_test() {
  use server <- http_server_mock.with_stubs(config(), [
    http_server_mock.stub(
      fn(req) { req.path == "/json-data" },
      response.new(200)
        |> response.set_header("content-type", "application/json")
        |> response.set_body("{\"ok\":true}"),
    ),
  ])

  let http_response = get(http_server_mock.base_url(server) <> "/json-data")
  assert http_response.status == 200
  assert http_response.body == "{\"ok\":true}"
  let assert Ok(content_type) =
    list.key_find(http_response.headers, "content-type")
  assert string.contains(content_type, "application/json")
}

pub fn multiple_stubs_different_paths_test() {
  use server <- http_server_mock.with_stubs(config(), [
    http_server_mock.stub(
      fn(req) { req.path == "/a" },
      response.new(200) |> response.set_body("response-a"),
    ),
    http_server_mock.stub(
      fn(req) { req.path == "/b" },
      response.new(200) |> response.set_body("response-b"),
    ),
  ])

  assert get(http_server_mock.base_url(server) <> "/a").body == "response-a"
  assert get(http_server_mock.base_url(server) <> "/b").body == "response-b"
}

pub fn add_stub_preserves_registration_order_for_ties_test() {
  use server <- http_server_mock.with_stubs(config(), [
    http_server_mock.stub(
      fn(req) { req.path == "/tie" },
      response.new(200) |> response.set_body("first"),
    ),
  ])

  let assert Ok(Nil) =
    http_server_mock.add_stub(
      server,
      http_server_mock.stub(
        fn(req) { req.path == "/tie" },
        response.new(200) |> response.set_body("second"),
      ),
    )

  // The one from with_stubs was registered first, so it should still win.
  assert get(http_server_mock.base_url(server) <> "/tie").body == "first"
}

pub fn remove_stub_removes_the_exact_stub_test() {
  let removable =
    http_server_mock.stub(
      fn(req) { req.path == "/removable" },
      response.new(200) |> response.set_body("still here"),
    )

  use server <- http_server_mock.with_stubs(config(), [removable])

  assert get(http_server_mock.base_url(server) <> "/removable").status == 200

  http_server_mock.remove_stub(server, removable)

  assert get(http_server_mock.base_url(server) <> "/removable").status == 404
}

pub fn received_tracks_calls_test() {
  use server <- http_server_mock.with_stubs(config(), [
    http_server_mock.stub(
      fn(req) { req.path == "/track" },
      response.new(200) |> response.set_body("ok"),
    ),
  ])

  let _ = get(http_server_mock.base_url(server) <> "/track")
  let _ = get(http_server_mock.base_url(server) <> "/track")

  let tracked =
    list.filter(http_server_mock.received(server), fn(req) {
      req.path == "/track"
    })
  assert list.length(tracked) == 2
}

pub fn reset_stubs_removes_all_stubs_test() {
  use server <- http_server_mock.with_stubs(config(), [
    http_server_mock.stub(
      fn(req) { req.path == "/gone" },
      response.new(200) |> response.set_body("was here"),
    ),
  ])

  assert get(http_server_mock.base_url(server) <> "/gone").status == 200
  http_server_mock.reset_stubs(server)
  assert get(http_server_mock.base_url(server) <> "/gone").status == 404
}

pub fn reset_requests_clears_history_test() {
  use server <- http_server_mock.with_stubs(config(), [
    http_server_mock.stub(
      fn(req) { req.path == "/call" },
      response.new(200) |> response.set_body("ok"),
    ),
  ])

  let _ = get(http_server_mock.base_url(server) <> "/call")
  http_server_mock.reset_requests(server)

  assert http_server_mock.received(server) == []
}

pub fn query_param_matching_test() {
  use server <- http_server_mock.with_stubs(config(), [
    http_server_mock.stub(
      fn(req) {
        case req.path, request.get_query(req) {
          "/search", Ok([#("q", "gleam")]) -> True
          _, _ -> False
        }
      },
      response.new(200) |> response.set_body("found"),
    ),
  ])

  assert get(http_server_mock.base_url(server) <> "/search?q=gleam").body
    == "found"
  assert get(http_server_mock.base_url(server) <> "/search?q=other").status
    == 404
}

pub fn unmatched_requests_test() {
  use server <- http_server_mock.with_stubs(config(), [
    http_server_mock.stub(fn(req) { req.path == "/known" }, response.new(200)),
  ])

  let _ = get(http_server_mock.base_url(server) <> "/known")
  let _ = get(http_server_mock.base_url(server) <> "/unknown-a")
  let _ = get(http_server_mock.base_url(server) <> "/unknown-b")

  let unmatched = http_server_mock.unmatched_requests(server)
  assert list.length(unmatched) == 2
}

pub fn post_with_body_matching_test() {
  use server <- http_server_mock.with_stubs(config(), [
    http_server_mock.stub(
      fn(req) {
        case req.method, req.path, string.contains(req.body, "important") {
          http.Post, "/submit", True -> True
          _, _, _ -> False
        }
      },
      response.new(201),
    ),
  ])

  assert post(
      http_server_mock.base_url(server) <> "/submit",
      "{\"important\":true}",
      "application/json",
    ).status
    == 201

  assert post(
      http_server_mock.base_url(server) <> "/submit",
      "{\"other\":true}",
      "application/json",
    ).status
    == 404
}

pub fn with_handler_routes_by_case_test() {
  use server <- http_server_mock.with_handler(config(), fn(req) {
    case req.method, request.path_segments(req) {
      http.Get, ["greet"] ->
        response.new(200) |> response.set_body("hello") |> Ok
      _, _ -> Error(http_server_mock.UnexpectedRequest(req))
    }
  })

  let http_response = get(http_server_mock.base_url(server) <> "/greet")
  assert http_response.status == 200
  assert http_response.body == "hello"

  assert get(http_server_mock.base_url(server) <> "/other").status == 404
  assert list.length(http_server_mock.unmatched_requests(server)) == 1
}

pub fn manual_start_stop_escape_hatch_test() {
  let assert Ok(server) =
    http_server_mock.start_with_stubs(config(), [
      http_server_mock.stub(
        fn(req) { req.path == "/manual" },
        response.new(200) |> response.set_body("ok"),
      ),
    ])

  assert get(http_server_mock.base_url(server) <> "/manual").body == "ok"

  http_server_mock.stop(server)
}

pub fn with_port_binds_to_the_requested_port_test() {
  let config =
    http_server_mock.new(http_server_mock_erlang.server())
    |> http_server_mock.with_port(39_217)

  use server <- http_server_mock.with_stubs(config, [])

  assert http_server_mock.base_url(server) == "http://localhost:39217"
  assert get(http_server_mock.base_url(server) <> "/anything").status == 404
}

pub fn start_returns_error_when_the_port_is_already_in_use_test() {
  let config =
    http_server_mock.new(http_server_mock_erlang.server())
    |> http_server_mock.with_port(39_218)

  let assert Ok(first_server) = http_server_mock.start(config)
  let assert Error(_) = http_server_mock.start(config)

  http_server_mock.stop(first_server)
}

pub fn reset_clears_stubs_and_requests_together_test() {
  use server <- http_server_mock.with_stubs(config(), [
    http_server_mock.stub(
      fn(req) { req.path == "/both" },
      response.new(200) |> response.set_body("ok"),
    ),
  ])

  let _ = get(http_server_mock.base_url(server) <> "/both")
  http_server_mock.reset(server)

  assert http_server_mock.received(server) == []
  assert get(http_server_mock.base_url(server) <> "/both").status == 404
}

pub fn received_by_returns_only_requests_that_matched_the_given_stub_test() {
  let ping =
    http_server_mock.stub(
      fn(req) { req.path == "/ping" },
      response.new(200) |> response.set_body("pong"),
    )
  let pong =
    http_server_mock.stub(
      fn(req) { req.path == "/pong" },
      response.new(200) |> response.set_body("ping"),
    )

  use server <- http_server_mock.with_stubs(config(), [ping, pong])

  let _ = get(http_server_mock.base_url(server) <> "/ping")
  let _ = get(http_server_mock.base_url(server) <> "/ping")
  let _ = get(http_server_mock.base_url(server) <> "/pong")

  assert list.length(http_server_mock.received_by(server, ping)) == 2
  assert list.length(http_server_mock.received_by(server, pong)) == 1
}
