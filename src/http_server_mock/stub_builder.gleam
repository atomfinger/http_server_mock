import gleam/int
import gleam/option.{None, Some, type Option}
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

/// A stub under construction.
///
/// The two phantom type parameters track whether a matcher and response have
/// been set:
/// - `StubBuilder(WithoutMatcher, WithoutResponse)` — freshly created, nothing set
/// - `StubBuilder(WithMatcher, WithoutResponse)` — matcher set, response missing
/// - `StubBuilder(WithoutMatcher, WithResponse)` — response set, matcher missing
/// - `StubBuilder(WithMatcher, WithResponse)` — fully configured, ready to register
///
/// Only `StubBuilder(WithMatcher, WithResponse)` can be passed to `build`.
/// Forgetting either `matching` or `responding_with` is a compile error.
pub opaque type StubBuilder(matcher_state, response_state) {
  StubBuilder(
    matcher: Option(RequestMatcher),
    response: Option(ResponseDefinition),
    id: Option(String),
    priority: Int,
    scenario: Option(types.ScenarioState),
  )
}

/// Creates an empty stub builder with no matcher or response set.
pub fn new() -> StubBuilder(WithoutMatcher, WithoutResponse) {
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
  builder: StubBuilder(_, response_state),
  request_matcher: RequestMatcher,
) -> StubBuilder(WithMatcher, response_state) {
  StubBuilder(..builder, matcher: Some(request_matcher))
}

/// Sets the response definition, transitioning the builder to `WithResponse`.
pub fn responding_with(
  builder: StubBuilder(matcher_state, _),
  response_def: ResponseDefinition,
) -> StubBuilder(matcher_state, WithResponse) {
  StubBuilder(..builder, response: Some(response_def))
}

/// Assigns a custom ID to this stub.
///
/// IDs are used with `remove_stub` to unregister a specific stub. If not set,
/// a unique ID is generated automatically.
pub fn with_id(
  builder: StubBuilder(matcher_state, response_state),
  id: String,
) -> StubBuilder(matcher_state, response_state) {
  StubBuilder(..builder, id: Some(id))
}

/// Sets the priority for this stub.
///
/// Lower values win when multiple stubs match a request. Defaults to `5`.
pub fn with_priority(
  builder: StubBuilder(matcher_state, response_state),
  priority: Int,
) -> StubBuilder(matcher_state, response_state) {
  StubBuilder(..builder, priority: priority)
}

/// Places this stub inside the named scenario.
///
/// Scenarios allow a sequence of stubs to fire in order: the first time the
/// matcher fires it transitions state; subsequent calls match the next stub.
pub fn in_scenario(
  builder: StubBuilder(matcher_state, response_state),
  name: String,
) -> StubBuilder(matcher_state, response_state) {
  let scenario = case builder.scenario {
    None -> ScenarioState(name: name, required_state: None, new_state: None)
    Some(existing) -> ScenarioState(..existing, name: name)
  }
  StubBuilder(..builder, scenario: Some(scenario))
}

/// Makes this stub only fire when the scenario is in the given state.
pub fn when_state_is(
  builder: StubBuilder(matcher_state, response_state),
  state: String,
) -> StubBuilder(matcher_state, response_state) {
  let scenario = case builder.scenario {
    None ->
      ScenarioState(name: "", required_state: Some(state), new_state: None)
    Some(existing) -> ScenarioState(..existing, required_state: Some(state))
  }
  StubBuilder(..builder, scenario: Some(scenario))
}

/// Transitions the scenario to the given state after this stub fires.
pub fn then_transition_to(
  builder: StubBuilder(matcher_state, response_state),
  new_state: String,
) -> StubBuilder(matcher_state, response_state) {
  let scenario = case builder.scenario {
    None ->
      ScenarioState(name: "", required_state: None, new_state: Some(new_state))
    Some(existing) -> ScenarioState(..existing, new_state: Some(new_state))
  }
  StubBuilder(..builder, scenario: Some(scenario))
}

/// Builds the concrete `Stub` from this builder.
///
/// Only callable when both `matching` and `responding_with` have been called —
/// the phantom types enforce this at compile time.
///
/// Pass the result to `http_server_mock.with_stub` or `http_server_mock.add_stub`.
pub fn build(builder: StubBuilder(WithMatcher, WithResponse)) -> Stub {
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
