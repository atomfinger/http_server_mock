import gleam/http
import gleam/http/request
import gleam/httpc
import gleeunit
import http_server_mock
import http_server_mock/matcher
import http_server_mock/response
import http_server_mock/stub_builder
import http_server_mock/verify

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

// Called 0 times, but verify expects 1.
pub fn verify_called_times_fails_when_never_called_test() {
  let get_ping =
    matcher.new()
    |> matcher.method(http.Get)
    |> matcher.path("/ping")

  let server =
    http_server_mock.new()
    |> http_server_mock.start()
    |> http_server_mock.with_stub(
      stub_builder.new()
      |> stub_builder.matching(get_ping)
      |> stub_builder.responding_with(response.ok())
      |> stub_builder.build(),
    )

  // We never actually call /ping — verify should fail.
  verify.called_times(server, get_ping, 1)

  http_server_mock.stop(server)
}

// Called once, but verify expects 3.
pub fn verify_called_times_fails_when_count_is_wrong_test() {
  let get_items =
    matcher.new()
    |> matcher.method(http.Get)
    |> matcher.path("/items")

  let server =
    http_server_mock.new()
    |> http_server_mock.start()
    |> http_server_mock.with_stub(
      stub_builder.new()
      |> stub_builder.matching(get_items)
      |> stub_builder.responding_with(response.ok())
      |> stub_builder.build(),
    )

  get(http_server_mock.base_url(server) <> "/items")

  verify.called_times(server, get_items, 3)

  http_server_mock.stop(server)
}

// The endpoint was called, but verify.never_called says it shouldn't have been.
pub fn verify_never_called_fails_when_endpoint_was_hit_test() {
  let delete_all =
    matcher.new()
    |> matcher.method(http.Delete)
    |> matcher.path("/everything")

  let server =
    http_server_mock.new()
    |> http_server_mock.start()
    |> http_server_mock.with_stub(
      stub_builder.new()
      |> stub_builder.matching(delete_all)
      |> stub_builder.responding_with(response.new() |> response.status(204))
      |> stub_builder.build(),
    )

  // Oops — we did call it.
  delete(http_server_mock.base_url(server) <> "/everything")

  verify.never_called(server, delete_all)

  http_server_mock.stop(server)
}

// The stub matches GET /users, but we call POST /users instead.
pub fn verify_called_at_least_fails_when_wrong_method_used_test() {
  let get_users =
    matcher.new()
    |> matcher.method(http.Get)
    |> matcher.path("/users")
  let post_users =
    matcher.new()
    |> matcher.method(http.Post)
    |> matcher.path("/users")

  let server =
    http_server_mock.new()
    |> http_server_mock.start()
    |> http_server_mock.with_stub(
      stub_builder.new()
      |> stub_builder.matching(get_users)
      |> stub_builder.responding_with(response.ok())
      |> stub_builder.build(),
    )
    |> http_server_mock.with_stub(
      stub_builder.new()
      |> stub_builder.matching(post_users)
      |> stub_builder.responding_with(response.new() |> response.status(201))
      |> stub_builder.build(),
    )

  // We call POST, but then verify expects GET to have been called at least once.
  post(http_server_mock.base_url(server) <> "/users", "{\"name\":\"Alice\"}")

  verify.called_at_least(server, get_users, 1)

  http_server_mock.stop(server)
}
