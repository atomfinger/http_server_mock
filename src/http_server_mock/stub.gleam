import gleam/int
import gleam/option.{None, Some}
import http_server_mock/types.{
  type RequestMatcher, type ResponseDefinition, type Stub, ScenarioState, Stub,
}

pub fn new(request_matcher: RequestMatcher, response_def: ResponseDefinition) -> Stub {
  Stub(
    id: generate_id(),
    priority: 5,
    matcher: request_matcher,
    response: response_def,
    scenario: None,
  )
}

pub fn with_id(stub: Stub, id: String) -> Stub {
  Stub(..stub, id: id)
}

pub fn with_priority(stub: Stub, priority: Int) -> Stub {
  Stub(..stub, priority: priority)
}

pub fn in_scenario(stub: Stub, name: String) -> Stub {
  let scenario_state = case stub.scenario {
    None -> ScenarioState(name: name, required_state: None, new_state: None)
    Some(existing) -> ScenarioState(..existing, name: name)
  }
  Stub(..stub, scenario: Some(scenario_state))
}

pub fn when_state_is(stub: Stub, state: String) -> Stub {
  let scenario_state = case stub.scenario {
    None ->
      ScenarioState(name: "", required_state: Some(state), new_state: None)
    Some(existing) -> ScenarioState(..existing, required_state: Some(state))
  }
  Stub(..stub, scenario: Some(scenario_state))
}

pub fn then_transition_to(stub: Stub, new_state: String) -> Stub {
  let scenario_state = case stub.scenario {
    None ->
      ScenarioState(name: "", required_state: None, new_state: Some(new_state))
    Some(existing) -> ScenarioState(..existing, new_state: Some(new_state))
  }
  Stub(..stub, scenario: Some(scenario_state))
}

// On JavaScript the external is used directly.
// On Erlang the Gleam body below is the fallback — no .erl file needed.
@external(javascript, "./ffi.mjs", "generateId")
fn generate_id() -> String {
  "stub_" <> int.to_string(erlang_unique_integer())
}

@external(erlang, "erlang", "unique_integer")
fn erlang_unique_integer() -> Int
