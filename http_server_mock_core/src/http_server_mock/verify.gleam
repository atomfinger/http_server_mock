//// Assertion helpers for verifying that the mock server received the expected
//// requests.
////
//// Each function accepts a running server and a `RequestMatcher` describing
//// which requests to count. On failure the functions panic with a descriptive
//// message that includes the matcher, the expected and actual counts, and a
//// list of all recorded requests.
////
//// ```gleam
//// verify.called_times(server, m, 1)
//// verify.never_called(server, other_matcher)
//// ```

import gleam/http
import gleam/int
import gleam/list
import gleam/option
import gleam/string
import http_server_mock/internal/server.{type MockServer, type Started}
import http_server_mock/matcher
import http_server_mock/types.{type RecordedRequest, type RequestMatcher}

/// Asserts that at least one recorded request matches `request_matcher`.
///
/// Returns the matching requests so you can chain further assertions.
/// Panics with a descriptive message if no matching request was recorded.
pub fn called(
  mock_server: MockServer(Started),
  request_matcher: RequestMatcher,
) -> List(RecordedRequest) {
  let recorded_requests = fetch_requests(mock_server)
  let matched =
    list.filter(recorded_requests, matcher.matches(request_matcher, _))
  case matched {
    [] ->
      panic as {
        "Expected at least one matching request but got none.\n"
        <> format_matcher(request_matcher)
        <> "\nRecorded requests:\n"
        <> format_requests(recorded_requests)
      }
    _ -> matched
  }
}

/// Asserts that exactly `count` recorded requests match `request_matcher`.
///
/// Returns the matching requests so you can chain further assertions.
/// Panics with a descriptive message if the actual count differs from `count`.
pub fn called_times(
  mock_server: MockServer(Started),
  request_matcher: RequestMatcher,
  count: Int,
) -> List(RecordedRequest) {
  let recorded_requests = fetch_requests(mock_server)
  let matched =
    list.filter(recorded_requests, matcher.matches(request_matcher, _))
  let matched_count = list.length(matched)
  case matched_count == count {
    True -> matched
    False ->
      panic as {
        "Expected "
        <> int.to_string(count)
        <> " matching request(s) but got "
        <> int.to_string(matched_count)
        <> ".\n"
        <> format_matcher(request_matcher)
        <> "\nRecorded requests:\n"
        <> format_requests(recorded_requests)
      }
  }
}

/// Asserts that at least `count` recorded requests match `request_matcher`.
///
/// Returns the matching requests so you can chain further assertions.
/// Panics with a descriptive message if fewer than `count` requests matched.
pub fn called_at_least(
  mock_server: MockServer(Started),
  request_matcher: RequestMatcher,
  count: Int,
) -> List(RecordedRequest) {
  let recorded_requests = fetch_requests(mock_server)
  let matched =
    list.filter(recorded_requests, matcher.matches(request_matcher, _))
  let matched_count = list.length(matched)
  case matched_count >= count {
    True -> matched
    False ->
      panic as {
        "Expected at least "
        <> int.to_string(count)
        <> " matching request(s) but got "
        <> int.to_string(matched_count)
        <> ".\n"
        <> format_matcher(request_matcher)
        <> "\nRecorded requests:\n"
        <> format_requests(recorded_requests)
      }
  }
}

/// Asserts that no recorded request matches `request_matcher`.
///
/// Panics with a descriptive message (including the unexpected requests) if
/// any matching request was recorded.
pub fn never_called(
  mock_server: MockServer(Started),
  request_matcher: RequestMatcher,
) -> Nil {
  let recorded_requests = fetch_requests(mock_server)
  let matched =
    list.filter(recorded_requests, matcher.matches(request_matcher, _))
  case matched {
    [] -> Nil
    _ ->
      panic as {
        "Expected no matching requests but got "
        <> int.to_string(list.length(matched))
        <> ".\n"
        <> format_matcher(request_matcher)
        <> "\nMatched requests:\n"
        <> format_requests(matched)
      }
  }
}

fn fetch_requests(mock_server: MockServer(Started)) -> List(RecordedRequest) {
  case server.recorded_requests(mock_server) {
    Ok(requests) -> requests
    Error(reason) ->
      panic as { "Failed to fetch recorded requests: " <> reason }
  }
}

fn format_matcher(request_matcher: RequestMatcher) -> String {
  let method = case request_matcher.method {
    option.None -> "ANY"
    option.Some(method) -> http.method_to_string(method) |> string.uppercase
  }
  let path = case request_matcher.path {
    option.None -> "ANY PATH"
    option.Some(types.Exact(path)) -> path
    option.Some(types.Contains(fragment)) -> "CONTAINS " <> fragment
    option.Some(types.Prefix(prefix)) -> "PREFIX " <> prefix
    option.Some(types.Suffix(suffix)) -> "SUFFIX " <> suffix
    option.Some(types.AnyString) -> "ANY PATH"
  }
  "Matcher: " <> method <> " " <> path
}

fn format_requests(recorded_requests: List(RecordedRequest)) -> String {
  case recorded_requests {
    [] -> "  (none)"
    _ ->
      recorded_requests
      |> list.map(fn(recorded_request) {
        "  "
        <> http.method_to_string(recorded_request.method) |> string.uppercase
        <> " "
        <> recorded_request.path
        <> case recorded_request.query {
          option.None -> ""
          option.Some(query_string) -> "?" <> query_string
        }
      })
      |> string.join("\n")
  }
}
