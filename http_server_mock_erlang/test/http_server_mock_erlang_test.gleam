import gleam/http
import gleam/http/request
import gleam/http/response
import gleam/httpc
import gleam/list
import gleeunit
import http_server_mock
import http_server_mock_erlang

pub fn main() -> Nil {
  gleeunit.main()
}

type TestResponse {
  TestResponse(status: Int, body: String)
}

@external(javascript, "./usage_test_ffi.mjs", "syncGet")
fn get(url: String) -> TestResponse {
  let assert Ok(req) = request.to(url)
  let assert Ok(resp) = httpc.send(req)
  TestResponse(status: resp.status, body: resp.body)
}

@external(javascript, "./usage_test_ffi.mjs", "syncPost")
fn post(url: String, body: String, content_type: String) -> TestResponse {
  let assert Ok(base) = request.to(url)
  let assert Ok(resp) =
    base
    |> request.set_method(http.Post)
    |> request.set_body(body)
    |> request.set_header("content-type", content_type)
    |> httpc.send
  TestResponse(status: resp.status, body: resp.body)
}

fn config() -> http_server_mock.Config {
  http_server_mock.new(http_server_mock_erlang.server())
}

pub fn stub_responds_to_matching_requests_test() {
  use server <- http_server_mock.with_stubs(config(), [
    http_server_mock.stub(
      fn(req) { req.path == "/greet" },
      response.new(200) |> response.set_body("Hello!"),
    ),
  ])

  assert get(http_server_mock.base_url(server) <> "/greet").body == "Hello!"
}

pub fn unmatched_requests_return_404_test() {
  use server <- http_server_mock.with_stubs(config(), [])

  assert get(http_server_mock.base_url(server) <> "/not-registered").status
    == 404
}

pub fn matchers_can_filter_on_method_path_and_query_test() {
  use server <- http_server_mock.with_stubs(config(), [
    http_server_mock.stub(
      fn(req) {
        case req.method, req.path, request.get_query(req) {
          http.Get, "/search", Ok([#("q", "gleam")]) -> True
          _, _, _ -> False
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

pub fn post_stub_matches_on_body_and_returns_status_test() {
  use server <- http_server_mock.with_stubs(config(), [
    http_server_mock.stub(
      fn(req) {
        case req.method, req.path, req.body {
          http.Post, "/echo", "ping" -> True
          _, _, _ -> False
        }
      },
      response.new(201) |> response.set_body("pong"),
    ),
  ])

  let resp =
    post(http_server_mock.base_url(server) <> "/echo", "ping", "text/plain")
  assert resp.status == 201
  assert resp.body == "pong"
}

pub fn received_requests_can_be_asserted_on_test() {
  use server <- http_server_mock.with_stubs(config(), [
    http_server_mock.stub(
      fn(req) { req.method == http.Get && req.path == "/ping" },
      response.new(200),
    ),
  ])

  let _ = get(http_server_mock.base_url(server) <> "/ping")
  let _ = get(http_server_mock.base_url(server) <> "/ping")
  let _ = get(http_server_mock.base_url(server) <> "/ping")

  assert list.length(http_server_mock.received(server)) == 3
}
