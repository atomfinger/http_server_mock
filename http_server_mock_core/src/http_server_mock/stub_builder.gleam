//// Builder for `Stub` — pairs a request matcher with a response definition.
////
//// Start with `new()`, set a matcher via `matching()` and a response via
//// `responding_with()`, then call `build()` to produce a `Stub` you can
//// register with the server.
////
//// Phantom types enforce that both `matching` and `responding_with` have been
//// called: passing a partially-configured builder to `build` is a compile error.
////
//// For stateful sequences, call `in_scenario` first, then optionally
//// `when_state_is` and `then_transition_to` — calling the latter two without
//// `in_scenario` is a compile error enforced by the `WithScenario` phantom type.
////
//// ```gleam
//// import gleam/http
//// import http_server_mock/matcher
//// import http_server_mock/response
//// import http_server_mock/stub_builder
////
//// let stub =
////   stub_builder.new()
////   |> stub_builder.matching(matcher.new() |> matcher.method(http.Post) |> matcher.path("/users"))
////   |> stub_builder.responding_with(response.created())
////   |> stub_builder.build()
//// ```

import gleam/int
import gleam/option.{type Option, None, Some}
import http_server_mock/types.{
  type RequestMatcher, type ResponseDefinition, type Stub, ScenarioState, Stub,
}

/// Phantom type indicating a matcher has been set on a `StubBuilder`.
pub type WithMatcher

/// Phantom type indicating no matcher has been set on a `StubBuilder` yet.
pub type WithoutMatcher

/// Phantom type indicating a response has been set on a `StubBuilder`.
pub type WithResponse

/// Phantom type indicating no response has been set on a `StubBuilder` yet.
pub type WithoutResponse

/// Phantom type indicating `in_scenario` has been called on a `StubBuilder`.
/// Required before calling `when_state_is` or `then_transition_to`.
pub type WithScenario

/// Phantom type indicating `in_scenario` has not yet been called on a `StubBuilder`.
pub type WithoutScenario

/// A stub under construction.
///
/// Three phantom type parameters track builder state:
/// - `matcher_state` — `WithoutMatcher` until `matching` is called
/// - `response_state` — `WithoutResponse` until `responding_with` is called
/// - `scenario_state` — `WithoutScenario` until `in_scenario` is called
///
/// Only `StubBuilder(WithMatcher, WithResponse, _)` can be passed to `build`.
/// Forgetting either `matching` or `responding_with` is a compile error.
/// Calling `when_state_is` or `then_transition_to` before `in_scenario` is also
/// a compile error.
pub opaque type StubBuilder(matcher_state, response_state, scenario_state) {
  StubBuilder(
    matcher: Option(RequestMatcher),
    response: Option(ResponseDefinition),
    id: Option(String),
    priority: Int,
    scenario: Option(types.ScenarioState),
  )
}

/// Creates an empty stub builder with no matcher, response, or scenario set.
pub fn new() -> StubBuilder(WithoutMatcher, WithoutResponse, WithoutScenario) {
  StubBuilder(
    matcher: None,
    response: None,
    id: None,
    priority: 5,
    scenario: None,
  )
}

/// Sets the request matcher, transitioning the builder to `WithMatcher`.
pub fn matching(
  builder: StubBuilder(_, response_state, scenario_state),
  request_matcher: RequestMatcher,
) -> StubBuilder(WithMatcher, response_state, scenario_state) {
  StubBuilder(..builder, matcher: Some(request_matcher))
}

/// Sets the response definition, transitioning the builder to `WithResponse`.
pub fn responding_with(
  builder: StubBuilder(matcher_state, _, scenario_state),
  response_def: ResponseDefinition,
) -> StubBuilder(matcher_state, WithResponse, scenario_state) {
  StubBuilder(..builder, response: Some(response_def))
}

/// Assigns a custom ID to this stub.
///
/// IDs are used with `remove_stub` to unregister a specific stub. If not set,
/// a unique ID is generated automatically.
pub fn with_id(
  builder: StubBuilder(matcher_state, response_state, scenario_state),
  id: String,
) -> StubBuilder(matcher_state, response_state, scenario_state) {
  StubBuilder(..builder, id: Some(id))
}

/// Sets the priority for this stub.
///
/// Lower values win when multiple stubs match a request. Defaults to `5`.
pub fn with_priority(
  builder: StubBuilder(matcher_state, response_state, scenario_state),
  priority: Int,
) -> StubBuilder(matcher_state, response_state, scenario_state) {
  StubBuilder(..builder, priority: priority)
}

/// Places this stub inside the named scenario, transitioning the builder to `WithScenario`.
///
/// Scenarios allow a sequence of stubs to fire in order: the first time the
/// matcher fires it transitions state; subsequent calls match the next stub.
/// Must be called before `when_state_is` or `then_transition_to`.
pub fn in_scenario(
  builder: StubBuilder(matcher_state, response_state, _),
  name: String,
) -> StubBuilder(matcher_state, response_state, WithScenario) {
  let scenario = case builder.scenario {
    None -> ScenarioState(name: name, required_state: None, new_state: None)
    Some(existing) -> ScenarioState(..existing, name: name)
  }
  StubBuilder(..builder, scenario: Some(scenario))
}

/// Makes this stub only fire when the scenario is in the given state.
///
/// Requires `in_scenario` to have been called first — enforced at compile time.
pub fn when_state_is(
  builder: StubBuilder(matcher_state, response_state, WithScenario),
  state: String,
) -> StubBuilder(matcher_state, response_state, WithScenario) {
  let assert Some(existing) = builder.scenario
  StubBuilder(
    ..builder,
    scenario: Some(ScenarioState(..existing, required_state: Some(state))),
  )
}

/// Transitions the scenario to the given state after this stub fires.
///
/// Requires `in_scenario` to have been called first — enforced at compile time.
pub fn then_transition_to(
  builder: StubBuilder(matcher_state, response_state, WithScenario),
  new_state: String,
) -> StubBuilder(matcher_state, response_state, WithScenario) {
  let assert Some(existing) = builder.scenario
  StubBuilder(
    ..builder,
    scenario: Some(ScenarioState(..existing, new_state: Some(new_state))),
  )
}

/// Builds the concrete `Stub` from this builder.
///
/// Only callable when both `matching` and `responding_with` have been called —
/// the phantom types enforce this at compile time.
///
/// Pass the result to `http_server_mock.with_stub` or `http_server_mock.add_stub`.
pub fn build(
  builder: StubBuilder(WithMatcher, WithResponse, scenario_state),
) -> Stub {
  let assert Some(matcher) = builder.matcher
  let assert Some(response) = builder.response
  let id = case builder.id {
    Some(id) -> id
    None -> generate_id()
  }
  Stub(
    id: id,
    priority: builder.priority,
    matcher: matcher,
    response: response,
    scenario: builder.scenario,
  )
}

// On JavaScript the external is used directly.
@external(javascript, "./internal/ffi.mjs", "generateId")
fn generate_id() -> String {
  "stub_" <> int.to_string(erlang_unique_integer())
}

@external(erlang, "erlang", "unique_integer")
fn erlang_unique_integer() -> Int
