import gleam/http
import gleam/http/request.{type Request}
import gleam/http/response
import gleam/option.{None, Some}
import http_server_mock/internal/router.{type Stub}

fn make_get_request(path: String) -> Request(String) {
  request.new() |> request.set_method(http.Get) |> request.set_path(path)
}

fn make_stub(label: String, path: String) -> Stub {
  router.Stub(handle: fn(req) {
    case req.path == path {
      True -> Ok(response.new(200) |> response.set_body(label))
      False -> Error(Nil)
    }
  })
}

pub fn find_match_returns_none_when_no_stubs_test() {
  let assert None = router.find_match([], make_get_request("/path"))
}

pub fn find_match_returns_stub_when_matches_test() {
  let the_stub = make_stub("hello", "/hello")
  let assert Some(#(matched_stub, response)) =
    router.find_match([the_stub], make_get_request("/hello"))
  assert matched_stub == the_stub
  let assert "hello" = response.body
}

pub fn find_match_returns_none_when_path_differs_test() {
  let the_stub = make_stub("hello", "/hello")
  let assert None = router.find_match([the_stub], make_get_request("/world"))
}

pub fn find_match_first_registered_wins_test() {
  let first = make_stub("first", "/api/users")
  let second = make_stub("second", "/api/users")

  let assert Some(#(matched_stub, response)) =
    router.find_match([first, second], make_get_request("/api/users"))
  assert matched_stub == first
  let assert "first" = response.body
}
