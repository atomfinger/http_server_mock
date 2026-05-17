import gleam/dict
import gleam/http
import gleam/option.{None, Some}
import http_server_mock/matcher
import http_server_mock/types.{
  type RecordedRequest, AnyString, Contains, Exact, Prefix, Suffix,
  RecordedRequest,
}

fn make_request(method: http.Method, path: String) -> RecordedRequest {
  RecordedRequest(
    id: "test",
    method: method,
    path: path,
    query: None,
    headers: dict.new(),
    body: "",
    timestamp_ms: 0,
    matched_stub_id: None,
  )
}

fn make_request_with_query(
  method: http.Method,
  path: String,
  query_string: String,
) -> RecordedRequest {
  RecordedRequest(
    id: "test",
    method: method,
    path: path,
    query: Some(query_string),
    headers: dict.new(),
    body: "",
    timestamp_ms: 0,
    matched_stub_id: None,
  )
}

fn make_request_with_body(body: String) -> RecordedRequest {
  RecordedRequest(
    id: "test",
    method: http.Post,
    path: "/",
    query: None,
    headers: dict.new(),
    body: body,
    timestamp_ms: 0,
    matched_stub_id: None,
  )
}

pub fn new_matcher_matches_anything_test() {
  let assert True =
    matcher.new()
    |> matcher.matches(make_request(http.Get, "/anything"))
}

pub fn method_matcher_matches_correct_method_test() {
  let assert True =
    matcher.new()
    |> matcher.method(http.Get)
    |> matcher.matches(make_request(http.Get, "/path"))
}

pub fn method_matcher_rejects_wrong_method_test() {
  let assert False =
    matcher.new()
    |> matcher.method(http.Post)
    |> matcher.matches(make_request(http.Get, "/path"))
}

pub fn exact_path_matches_test() {
  let assert True =
    matcher.new()
    |> matcher.path("/api/users")
    |> matcher.matches(make_request(http.Get, "/api/users"))
}

pub fn exact_path_rejects_different_test() {
  let assert False =
    matcher.new()
    |> matcher.path("/api/users")
    |> matcher.matches(make_request(http.Get, "/api/other"))
}

pub fn path_contains_matches_test() {
  let assert True =
    matcher.new()
    |> matcher.path_contains("users")
    |> matcher.matches(make_request(http.Get, "/api/users/123"))
}

pub fn path_contains_rejects_missing_fragment_test() {
  let assert False =
    matcher.new()
    |> matcher.path_contains("orders")
    |> matcher.matches(make_request(http.Get, "/api/users/123"))
}

pub fn path_matching_prefix_test() {
  let assert True =
    matcher.new()
    |> matcher.path_matching(Prefix("/api"))
    |> matcher.matches(make_request(http.Get, "/api/users"))
}

pub fn path_matching_suffix_test() {
  let assert True =
    matcher.new()
    |> matcher.path_matching(Suffix(".json"))
    |> matcher.matches(make_request(http.Get, "/data.json"))
}

pub fn path_matching_any_string_test() {
  let assert True =
    matcher.new()
    |> matcher.path_matching(AnyString)
    |> matcher.matches(make_request(http.Get, "/literally/anything"))
}

pub fn query_param_matches_test() {
  let assert True =
    matcher.new()
    |> matcher.query_param("lang", "en")
    |> matcher.matches(
      make_request_with_query(http.Get, "/search", "lang=en&q=test"),
    )
}

pub fn query_param_rejects_wrong_value_test() {
  let assert False =
    matcher.new()
    |> matcher.query_param("lang", "fr")
    |> matcher.matches(make_request_with_query(http.Get, "/search", "lang=en"))
}

pub fn query_param_rejects_missing_key_test() {
  let assert False =
    matcher.new()
    |> matcher.query_param("lang", "en")
    |> matcher.matches(make_request(http.Get, "/search"))
}

pub fn header_matches_test() {
  let headers = dict.from_list([#("content-type", "application/json")])
  let recorded_request =
    RecordedRequest(
      id: "t",
      method: http.Post,
      path: "/",
      query: None,
      headers: headers,
      body: "",
      timestamp_ms: 0,
      matched_stub_id: None,
    )
  let assert True =
    matcher.new()
    |> matcher.header("content-type", "application/json")
    |> matcher.matches(recorded_request)
}

pub fn header_case_insensitive_key_test() {
  let headers = dict.from_list([#("content-type", "application/json")])
  let recorded_request =
    RecordedRequest(
      id: "t",
      method: http.Post,
      path: "/",
      query: None,
      headers: headers,
      body: "",
      timestamp_ms: 0,
      matched_stub_id: None,
    )
  let assert True =
    matcher.new()
    |> matcher.header("Content-Type", "application/json")
    |> matcher.matches(recorded_request)
}

pub fn body_exact_matches_test() {
  let assert True =
    matcher.new()
    |> matcher.body_equal_to("{\"key\":\"val\"}")
    |> matcher.matches(make_request_with_body("{\"key\":\"val\"}"))
}

pub fn body_exact_rejects_different_test() {
  let assert False =
    matcher.new()
    |> matcher.body_equal_to("{\"key\":\"val\"}")
    |> matcher.matches(make_request_with_body("{\"key\":\"other\"}"))
}

pub fn body_containing_matches_test() {
  let assert True =
    matcher.new()
    |> matcher.body_containing("hello")
    |> matcher.matches(make_request_with_body("say hello world"))
}

pub fn body_json_matches_ignoring_whitespace_test() {
  let assert True =
    matcher.new()
    |> matcher.body_json("{\"a\":1}")
    |> matcher.matches(make_request_with_body("{ \"a\" : 1 }"))
}

pub fn combined_matcher_all_must_match_test() {
  let assert True =
    matcher.new()
    |> matcher.method(http.Post)
    |> matcher.path("/submit")
    |> matcher.body_containing("data")
    |> matcher.matches(
      RecordedRequest(
        id: "t",
        method: http.Post,
        path: "/submit",
        query: None,
        headers: dict.new(),
        body: "submit data here",
        timestamp_ms: 0,
        matched_stub_id: None,
      ),
    )
}

pub fn combined_matcher_partial_miss_fails_test() {
  let assert False =
    matcher.new()
    |> matcher.method(http.Post)
    |> matcher.path("/submit")
    |> matcher.matches(make_request(http.Get, "/submit"))
}

pub fn apply_string_matcher_exact_test() {
  let assert True = matcher.apply_string_matcher(Exact("hello"), "hello")
  let assert False = matcher.apply_string_matcher(Exact("hello"), "world")
}

pub fn apply_string_matcher_contains_test() {
  let assert True = matcher.apply_string_matcher(Contains("ell"), "hello")
  let assert False = matcher.apply_string_matcher(Contains("xyz"), "hello")
}

pub fn apply_string_matcher_prefix_test() {
  let assert True = matcher.apply_string_matcher(Prefix("hel"), "hello")
  let assert False = matcher.apply_string_matcher(Prefix("llo"), "hello")
}

pub fn apply_string_matcher_suffix_test() {
  let assert True = matcher.apply_string_matcher(Suffix("llo"), "hello")
  let assert False = matcher.apply_string_matcher(Suffix("hel"), "hello")
}

pub fn apply_string_matcher_any_test() {
  let assert True = matcher.apply_string_matcher(AnyString, "")
  let assert True = matcher.apply_string_matcher(AnyString, "anything")
}
