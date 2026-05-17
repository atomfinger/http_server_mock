import gleam/dict
import gleam/http
import gleam/list
import gleam/option.{Some}
import http_server_mock/json_codec
import http_server_mock/matcher
import http_server_mock/response
import http_server_mock/stub
import http_server_mock/types.{
  type Stub, AnyBody, AnyString, Contains,
  Exact, ExactBody, JsonBody, Prefix, RecordedRequest, StringBody, Suffix,
}

fn roundtrip_stub(the_stub: Stub) -> Stub {
  let json_string = json_codec.encode_stub(the_stub)
  let assert Ok(decoded) = json_codec.decode_stub(json_string)
  decoded
}

pub fn encode_decode_minimal_stub_test() {
  let the_stub =
    stub.new(matcher.new(), response.ok()) |> stub.with_id("test-id")
  let roundtrip_result = roundtrip_stub(the_stub)
  let assert "test-id" = roundtrip_result.id
  let assert 200 = roundtrip_result.response.status
}

pub fn encode_decode_stub_with_method_and_path_test() {
  let the_stub =
    stub.new(
      matcher.new() |> matcher.method(http.Post) |> matcher.path("/api/data"),
      response.new() |> response.status(201),
    )
    |> stub.with_id("post-stub")
  let roundtrip_result = roundtrip_stub(the_stub)
  let assert Some(http.Post) = roundtrip_result.matcher.method
  let assert Some(Exact("/api/data")) = roundtrip_result.matcher.path
}

pub fn encode_decode_stub_with_all_path_matchers_test() {
  let string_matchers = [
    Exact("/exact"),
    Contains("fragment"),
    Prefix("/api"),
    Suffix(".json"),
    AnyString,
  ]
  list.each(string_matchers, fn(string_matcher) {
    let the_stub =
      stub.new(
        matcher.new() |> matcher.path_matching(string_matcher),
        response.ok(),
      )
      |> stub.with_id("path-test")
    let roundtrip_result = roundtrip_stub(the_stub)
    let assert True = roundtrip_result.matcher.path == Some(string_matcher)
  })
}

pub fn encode_decode_stub_with_query_params_test() {
  let the_stub =
    stub.new(matcher.new() |> matcher.query_param("key", "value"), response.ok())
    |> stub.with_id("query-stub")
  let roundtrip_result = roundtrip_stub(the_stub)
  let assert [#("key", Exact("value"))] = roundtrip_result.matcher.query_params
}

pub fn encode_decode_stub_with_headers_test() {
  let the_stub =
    stub.new(
      matcher.new() |> matcher.header("authorization", "Bearer token"),
      response.ok(),
    )
    |> stub.with_id("header-stub")
  let roundtrip_result = roundtrip_stub(the_stub)
  let assert [#("authorization", Exact("Bearer token"))] =
    roundtrip_result.matcher.headers
}

pub fn encode_decode_stub_with_body_matchers_test() {
  let body_matchers = [
    AnyBody,
    ExactBody("exact"),
    types.ContainsBody("frag"),
    JsonBody("{\"a\":1}"),
  ]
  list.each(body_matchers, fn(body_matcher) {
    let the_stub =
      stub.new(matcher.new() |> matcher.body_matcher(body_matcher), response.ok())
      |> stub.with_id("body-stub")
    let roundtrip_result = roundtrip_stub(the_stub)
    let assert True = roundtrip_result.matcher.body == body_matcher
  })
}

pub fn encode_decode_stub_with_response_headers_test() {
  let the_stub =
    stub.new(
      matcher.new(),
      response.new()
        |> response.header("content-type", "application/json")
        |> response.header("x-custom", "val"),
    )
    |> stub.with_id("response-stub")
  let roundtrip_result = roundtrip_stub(the_stub)
  let assert [#("x-custom", "val"), #("content-type", "application/json")] =
    roundtrip_result.response.headers
}

pub fn encode_decode_stub_with_string_body_test() {
  let the_stub =
    stub.new(matcher.new(), response.new() |> response.body("hello"))
    |> stub.with_id("string-body-stub")
  let roundtrip_result = roundtrip_stub(the_stub)
  let assert StringBody("hello") = roundtrip_result.response.body
}

pub fn encode_decode_stub_with_delay_test() {
  let the_stub =
    stub.new(matcher.new(), response.new() |> response.delay(250))
    |> stub.with_id("delay-stub")
  let roundtrip_result = roundtrip_stub(the_stub)
  let assert Some(250) = roundtrip_result.response.delay_ms
}

pub fn encode_decode_stub_with_scenario_test() {
  let the_stub =
    stub.new(matcher.new(), response.ok())
    |> stub.with_id("scenario-stub")
    |> stub.in_scenario("checkout")
    |> stub.when_state_is("step1")
    |> stub.then_transition_to("step2")
  let roundtrip_result = roundtrip_stub(the_stub)
  let assert Some(scenario_state) = roundtrip_result.scenario
  let assert "checkout" = scenario_state.name
  let assert Some("step1") = scenario_state.required_state
  let assert Some("step2") = scenario_state.new_state
}

pub fn encode_decode_multiple_stubs_test() {
  let stubs = [
    stub.new(matcher.new() |> matcher.path("/a"), response.ok())
      |> stub.with_id("a"),
    stub.new(matcher.new() |> matcher.path("/b"), response.not_found())
      |> stub.with_id("b"),
  ]
  let json_string = json_codec.encode_stubs(stubs)
  let assert Ok(decoded) = json_codec.decode_stubs(json_string)
  let assert ["a", "b"] = list.map(decoded, fn(the_stub) { the_stub.id })
}

pub fn decode_invalid_json_returns_error_test() {
  let assert Error(_) = json_codec.decode_stub("not json at all")
}

pub fn encode_decode_recorded_requests_test() {
  let recorded_requests = [
    RecordedRequest(
      id: "req1",
      method: http.Get,
      path: "/test",
      query: Some("a=1"),
      headers: dict.from_list([#("accept", "application/json")]),
      body: "",
      timestamp_ms: 1_000_000,
      matched_stub_id: Some("stub-1"),
    ),
  ]
  let json_string = json_codec.encode_recorded_requests(recorded_requests)
  let assert Ok(decoded) = json_codec.decode_recorded_requests(json_string)
  let assert [recorded_request] = decoded
  let assert "req1" = recorded_request.id
  let assert http.Get = recorded_request.method
  let assert "/test" = recorded_request.path
  let assert Some("a=1") = recorded_request.query
  let assert Some("stub-1") = recorded_request.matched_stub_id
}
