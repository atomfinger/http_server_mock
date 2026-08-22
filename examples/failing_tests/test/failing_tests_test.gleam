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

fn get(url: String) -> Int {
  let assert Ok(req) = request.to(url)
  let assert Ok(resp) = httpc.send(req)
  resp.status
}

fn post(url: String, body: String) -> Int {
  let assert Ok(req) = request.to(url)
  let assert Ok(resp) =
    req
    |> request.set_method(http.Post)
    |> request.set_body(body)
    |> request.set_header("content-type", "application/json")
    |> httpc.send
  resp.status
}

fn delete(url: String) -> Int {
  let assert Ok(req) = request.to(url)
  let assert Ok(resp) = httpc.send(req |> request.set_method(http.Delete))
  resp.status
}

fn config() -> http_server_mock.Config {
  http_server_mock.new(http_server_mock_erlang.server())
}

// Called 0 times, but the assertion expects 1.
pub fn expected_one_call_fails_when_never_called_test() {
  let get_ping =
    http_server_mock.stub(
      fn(req) { req.method == http.Get && req.path == "/ping" },
      response.new(200),
    )

  use server <- http_server_mock.with_stubs(config(), [get_ping])

  // We never actually call /ping - this assertion should fail.
  let ping_calls =
    list.filter(http_server_mock.received(server), fn(req) {
      req.path == "/ping"
    })
  assert list.length(ping_calls) == 1
}

// Called once, but the assertion expects 3.
pub fn expected_three_calls_fails_when_count_is_wrong_test() {
  let get_items =
    http_server_mock.stub(
      fn(req) { req.method == http.Get && req.path == "/items" },
      response.new(200),
    )

  use server <- http_server_mock.with_stubs(config(), [get_items])

  let _ = get(http_server_mock.base_url(server) <> "/items")

  let item_calls =
    list.filter(http_server_mock.received(server), fn(req) {
      req.path == "/items"
    })
  assert list.length(item_calls) == 3
}

// The endpoint was called, but the assertion expects it not to have been.
pub fn expected_no_calls_fails_when_endpoint_was_hit_test() {
  let delete_all =
    http_server_mock.stub(
      fn(req) { req.method == http.Delete && req.path == "/everything" },
      response.new(204),
    )

  use server <- http_server_mock.with_stubs(config(), [delete_all])

  // Oops - we did call it.
  let _ = delete(http_server_mock.base_url(server) <> "/everything")

  let deletions =
    list.filter(http_server_mock.received(server), fn(req) {
      req.method == http.Delete && req.path == "/everything"
    })
  assert deletions == []
}

// The stub matches GET /users, but we call POST /users instead.
pub fn expected_get_called_at_least_once_fails_when_only_post_used_test() {
  let get_users =
    http_server_mock.stub(
      fn(req) { req.method == http.Get && req.path == "/users" },
      response.new(200),
    )
  let post_users =
    http_server_mock.stub(
      fn(req) { req.method == http.Post && req.path == "/users" },
      response.new(201),
    )

  use server <- http_server_mock.with_stubs(config(), [get_users, post_users])

  // We call POST, but then assert that GET was called at least once.
  let _ = post(http_server_mock.base_url(server) <> "/users", "{\"name\":\"Alice\"}")

  let get_calls =
    list.filter(http_server_mock.received(server), fn(req) {
      req.method == http.Get && req.path == "/users"
    })
  assert list.length(get_calls) >= 1
}
