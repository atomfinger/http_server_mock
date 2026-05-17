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

// A registered stub responds to matching requests.
pub fn stub_responds_to_matching_requests_test() {
  let server =
    http_server_mock.new()
    |> http_server_mock.start()
    |> http_server_mock.with_stub(
      stub_builder.new()
      |> stub_builder.matching(matcher.new() |> matcher.path("/greet"))
      |> stub_builder.responding_with(response.new() |> response.body("Hello!"))
      |> stub_builder.build(),
    )

  assert get(http_server_mock.base_url(server) <> "/greet").body == "Hello!"

  http_server_mock.stop(server)
}

// Requests that do not match any stub return 404.
pub fn unmatched_requests_return_404_test() {
  let server = http_server_mock.new() |> http_server_mock.start()

  assert get(http_server_mock.base_url(server) <> "/not-registered").status
    == 404

  http_server_mock.stop(server)
}

// Matchers can require a specific HTTP method, path, and query parameters.
pub fn matchers_can_filter_on_method_path_and_query_test() {
  let server =
    http_server_mock.new()
    |> http_server_mock.start()
    |> http_server_mock.with_stub(
      stub_builder.new()
      |> stub_builder.matching(
        matcher.new()
        |> matcher.method(http.Get)
        |> matcher.path("/search")
        |> matcher.query_param("q", "gleam"),
      )
      |> stub_builder.responding_with(response.new() |> response.body("found"))
      |> stub_builder.build(),
    )

  assert get(http_server_mock.base_url(server) <> "/search?q=gleam").body
    == "found"
  assert get(http_server_mock.base_url(server) <> "/search?q=other").status
    == 404

  http_server_mock.stop(server)
}

// POST stubs can match on body content and return a specific status code.
pub fn post_stub_matches_on_body_and_returns_status_test() {
  let server =
    http_server_mock.new()
    |> http_server_mock.start()
    |> http_server_mock.with_stub(
      stub_builder.new()
      |> stub_builder.matching(
        matcher.new()
        |> matcher.method(http.Post)
        |> matcher.path("/echo")
        |> matcher.body_containing("ping"),
      )
      |> stub_builder.responding_with(
        response.new() |> response.status(201) |> response.body("pong"),
      )
      |> stub_builder.build(),
    )

  let resp =
    post(http_server_mock.base_url(server) <> "/echo", "ping", "text/plain")
  assert resp.status == 201
  assert resp.body == "pong"

  http_server_mock.stop(server)
}

// All requests are recorded and can be verified after the fact.
pub fn recorded_requests_can_be_verified_test() {
  let ping = matcher.new() |> matcher.method(http.Get) |> matcher.path("/ping")

  let server =
    http_server_mock.new()
    |> http_server_mock.start()
    |> http_server_mock.with_stub(
      stub_builder.new()
      |> stub_builder.matching(ping)
      |> stub_builder.responding_with(response.ok())
      |> stub_builder.build(),
    )

  let _ = get(http_server_mock.base_url(server) <> "/ping")
  let _ = get(http_server_mock.base_url(server) <> "/ping")
  let _ = get(http_server_mock.base_url(server) <> "/ping")

  verify.called_times(server, ping, 3)

  http_server_mock.stop(server)
}

// Scenarios model stateful sequences — each call can return a different response.
pub fn scenarios_model_stateful_sequences_test() {
  let get_job =
    matcher.new() |> matcher.method(http.Get) |> matcher.path("/job")

  let server = http_server_mock.new() |> http_server_mock.start()
  let assert Ok(_) =
    http_server_mock.add_stub(
      server,
      stub_builder.new()
        |> stub_builder.matching(get_job)
        |> stub_builder.responding_with(
          response.new() |> response.body("running"),
        )
        |> stub_builder.in_scenario("job")
        |> stub_builder.then_transition_to("done")
        |> stub_builder.build(),
    )
  let assert Ok(_) =
    http_server_mock.add_stub(
      server,
      stub_builder.new()
        |> stub_builder.matching(get_job)
        |> stub_builder.responding_with(
          response.new() |> response.body("complete"),
        )
        |> stub_builder.in_scenario("job")
        |> stub_builder.when_state_is("done")
        |> stub_builder.build(),
    )

  assert get(http_server_mock.base_url(server) <> "/job").body == "running"
  assert get(http_server_mock.base_url(server) <> "/job").body == "complete"

  http_server_mock.stop(server)
}
