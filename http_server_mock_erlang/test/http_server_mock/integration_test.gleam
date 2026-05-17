import gleam/http
import gleam/http/request
import gleam/httpc
import gleam/list
import gleam/option
import gleam/result
import gleam/string
import http_server_mock
import http_server_mock/matcher
import http_server_mock/response as mock_response
import http_server_mock/stub_builder
import http_server_mock/verify
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
  let server =
    http_server_mock.new(http_server_mock_erlang.server())
    |> http_server_mock.start()

  let assert Ok(_) =
    http_server_mock.add_stub(
      server,
      stub_builder.new()
        |> stub_builder.matching(
          matcher.new() |> matcher.method(http.Get) |> matcher.path("/hello"),
        )
        |> stub_builder.responding_with(
          mock_response.new()
          |> mock_response.status(200)
          |> mock_response.body("world"),
        )
        |> stub_builder.build(),
    )

  let http_response = get(http_server_mock.base_url(server) <> "/hello")
  assert http_response.status == 200
  assert http_response.body == "world"

  http_server_mock.stop(server)
}

pub fn unmatched_request_returns_404_test() {
  let server =
    http_server_mock.new(http_server_mock_erlang.server())
    |> http_server_mock.start()

  assert get(http_server_mock.base_url(server) <> "/no-such-path").status == 404

  http_server_mock.stop(server)
}

pub fn stub_with_response_headers_test() {
  let server =
    http_server_mock.new(http_server_mock_erlang.server())
    |> http_server_mock.start()

  let assert Ok(_) =
    http_server_mock.add_stub(
      server,
      stub_builder.new()
        |> stub_builder.matching(matcher.new() |> matcher.path("/json-data"))
        |> stub_builder.responding_with(
          mock_response.new()
          |> mock_response.status(200)
          |> mock_response.header("content-type", "application/json")
          |> mock_response.json_body("{\"ok\":true}"),
        )
        |> stub_builder.build(),
    )

  let http_response = get(http_server_mock.base_url(server) <> "/json-data")
  assert http_response.status == 200
  assert http_response.body == "{\"ok\":true}"
  let content_type =
    http_response.headers
    |> list.key_find("content-type")
    |> result.unwrap("")
  assert string.contains(content_type, "application/json")

  http_server_mock.stop(server)
}

pub fn multiple_stubs_different_paths_test() {
  let server =
    http_server_mock.new(http_server_mock_erlang.server())
    |> http_server_mock.start()

  let assert Ok(_) =
    http_server_mock.add_stub(
      server,
      stub_builder.new()
        |> stub_builder.matching(matcher.new() |> matcher.path("/a"))
        |> stub_builder.responding_with(
          mock_response.new() |> mock_response.body("response-a"),
        )
        |> stub_builder.build(),
    )
  let assert Ok(_) =
    http_server_mock.add_stub(
      server,
      stub_builder.new()
        |> stub_builder.matching(matcher.new() |> matcher.path("/b"))
        |> stub_builder.responding_with(
          mock_response.new() |> mock_response.body("response-b"),
        )
        |> stub_builder.build(),
    )

  assert get(http_server_mock.base_url(server) <> "/a").body == "response-a"
  assert get(http_server_mock.base_url(server) <> "/b").body == "response-b"

  http_server_mock.stop(server)
}

pub fn recorded_requests_tracks_calls_test() {
  let server =
    http_server_mock.new(http_server_mock_erlang.server())
    |> http_server_mock.start()

  let assert Ok(_) =
    http_server_mock.add_stub(
      server,
      stub_builder.new()
        |> stub_builder.matching(matcher.new() |> matcher.path("/track"))
        |> stub_builder.responding_with(
          mock_response.new() |> mock_response.body("ok"),
        )
        |> stub_builder.build(),
    )

  let _ = get(http_server_mock.base_url(server) <> "/track")
  let _ = get(http_server_mock.base_url(server) <> "/track")

  let assert Ok(recorded_requests) = http_server_mock.recorded_requests(server)
  let tracked =
    list.filter(recorded_requests, fn(recorded) { recorded.path == "/track" })
  assert list.length(tracked) == 2

  http_server_mock.stop(server)
}

pub fn verify_called_times_test() {
  let server =
    http_server_mock.new(http_server_mock_erlang.server())
    |> http_server_mock.start()

  let request_matcher =
    matcher.new() |> matcher.method(http.Get) |> matcher.path("/counted")
  let assert Ok(_) =
    http_server_mock.add_stub(
      server,
      stub_builder.new()
        |> stub_builder.matching(request_matcher)
        |> stub_builder.responding_with(
          mock_response.new() |> mock_response.body("ok"),
        )
        |> stub_builder.build(),
    )

  let _ = get(http_server_mock.base_url(server) <> "/counted")
  let _ = get(http_server_mock.base_url(server) <> "/counted")
  let _ = get(http_server_mock.base_url(server) <> "/counted")

  verify.called_times(server, request_matcher, 3)

  http_server_mock.stop(server)
}

pub fn reset_stubs_removes_all_stubs_test() {
  let server =
    http_server_mock.new(http_server_mock_erlang.server())
    |> http_server_mock.start()

  let assert Ok(_) =
    http_server_mock.add_stub(
      server,
      stub_builder.new()
        |> stub_builder.matching(matcher.new() |> matcher.path("/gone"))
        |> stub_builder.responding_with(
          mock_response.new() |> mock_response.body("was here"),
        )
        |> stub_builder.build(),
    )

  assert get(http_server_mock.base_url(server) <> "/gone").status == 200
  http_server_mock.reset_stubs(server)
  assert get(http_server_mock.base_url(server) <> "/gone").status == 404

  http_server_mock.stop(server)
}

pub fn reset_requests_clears_history_test() {
  let server =
    http_server_mock.new(http_server_mock_erlang.server())
    |> http_server_mock.start()

  let assert Ok(_) =
    http_server_mock.add_stub(
      server,
      stub_builder.new()
        |> stub_builder.matching(matcher.new() |> matcher.path("/call"))
        |> stub_builder.responding_with(
          mock_response.new() |> mock_response.body("ok"),
        )
        |> stub_builder.build(),
    )

  let _ = get(http_server_mock.base_url(server) <> "/call")
  http_server_mock.reset_requests(server)

  let assert Ok(recorded_requests) = http_server_mock.recorded_requests(server)
  assert recorded_requests == []

  http_server_mock.stop(server)
}

pub fn query_param_matching_test() {
  let server =
    http_server_mock.new(http_server_mock_erlang.server())
    |> http_server_mock.start()

  let request_matcher =
    matcher.new()
    |> matcher.path("/search")
    |> matcher.query_param("q", "gleam")
  let assert Ok(_) =
    http_server_mock.add_stub(
      server,
      stub_builder.new()
        |> stub_builder.matching(request_matcher)
        |> stub_builder.responding_with(
          mock_response.new() |> mock_response.body("found"),
        )
        |> stub_builder.build(),
    )

  assert get(http_server_mock.base_url(server) <> "/search?q=gleam").body
    == "found"
  assert get(http_server_mock.base_url(server) <> "/search?q=other").status
    == 404

  http_server_mock.stop(server)
}

pub fn admin_health_endpoint_test() {
  let server =
    http_server_mock.new(http_server_mock_erlang.server())
    |> http_server_mock.start()

  let http_response =
    get(http_server_mock.base_url(server) <> "/__admin/health")
  assert http_response.status == 200
  assert http_response.body == "{\"status\":\"ok\"}"

  http_server_mock.stop(server)
}

pub fn admin_stubs_list_test() {
  let server =
    http_server_mock.new(http_server_mock_erlang.server())
    |> http_server_mock.start()

  let assert Ok(_) =
    http_server_mock.add_stub(
      server,
      stub_builder.new()
        |> stub_builder.matching(matcher.new() |> matcher.path("/listed"))
        |> stub_builder.responding_with(
          mock_response.new() |> mock_response.body("ok"),
        )
        |> stub_builder.with_id("listed-stub")
        |> stub_builder.build(),
    )

  let http_response = get(http_server_mock.base_url(server) <> "/__admin/stubs")
  assert http_response.status == 200
  assert string.contains(http_response.body, "listed-stub")

  http_server_mock.stop(server)
}

pub fn admin_delete_stubs_test() {
  let server =
    http_server_mock.new(http_server_mock_erlang.server())
    |> http_server_mock.start()

  let assert Ok(_) =
    http_server_mock.add_stub(
      server,
      stub_builder.new()
        |> stub_builder.matching(matcher.new() |> matcher.path("/bye"))
        |> stub_builder.responding_with(
          mock_response.new() |> mock_response.body("hi"),
        )
        |> stub_builder.build(),
    )

  assert get(http_server_mock.base_url(server) <> "/bye").status == 200
  assert delete(http_server_mock.base_url(server) <> "/__admin/stubs").status
    == 200
  assert get(http_server_mock.base_url(server) <> "/bye").status == 404

  http_server_mock.stop(server)
}

pub fn unmatched_requests_test() {
  let server =
    http_server_mock.new(http_server_mock_erlang.server())
    |> http_server_mock.start()

  let assert Ok(_) =
    http_server_mock.add_stub(
      server,
      stub_builder.new()
        |> stub_builder.matching(matcher.new() |> matcher.path("/known"))
        |> stub_builder.responding_with(mock_response.ok())
        |> stub_builder.build(),
    )

  let _ = get(http_server_mock.base_url(server) <> "/known")
  let _ = get(http_server_mock.base_url(server) <> "/unknown-a")
  let _ = get(http_server_mock.base_url(server) <> "/unknown-b")

  let assert Ok(unmatched) = http_server_mock.unmatched_requests(server)
  assert list.length(unmatched) == 2
  assert list.all(unmatched, fn(req) { req.matched_stub_id == option.None })

  http_server_mock.stop(server)
}

pub fn post_with_body_matching_test() {
  let server =
    http_server_mock.new(http_server_mock_erlang.server())
    |> http_server_mock.start()

  let request_matcher =
    matcher.new()
    |> matcher.method(http.Post)
    |> matcher.path("/submit")
    |> matcher.body_containing("important")
  let assert Ok(_) =
    http_server_mock.add_stub(
      server,
      stub_builder.new()
        |> stub_builder.matching(request_matcher)
        |> stub_builder.responding_with(
          mock_response.new() |> mock_response.status(201),
        )
        |> stub_builder.build(),
    )

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

  http_server_mock.stop(server)
}
