import gleam/dict
import gleam/http
import gleam/option.{None, Some}
import http_server_mock/matcher
import http_server_mock/response
import http_server_mock/router
import http_server_mock/stub
import http_server_mock/types.{type RecordedRequest, RecordedRequest}

fn make_get_request(path: String) -> RecordedRequest {
  RecordedRequest(
    id: "test",
    method: http.Get,
    path: path,
    query: None,
    headers: dict.new(),
    body: "",
    timestamp_ms: 0,
    matched_stub_id: None,
  )
}

fn make_stub(request_matcher: types.RequestMatcher) -> types.Stub {
  stub.new(request_matcher, response.ok())
}

pub fn find_match_returns_none_when_no_stubs_test() {
  let assert None = router.find_match([], dict.new(), make_get_request("/path"))
}

pub fn find_match_returns_stub_when_matches_test() {
  let request_matcher = matcher.new() |> matcher.path("/hello")
  let the_stub = make_stub(request_matcher)
  let assert Some(_) =
    router.find_match([the_stub], dict.new(), make_get_request("/hello"))
}

pub fn find_match_returns_none_when_path_differs_test() {
  let request_matcher = matcher.new() |> matcher.path("/hello")
  let the_stub = make_stub(request_matcher)
  let assert None =
    router.find_match([the_stub], dict.new(), make_get_request("/world"))
}

pub fn find_match_picks_higher_score_over_lower_test() {
  let exact_stub =
    make_stub(matcher.new() |> matcher.path("/api/users")) |> stub.with_id("exact")
  let contains_stub =
    make_stub(matcher.new() |> matcher.path_contains("users"))
    |> stub.with_id("contains")

  let assert Some(#(matched_stub, _)) =
    router.find_match(
      [contains_stub, exact_stub],
      dict.new(),
      make_get_request("/api/users"),
    )
  let assert "exact" = matched_stub.id
}

pub fn find_match_priority_overrides_score_test() {
  let high_priority_stub =
    make_stub(matcher.new() |> matcher.path_contains("users"))
    |> stub.with_id("high")
    |> stub.with_priority(1)
  let low_priority_stub =
    make_stub(matcher.new() |> matcher.path("/api/users"))
    |> stub.with_id("low")
    |> stub.with_priority(5)

  let assert Some(#(matched_stub, _)) =
    router.find_match(
      [low_priority_stub, high_priority_stub],
      dict.new(),
      make_get_request("/api/users"),
    )
  let assert "high" = matched_stub.id
}

pub fn score_returns_none_when_no_match_test() {
  let the_stub = make_stub(matcher.new() |> matcher.path("/specific"))
  let assert None = router.score(the_stub, dict.new(), make_get_request("/other"))
}

pub fn score_returns_some_when_matches_test() {
  let the_stub = make_stub(matcher.new() |> matcher.path("/specific"))
  let assert Some(_) =
    router.score(the_stub, dict.new(), make_get_request("/specific"))
}

pub fn score_exact_path_higher_than_wildcard_test() {
  let exact_stub = make_stub(matcher.new() |> matcher.path("/users"))
  let any_stub = make_stub(matcher.new())

  let assert Some(exact_value) =
    router.score(exact_stub, dict.new(), make_get_request("/users"))
  let assert Some(any_value) =
    router.score(any_stub, dict.new(), make_get_request("/users"))
  let assert True = exact_value > any_value
}

pub fn scenario_blocks_unmatched_state_test() {
  let the_stub =
    make_stub(matcher.new() |> matcher.path("/order"))
    |> stub.in_scenario("checkout")
    |> stub.when_state_is("confirmed")

  let scenarios = dict.from_list([#("checkout", "pending")])
  let assert None =
    router.find_match([the_stub], scenarios, make_get_request("/order"))
}

pub fn scenario_matches_correct_state_test() {
  let the_stub =
    make_stub(matcher.new() |> matcher.path("/order"))
    |> stub.in_scenario("checkout")
    |> stub.when_state_is("confirmed")

  let scenarios = dict.from_list([#("checkout", "confirmed")])
  let assert Some(_) =
    router.find_match([the_stub], scenarios, make_get_request("/order"))
}

pub fn scenario_initial_state_requires_no_entry_test() {
  let the_stub =
    make_stub(matcher.new() |> matcher.path("/start")) |> stub.in_scenario("flow")

  let assert Some(_) =
    router.find_match([the_stub], dict.new(), make_get_request("/start"))
}

pub fn scenario_initial_state_fails_if_scenario_active_test() {
  let the_stub =
    make_stub(matcher.new() |> matcher.path("/start")) |> stub.in_scenario("flow")

  let scenarios = dict.from_list([#("flow", "step2")])
  let assert None =
    router.find_match([the_stub], scenarios, make_get_request("/start"))
}
