import gleam/http
import gleam/http/request
import gleam/httpc
import gleam/list
import gleam/result
import gleam/string
import http_server_mock
import http_server_mock/matcher
import http_server_mock/response as mock_response
import http_server_mock/stub
import http_server_mock/verify

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

@external(javascript, "./integration_test_ffi.mjs", "syncDelete")
fn delete(url: String) -> TestResponse {
  let assert Ok(base_request) = request.to(url)
  let assert Ok(http_response) =
    base_request
    |> request.set_method(http.Delete)
    |> httpc.send
  TestResponse(
    status: http_response.status,
    headers: http_response.headers,
    body: http_response.body,
  )
}

pub fn simple_get_stub_test() {
  let assert Ok(server) =
    http_server_mock.start(http_server_mock.default_config())

  let request_matcher =
    matcher.new()
    |> matcher.method(http.Get)
    |> matcher.path("/hello")
  let stub_response =
    mock_response.new()
    |> mock_response.status(200)
    |> mock_response.body("world")
  let assert Ok(_) =
    http_server_mock.register(server, stub.new(request_matcher, stub_response))

  let http_response = get(http_server_mock.base_url(server) <> "/hello")
  let assert 200 = http_response.status
  let assert "world" = http_response.body

  http_server_mock.stop(server)
}

pub fn unmatched_request_returns_404_test() {
  let assert Ok(server) =
    http_server_mock.start(http_server_mock.default_config())

  let assert 404 = get(http_server_mock.base_url(server) <> "/no-such-path").status

  http_server_mock.stop(server)
}

pub fn stub_with_response_headers_test() {
  let assert Ok(server) =
    http_server_mock.start(http_server_mock.default_config())

  let request_matcher = matcher.new() |> matcher.path("/json-data")
  let stub_response =
    mock_response.new()
    |> mock_response.status(200)
    |> mock_response.header("content-type", "application/json")
    |> mock_response.json_body("{\"ok\":true}")
  let assert Ok(_) =
    http_server_mock.register(server, stub.new(request_matcher, stub_response))

  let http_response = get(http_server_mock.base_url(server) <> "/json-data")
  let assert 200 = http_response.status
  let assert "{\"ok\":true}" = http_response.body
  let content_type =
    http_response.headers
    |> list.key_find("content-type")
    |> result.unwrap("")
  let assert True = content_type |> string.contains("application/json")

  http_server_mock.stop(server)
}

pub fn multiple_stubs_different_paths_test() {
  let assert Ok(server) =
    http_server_mock.start(http_server_mock.default_config())

  let assert Ok(_) =
    http_server_mock.register(
      server,
      stub.new(
        matcher.new() |> matcher.path("/a"),
        mock_response.new() |> mock_response.body("response-a"),
      ),
    )
  let assert Ok(_) =
    http_server_mock.register(
      server,
      stub.new(
        matcher.new() |> matcher.path("/b"),
        mock_response.new() |> mock_response.body("response-b"),
      ),
    )

  let assert "response-a" = get(http_server_mock.base_url(server) <> "/a").body
  let assert "response-b" = get(http_server_mock.base_url(server) <> "/b").body

  http_server_mock.stop(server)
}

pub fn recorded_requests_tracks_calls_test() {
  let assert Ok(server) =
    http_server_mock.start(http_server_mock.default_config())

  let request_matcher = matcher.new() |> matcher.path("/track")
  let assert Ok(_) =
    http_server_mock.register(
      server,
      stub.new(request_matcher, mock_response.new() |> mock_response.body("ok")),
    )

  let _ = get(http_server_mock.base_url(server) <> "/track")
  let _ = get(http_server_mock.base_url(server) <> "/track")

  let assert Ok(recorded_requests) = http_server_mock.recorded_requests(server)
  let tracked =
    list.filter(recorded_requests, fn(recorded) { recorded.path == "/track" })
  let assert 2 = list.length(tracked)

  http_server_mock.stop(server)
}

pub fn verify_called_times_test() {
  let assert Ok(server) =
    http_server_mock.start(http_server_mock.default_config())

  let request_matcher =
    matcher.new() |> matcher.method(http.Get) |> matcher.path("/counted")
  let assert Ok(_) =
    http_server_mock.register(
      server,
      stub.new(
        request_matcher,
        mock_response.new() |> mock_response.body("ok"),
      ),
    )

  let _ = get(http_server_mock.base_url(server) <> "/counted")
  let _ = get(http_server_mock.base_url(server) <> "/counted")
  let _ = get(http_server_mock.base_url(server) <> "/counted")

  let assert Ok(recorded_requests) = http_server_mock.recorded_requests(server)
  verify.called_times(recorded_requests, request_matcher, 3)

  http_server_mock.stop(server)
}

pub fn reset_stubs_removes_all_stubs_test() {
  let assert Ok(server) =
    http_server_mock.start(http_server_mock.default_config())

  let assert Ok(_) =
    http_server_mock.register(
      server,
      stub.new(
        matcher.new() |> matcher.path("/gone"),
        mock_response.new() |> mock_response.body("was here"),
      ),
    )

  let assert 200 = get(http_server_mock.base_url(server) <> "/gone").status
  http_server_mock.reset_stubs(server)
  let assert 404 = get(http_server_mock.base_url(server) <> "/gone").status

  http_server_mock.stop(server)
}

pub fn reset_requests_clears_history_test() {
  let assert Ok(server) =
    http_server_mock.start(http_server_mock.default_config())

  let assert Ok(_) =
    http_server_mock.register(
      server,
      stub.new(
        matcher.new() |> matcher.path("/call"),
        mock_response.new() |> mock_response.body("ok"),
      ),
    )

  let _ = get(http_server_mock.base_url(server) <> "/call")
  http_server_mock.reset_requests(server)

  let assert Ok(recorded_requests) = http_server_mock.recorded_requests(server)
  let assert [] = recorded_requests

  http_server_mock.stop(server)
}

pub fn query_param_matching_test() {
  let assert Ok(server) =
    http_server_mock.start(http_server_mock.default_config())

  let request_matcher =
    matcher.new()
    |> matcher.path("/search")
    |> matcher.query_param("q", "gleam")
  let assert Ok(_) =
    http_server_mock.register(
      server,
      stub.new(
        request_matcher,
        mock_response.new() |> mock_response.body("found"),
      ),
    )

  let assert "found" =
    get(http_server_mock.base_url(server) <> "/search?q=gleam").body
  let assert 404 =
    get(http_server_mock.base_url(server) <> "/search?q=other").status

  http_server_mock.stop(server)
}

pub fn admin_health_endpoint_test() {
  let assert Ok(server) =
    http_server_mock.start(http_server_mock.default_config())

  let http_response =
    get(http_server_mock.base_url(server) <> "/__admin/health")
  let assert 200 = http_response.status
  let assert "{\"status\":\"ok\"}" = http_response.body

  http_server_mock.stop(server)
}

pub fn admin_stubs_list_test() {
  let assert Ok(server) =
    http_server_mock.start(http_server_mock.default_config())

  let assert Ok(_) =
    http_server_mock.register(
      server,
      stub.new(
        matcher.new() |> matcher.path("/listed"),
        mock_response.new() |> mock_response.body("ok"),
      )
        |> stub.with_id("listed-stub"),
    )

  let http_response =
    get(http_server_mock.base_url(server) <> "/__admin/stubs")
  let assert 200 = http_response.status
  let assert True = http_response.body |> string.contains("listed-stub")

  http_server_mock.stop(server)
}

pub fn admin_delete_stubs_test() {
  let assert Ok(server) =
    http_server_mock.start(http_server_mock.default_config())

  let assert Ok(_) =
    http_server_mock.register(
      server,
      stub.new(
        matcher.new() |> matcher.path("/bye"),
        mock_response.new() |> mock_response.body("hi"),
      ),
    )

  let assert 200 = get(http_server_mock.base_url(server) <> "/bye").status
  let assert 200 =
    delete(http_server_mock.base_url(server) <> "/__admin/stubs").status
  let assert 404 = get(http_server_mock.base_url(server) <> "/bye").status

  http_server_mock.stop(server)
}

pub fn post_with_body_matching_test() {
  let assert Ok(server) =
    http_server_mock.start(http_server_mock.default_config())

  let request_matcher =
    matcher.new()
    |> matcher.method(http.Post)
    |> matcher.path("/submit")
    |> matcher.body_containing("important")
  let assert Ok(_) =
    http_server_mock.register(
      server,
      stub.new(request_matcher, mock_response.new() |> mock_response.status(201)),
    )

  let assert 201 =
    post(
      http_server_mock.base_url(server) <> "/submit",
      "{\"important\":true}",
      "application/json",
    ).status

  let assert 404 =
    post(
      http_server_mock.base_url(server) <> "/submit",
      "{\"other\":true}",
      "application/json",
    ).status

  http_server_mock.stop(server)
}
