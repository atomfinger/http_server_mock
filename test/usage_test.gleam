import gleam/http
import gleam/http/request
import gleam/httpc
import http_server_mock
import http_server_mock/matcher
import http_server_mock/response
import http_server_mock/stub
import http_server_mock/verify

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
  let assert Ok(server) =
    http_server_mock.start(http_server_mock.default_config())

  let assert Ok(_) =
    http_server_mock.register(
      server,
      stub.new(
        matcher.new() |> matcher.path("/greet"),
        response.new() |> response.body("Hello!"),
      ),
    )

  let assert "Hello!" = get(http_server_mock.base_url(server) <> "/greet").body

  http_server_mock.stop(server)
}

// Requests that do not match any stub return 404.
pub fn unmatched_requests_return_404_test() {
  let assert Ok(server) =
    http_server_mock.start(http_server_mock.default_config())

  let assert 404 =
    get(http_server_mock.base_url(server) <> "/not-registered").status

  http_server_mock.stop(server)
}

// Matchers can require a specific HTTP method, path, and query parameters.
pub fn matchers_can_filter_on_method_path_and_query_test() {
  let assert Ok(server) =
    http_server_mock.start(http_server_mock.default_config())

  let assert Ok(_) =
    http_server_mock.register(
      server,
      stub.new(
        matcher.new()
          |> matcher.method(http.Get)
          |> matcher.path("/search")
          |> matcher.query_param("q", "gleam"),
        response.new() |> response.body("found"),
      ),
    )

  let assert "found" =
    get(http_server_mock.base_url(server) <> "/search?q=gleam").body

  let assert 404 =
    get(http_server_mock.base_url(server) <> "/search?q=other").status

  http_server_mock.stop(server)
}

// POST stubs can match on body content and return a specific status code.
pub fn post_stub_matches_on_body_and_returns_status_test() {
  let assert Ok(server) =
    http_server_mock.start(http_server_mock.default_config())

  let assert Ok(_) =
    http_server_mock.register(
      server,
      stub.new(
        matcher.new()
          |> matcher.method(http.Post)
          |> matcher.path("/echo")
          |> matcher.body_containing("ping"),
        response.new() |> response.status(201) |> response.body("pong"),
      ),
    )

  let resp =
    post(http_server_mock.base_url(server) <> "/echo", "ping", "text/plain")
  let assert 201 = resp.status
  let assert "pong" = resp.body

  http_server_mock.stop(server)
}

// All requests are recorded and can be verified after the fact.
pub fn recorded_requests_can_be_verified_test() {
  let assert Ok(server) =
    http_server_mock.start(http_server_mock.default_config())

  let ping = matcher.new() |> matcher.method(http.Get) |> matcher.path("/ping")
  let assert Ok(_) =
    http_server_mock.register(server, stub.new(ping, response.ok()))

  let _ = get(http_server_mock.base_url(server) <> "/ping")
  let _ = get(http_server_mock.base_url(server) <> "/ping")
  let _ = get(http_server_mock.base_url(server) <> "/ping")

  let assert Ok(requests) = http_server_mock.recorded_requests(server)
  verify.called_times(requests, ping, 3)

  http_server_mock.stop(server)
}

// Scenarios model stateful sequences — each call can return a different response.
pub fn scenarios_model_stateful_sequences_test() {
  let assert Ok(server) =
    http_server_mock.start(http_server_mock.default_config())

  let get_job =
    matcher.new() |> matcher.method(http.Get) |> matcher.path("/job")

  let assert Ok(_) =
    http_server_mock.register(
      server,
      stub.new(get_job, response.new() |> response.body("running"))
        |> stub.in_scenario("job")
        |> stub.then_transition_to("done"),
    )

  let assert Ok(_) =
    http_server_mock.register(
      server,
      stub.new(get_job, response.new() |> response.body("complete"))
        |> stub.in_scenario("job")
        |> stub.when_state_is("done"),
    )

  let assert "running" = get(http_server_mock.base_url(server) <> "/job").body
  let assert "complete" = get(http_server_mock.base_url(server) <> "/job").body

  http_server_mock.stop(server)
}
