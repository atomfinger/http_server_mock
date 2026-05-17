//// Builder for `RequestMatcher` — the rules that decide whether an incoming
//// request should be handled by a given stub.
////
//// Start with `new()` and pipe through the constraint functions you need.
//// Constraints that are not set match anything, so a `new()` with no
//// constraints will match every request.
////
//// ```gleam
//// let m =
////   matcher.new()
////   |> matcher.method(http.Post)
////   |> matcher.path("/orders")
////   |> matcher.header("x-api-key", "secret")
////   |> matcher.body_json("{\"amount\":100}")
//// ```

import gleam/dict
import gleam/http.{type Method}
import gleam/list
import gleam/option.{None, Some}
import gleam/string
import http_server_mock/types.{
  type BodyMatcher, type RecordedRequest, type RequestMatcher,
  type StringMatcher, AnyBody, AnyString, ContainsBody, Contains, Exact,
  ExactBody, JsonBody, Prefix, RequestMatcher, Suffix,
}

/// Returns a new `RequestMatcher` with no constraints — matches every request.
pub fn new() -> RequestMatcher {
  RequestMatcher(
    method: None,
    path: None,
    query_params: [],
    headers: [],
    body: AnyBody,
  )
}

/// Constrains the matcher to only match requests with the given HTTP method.
pub fn method(request_matcher: RequestMatcher, method: Method) -> RequestMatcher {
  RequestMatcher(..request_matcher, method: Some(method))
}

/// Constrains the matcher to only match requests whose path is exactly equal
/// to `path`.
///
/// Use `path_matching` or `path_contains` for partial matches.
pub fn path(request_matcher: RequestMatcher, path: String) -> RequestMatcher {
  RequestMatcher(..request_matcher, path: Some(Exact(path)))
}

/// Constrains the matcher to only match requests whose path satisfies the
/// given `StringMatcher`.
///
/// Use this when you need `Contains`, `Prefix`, or `Suffix` path matching
/// instead of an exact match.
pub fn path_matching(
  request_matcher: RequestMatcher,
  string_matcher: StringMatcher,
) -> RequestMatcher {
  RequestMatcher(..request_matcher, path: Some(string_matcher))
}

/// Constrains the matcher to only match requests whose path contains
/// `fragment` as a substring.
pub fn path_contains(
  request_matcher: RequestMatcher,
  fragment: String,
) -> RequestMatcher {
  RequestMatcher(..request_matcher, path: Some(Contains(fragment)))
}

/// Constrains the matcher to only match requests that have the query parameter
/// `key` set to exactly `value`.
///
/// Can be called multiple times to require several query parameters.
pub fn query_param(
  request_matcher: RequestMatcher,
  key: String,
  value: String,
) -> RequestMatcher {
  RequestMatcher(
    ..request_matcher,
    query_params: [#(key, Exact(value)), ..request_matcher.query_params],
  )
}

/// Constrains the matcher to only match requests that have the query parameter
/// `key` satisfying the given `StringMatcher`.
///
/// Can be called multiple times to require several query parameters.
pub fn query_param_matching(
  request_matcher: RequestMatcher,
  key: String,
  string_matcher: StringMatcher,
) -> RequestMatcher {
  RequestMatcher(
    ..request_matcher,
    query_params: [#(key, string_matcher), ..request_matcher.query_params],
  )
}

/// Constrains the matcher to only match requests that have the header `key`
/// set to exactly `value`. Header names are compared case-insensitively.
///
/// Can be called multiple times to require several headers.
pub fn header(
  request_matcher: RequestMatcher,
  key: String,
  value: String,
) -> RequestMatcher {
  RequestMatcher(
    ..request_matcher,
    headers: [#(string.lowercase(key), Exact(value)), ..request_matcher.headers],
  )
}

/// Constrains the matcher to only match requests that have the header `key`
/// satisfying the given `StringMatcher`. Header names are compared
/// case-insensitively.
///
/// Can be called multiple times to require several headers.
pub fn header_matching(
  request_matcher: RequestMatcher,
  key: String,
  string_matcher: StringMatcher,
) -> RequestMatcher {
  RequestMatcher(
    ..request_matcher,
    headers: [
      #(string.lowercase(key), string_matcher),
      ..request_matcher.headers
    ],
  )
}

/// Constrains the matcher to only match requests whose body is exactly equal
/// to `body`.
pub fn body_equal_to(
  request_matcher: RequestMatcher,
  body: String,
) -> RequestMatcher {
  RequestMatcher(..request_matcher, body: ExactBody(body))
}

/// Constrains the matcher to only match requests whose body contains
/// `fragment` as a substring.
pub fn body_containing(
  request_matcher: RequestMatcher,
  fragment: String,
) -> RequestMatcher {
  RequestMatcher(..request_matcher, body: ContainsBody(fragment))
}

/// Constrains the matcher to only match requests whose body is semantically
/// equal to `json` when both are parsed as JSON (whitespace and key order are
/// ignored).
pub fn body_json(
  request_matcher: RequestMatcher,
  json: String,
) -> RequestMatcher {
  RequestMatcher(..request_matcher, body: JsonBody(json))
}

/// Constrains the matcher using a custom `BodyMatcher`.
///
/// Use this when none of the convenience functions (`body_equal_to`,
/// `body_containing`, `body_json`) cover your use case.
pub fn body_matcher(
  request_matcher: RequestMatcher,
  body_matcher: BodyMatcher,
) -> RequestMatcher {
  RequestMatcher(..request_matcher, body: body_matcher)
}

/// Returns `True` if `recorded_request` satisfies all constraints on
/// `request_matcher`.
///
/// This is the same matching logic the server uses internally. You can call it
/// directly when filtering `recorded_requests` for custom assertions.
pub fn matches(request_matcher: RequestMatcher, recorded_request: RecordedRequest) -> Bool {
  method_matches(request_matcher.method, recorded_request.method)
  && path_matches(request_matcher.path, recorded_request.path)
  && query_params_match(request_matcher.query_params, recorded_request.query)
  && headers_match(request_matcher.headers, recorded_request.headers)
  && body_matches(request_matcher.body, recorded_request.body)
}

fn method_matches(
  expected: option.Option(Method),
  actual: Method,
) -> Bool {
  case expected {
    None -> True
    Some(method) -> method == actual
  }
}

fn path_matches(
  expected: option.Option(StringMatcher),
  actual: String,
) -> Bool {
  case expected {
    None -> True
    Some(string_matcher) -> apply_string_matcher(string_matcher, actual)
  }
}

fn query_params_match(
  expected: List(#(String, StringMatcher)),
  query_string: option.Option(String),
) -> Bool {
  case expected {
    [] -> True
    _ -> {
      let params = parse_query(query_string)
      list.all(expected, fn(query_param_pair) {
        let #(key, string_matcher) = query_param_pair
        case list.key_find(params, key) {
          Ok(value) -> apply_string_matcher(string_matcher, value)
          Error(Nil) -> string_matcher == AnyString
        }
      })
    }
  }
}

fn headers_match(
  expected: List(#(String, StringMatcher)),
  actual: dict.Dict(String, String),
) -> Bool {
  list.all(expected, fn(header_pair) {
    let #(key, string_matcher) = header_pair
    case dict.get(actual, string.lowercase(key)) {
      Ok(value) -> apply_string_matcher(string_matcher, value)
      Error(Nil) -> string_matcher == AnyString
    }
  })
}

fn body_matches(expected: BodyMatcher, actual: String) -> Bool {
  case expected {
    AnyBody -> True
    ExactBody(body) -> actual == body
    ContainsBody(fragment) -> string.contains(actual, fragment)
    JsonBody(expected_json) ->
      normalize_json(actual) == normalize_json(expected_json)
  }
}

/// Applies a `StringMatcher` to `value`, returning `True` if it matches.
///
/// Exposed for use in custom filtering logic over `recorded_requests`.
pub fn apply_string_matcher(string_matcher: StringMatcher, value: String) -> Bool {
  case string_matcher {
    Exact(expected) -> value == expected
    Contains(fragment) -> string.contains(value, fragment)
    Prefix(prefix) -> string.starts_with(value, prefix)
    Suffix(suffix) -> string.ends_with(value, suffix)
    AnyString -> True
  }
}

fn parse_query(query_string: option.Option(String)) -> List(#(String, String)) {
  case query_string {
    None -> []
    Some(query) ->
      query
      |> string.split("&")
      |> list.filter_map(fn(part) {
        case string.split_once(part, "=") {
          Ok(#(key, value)) -> Ok(#(key, value))
          Error(Nil) -> Ok(#(part, ""))
        }
      })
  }
}

fn normalize_json(json_string: String) -> String {
  json_string
  |> string.replace(" ", "")
  |> string.replace("\n", "")
  |> string.replace("\t", "")
  |> string.replace("\r", "")
}
