import gleam/dict
import gleam/http
import gleam/list
import gleam/option.{None}
import http_server_mock/matcher
import http_server_mock/types.{type RecordedRequest, RecordedRequest}
import http_server_mock/verify

fn make_recorded_request(
  method: http.Method,
  path: String,
) -> RecordedRequest {
  RecordedRequest(
    id: "req",
    method: method,
    path: path,
    query: None,
    headers: dict.new(),
    body: "",
    timestamp_ms: 0,
    matched_stub_id: None,
  )
}

pub fn called_returns_matched_requests_test() {
  let recorded_requests = [
    make_recorded_request(http.Get, "/hello"),
    make_recorded_request(http.Post, "/other"),
  ]
  let request_matcher = matcher.new() |> matcher.path("/hello")
  let result = verify.called(recorded_requests, request_matcher)
  let assert [req] = result
  let assert "/hello" = req.path
}

pub fn called_times_returns_matched_when_count_correct_test() {
  let recorded_requests = [
    make_recorded_request(http.Get, "/api"),
    make_recorded_request(http.Get, "/api"),
    make_recorded_request(http.Get, "/other"),
  ]
  let request_matcher = matcher.new() |> matcher.path("/api")
  let result = verify.called_times(recorded_requests, request_matcher, 2)
  let assert 2 = list.length(result)
}

pub fn called_at_least_returns_matched_when_enough_test() {
  let recorded_requests = [
    make_recorded_request(http.Get, "/x"),
    make_recorded_request(http.Get, "/x"),
    make_recorded_request(http.Get, "/x"),
  ]
  let request_matcher = matcher.new() |> matcher.path("/x")
  let result = verify.called_at_least(recorded_requests, request_matcher, 2)
  let assert 3 = list.length(result)
}

pub fn never_called_returns_nil_when_no_match_test() {
  let recorded_requests = [make_recorded_request(http.Get, "/safe")]
  let request_matcher = matcher.new() |> matcher.path("/never")
  verify.never_called(recorded_requests, request_matcher)
}
