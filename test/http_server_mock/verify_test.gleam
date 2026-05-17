import gleam/http/request
import gleam/httpc
import gleam/list
import http_server_mock
import http_server_mock/matcher
import http_server_mock/response
import http_server_mock/stub_builder
import http_server_mock/verify

@external(javascript, "./integration_test_ffi.mjs", "syncGet")
fn get(url: String) -> Nil {
  let assert Ok(req) = request.to(url)
  let assert Ok(_) = httpc.send(req)
  Nil
}

pub fn called_returns_matched_requests_test() {
  let server = http_server_mock.new() |> http_server_mock.start()
  let base = http_server_mock.base_url(server)

  let assert Ok(_) =
    http_server_mock.add_stub(
      server,
      stub_builder.new()
        |> stub_builder.matching(matcher.new() |> matcher.path("/hello"))
        |> stub_builder.responding_with(response.ok())
        |> stub_builder.build(),
    )
  let assert Ok(_) =
    http_server_mock.add_stub(
      server,
      stub_builder.new()
        |> stub_builder.matching(matcher.new() |> matcher.path("/other"))
        |> stub_builder.responding_with(response.ok())
        |> stub_builder.build(),
    )

  get(base <> "/hello")
  get(base <> "/other")

  let result = verify.called(server, matcher.new() |> matcher.path("/hello"))
  let assert [req] = result
  assert req.path == "/hello"

  http_server_mock.stop(server)
}

pub fn called_times_returns_matched_when_count_correct_test() {
  let server = http_server_mock.new() |> http_server_mock.start()
  let base = http_server_mock.base_url(server)

  let assert Ok(_) =
    http_server_mock.add_stub(
      server,
      stub_builder.new()
        |> stub_builder.matching(matcher.new() |> matcher.path("/api"))
        |> stub_builder.responding_with(response.ok())
        |> stub_builder.build(),
    )

  get(base <> "/api")
  get(base <> "/api")

  let result =
    verify.called_times(server, matcher.new() |> matcher.path("/api"), 2)
  assert list.length(result) == 2

  http_server_mock.stop(server)
}

pub fn called_at_least_returns_matched_when_enough_test() {
  let server = http_server_mock.new() |> http_server_mock.start()
  let base = http_server_mock.base_url(server)

  let assert Ok(_) =
    http_server_mock.add_stub(
      server,
      stub_builder.new()
        |> stub_builder.matching(matcher.new() |> matcher.path("/x"))
        |> stub_builder.responding_with(response.ok())
        |> stub_builder.build(),
    )

  get(base <> "/x")
  get(base <> "/x")
  get(base <> "/x")

  let result =
    verify.called_at_least(server, matcher.new() |> matcher.path("/x"), 2)
  assert list.length(result) == 3

  http_server_mock.stop(server)
}

pub fn never_called_passes_when_no_requests_made_test() {
  let server = http_server_mock.new() |> http_server_mock.start()

  verify.never_called(server, matcher.new() |> matcher.path("/never"))

  http_server_mock.stop(server)
}
