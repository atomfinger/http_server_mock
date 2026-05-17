import gleam/dict
import gleam/http
import gleam/list
import gleam/option.{Some}
import http_server_mock/internal/json_codec
import http_server_mock/matcher
import http_server_mock/response
import http_server_mock/stub_builder
import http_server_mock/types.{
  type Stub, AnyBody, AnyString, Contains, Exact, ExactBody, JsonBody, Prefix,
  RecordedRequest, StringBody, Suffix,
}

fn roundtrip_stub(the_stub: Stub) -> Stub {
  let json_string = json_codec.encode_stub(the_stub)
  let assert Ok(decoded) = json_codec.decode_stub(json_string)
  decoded
}

pub fn encode_decode_minimal_stub_test() {
  let the_stub =
    stub_builder.new()
    |> stub_builder.matching(matcher.new())
    |> stub_builder.responding_with(response.ok())
    |> stub_builder.with_id("test-id")
    |> stub_builder.build()
  let roundtrip_result = roundtrip_stub(the_stub)
  assert roundtrip_result.id == "test-id"
  assert roundtrip_result.response.status == 200
}

pub fn encode_decode_stub_with_method_and_path_test() {
  let the_stub =
    stub_builder.new()
    |> stub_builder.matching(
      matcher.new() |> matcher.method(http.Post) |> matcher.path("/api/data"),
    )
    |> stub_builder.responding_with(response.new() |> response.status(201))
    |> stub_builder.with_id("post-stub")
    |> stub_builder.build()
  let roundtrip_result = roundtrip_stub(the_stub)
  assert roundtrip_result.matcher.method == Some(http.Post)
  assert roundtrip_result.matcher.path == Some(Exact("/api/data"))
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
      stub_builder.new()
      |> stub_builder.matching(matcher.new() |> matcher.path_matching(string_matcher))
      |> stub_builder.responding_with(response.ok())
      |> stub_builder.with_id("path-test")
      |> stub_builder.build()
    let roundtrip_result = roundtrip_stub(the_stub)
    assert roundtrip_result.matcher.path == Some(string_matcher)
  })
}

pub fn encode_decode_stub_with_query_params_test() {
  let the_stub =
    stub_builder.new()
    |> stub_builder.matching(matcher.new() |> matcher.query_param("key", "value"))
    |> stub_builder.responding_with(response.ok())
    |> stub_builder.with_id("query-stub")
    |> stub_builder.build()
  let roundtrip_result = roundtrip_stub(the_stub)
  assert roundtrip_result.matcher.query_params == [#("key", Exact("value"))]
}

pub fn encode_decode_stub_with_headers_test() {
  let the_stub =
    stub_builder.new()
    |> stub_builder.matching(
      matcher.new() |> matcher.header("authorization", "Bearer token"),
    )
    |> stub_builder.responding_with(response.ok())
    |> stub_builder.with_id("header-stub")
    |> stub_builder.build()
  let roundtrip_result = roundtrip_stub(the_stub)
  assert roundtrip_result.matcher.headers
    == [#("authorization", Exact("Bearer token"))]
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
      stub_builder.new()
      |> stub_builder.matching(matcher.new() |> matcher.body_matcher(body_matcher))
      |> stub_builder.responding_with(response.ok())
      |> stub_builder.with_id("body-stub")
      |> stub_builder.build()
    let roundtrip_result = roundtrip_stub(the_stub)
    assert roundtrip_result.matcher.body == body_matcher
  })
}

pub fn encode_decode_stub_with_response_headers_test() {
  let the_stub =
    stub_builder.new()
    |> stub_builder.matching(matcher.new())
    |> stub_builder.responding_with(
      response.new()
      |> response.header("content-type", "application/json")
      |> response.header("x-custom", "val"),
    )
    |> stub_builder.with_id("response-stub")
    |> stub_builder.build()
  let roundtrip_result = roundtrip_stub(the_stub)
  assert roundtrip_result.response.headers
    == [#("x-custom", "val"), #("content-type", "application/json")]
}

pub fn encode_decode_stub_with_string_body_test() {
  let the_stub =
    stub_builder.new()
    |> stub_builder.matching(matcher.new())
    |> stub_builder.responding_with(response.new() |> response.body("hello"))
    |> stub_builder.with_id("string-body-stub")
    |> stub_builder.build()
  let roundtrip_result = roundtrip_stub(the_stub)
  assert roundtrip_result.response.body == StringBody("hello")
}

pub fn encode_decode_stub_with_delay_test() {
  let the_stub =
    stub_builder.new()
    |> stub_builder.matching(matcher.new())
    |> stub_builder.responding_with(response.new() |> response.delay(250))
    |> stub_builder.with_id("delay-stub")
    |> stub_builder.build()
  let roundtrip_result = roundtrip_stub(the_stub)
  assert roundtrip_result.response.delay_ms == Some(250)
}

pub fn encode_decode_stub_with_scenario_test() {
  let the_stub =
    stub_builder.new()
    |> stub_builder.matching(matcher.new())
    |> stub_builder.responding_with(response.ok())
    |> stub_builder.with_id("scenario-stub")
    |> stub_builder.in_scenario("checkout")
    |> stub_builder.when_state_is("step1")
    |> stub_builder.then_transition_to("step2")
    |> stub_builder.build()
  let roundtrip_result = roundtrip_stub(the_stub)
  let assert Some(scenario_state) = roundtrip_result.scenario
  assert scenario_state.name == "checkout"
  assert scenario_state.required_state == Some("step1")
  assert scenario_state.new_state == Some("step2")
}

pub fn encode_decode_multiple_stubs_test() {
  let stubs = [
    stub_builder.new()
      |> stub_builder.matching(matcher.new() |> matcher.path("/a"))
      |> stub_builder.responding_with(response.ok())
      |> stub_builder.with_id("a")
      |> stub_builder.build(),
    stub_builder.new()
      |> stub_builder.matching(matcher.new() |> matcher.path("/b"))
      |> stub_builder.responding_with(response.not_found())
      |> stub_builder.with_id("b")
      |> stub_builder.build(),
  ]
  let json_string = json_codec.encode_stubs(stubs)
  let assert Ok(decoded) = json_codec.decode_stubs(json_string)
  assert list.map(decoded, fn(the_stub) { the_stub.id }) == ["a", "b"]
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
  assert recorded_request.id == "req1"
  assert recorded_request.method == http.Get
  assert recorded_request.path == "/test"
  assert recorded_request.query == Some("a=1")
  assert recorded_request.matched_stub_id == Some("stub-1")
}
