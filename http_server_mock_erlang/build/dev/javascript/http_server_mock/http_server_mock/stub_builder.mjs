import * as $int from "../../gleam_stdlib/gleam/int.mjs";
import * as $option from "../../gleam_stdlib/gleam/option.mjs";
import { None, Some } from "../../gleam_stdlib/gleam/option.mjs";
import { CustomType as $CustomType, makeError } from "../gleam.mjs";
import * as $types from "../http_server_mock/types.mjs";
import { ScenarioState, Stub } from "../http_server_mock/types.mjs";
import { generateId as generate_id } from "./internal/ffi.mjs";

const FILEPATH = "src/http_server_mock/stub_builder.gleam";

class StubBuilder extends $CustomType {
  constructor(matcher, response, id, priority, scenario) {
    super();
    this.matcher = matcher;
    this.response = response;
    this.id = id;
    this.priority = priority;
    this.scenario = scenario;
  }
}

/**
 * Creates an empty stub builder with no matcher or response set.
 */
export function new$() {
  return new StubBuilder(new None(), new None(), new None(), 5, new None());
}

/**
 * Sets the request matcher, transitioning the builder to `WithMatcher`.
 */
export function matching(builder, request_matcher) {
  return new StubBuilder(
    new Some(request_matcher),
    builder.response,
    builder.id,
    builder.priority,
    builder.scenario,
  );
}

/**
 * Sets the response definition, transitioning the builder to `WithResponse`.
 */
export function responding_with(builder, response_def) {
  return new StubBuilder(
    builder.matcher,
    new Some(response_def),
    builder.id,
    builder.priority,
    builder.scenario,
  );
}

/**
 * Assigns a custom ID to this stub.
 *
 * IDs are used with `remove_stub` to unregister a specific stub. If not set,
 * a unique ID is generated automatically.
 */
export function with_id(builder, id) {
  return new StubBuilder(
    builder.matcher,
    builder.response,
    new Some(id),
    builder.priority,
    builder.scenario,
  );
}

/**
 * Sets the priority for this stub.
 *
 * Lower values win when multiple stubs match a request. Defaults to `5`.
 */
export function with_priority(builder, priority) {
  return new StubBuilder(
    builder.matcher,
    builder.response,
    builder.id,
    priority,
    builder.scenario,
  );
}

/**
 * Places this stub inside the named scenario.
 *
 * Scenarios allow a sequence of stubs to fire in order: the first time the
 * matcher fires it transitions state; subsequent calls match the next stub.
 */
export function in_scenario(builder, name) {
  let _block;
  let $ = builder.scenario;
  if ($ instanceof Some) {
    let existing = $[0];
    _block = new ScenarioState(
      name,
      existing.required_state,
      existing.new_state,
    );
  } else {
    _block = new ScenarioState(name, new None(), new None());
  }
  let scenario = _block;
  return new StubBuilder(
    builder.matcher,
    builder.response,
    builder.id,
    builder.priority,
    new Some(scenario),
  );
}

/**
 * Makes this stub only fire when the scenario is in the given state.
 */
export function when_state_is(builder, state) {
  let _block;
  let $ = builder.scenario;
  if ($ instanceof Some) {
    let existing = $[0];
    _block = new ScenarioState(
      existing.name,
      new Some(state),
      existing.new_state,
    );
  } else {
    _block = new ScenarioState("", new Some(state), new None());
  }
  let scenario = _block;
  return new StubBuilder(
    builder.matcher,
    builder.response,
    builder.id,
    builder.priority,
    new Some(scenario),
  );
}

/**
 * Transitions the scenario to the given state after this stub fires.
 */
export function then_transition_to(builder, new_state) {
  let _block;
  let $ = builder.scenario;
  if ($ instanceof Some) {
    let existing = $[0];
    _block = new ScenarioState(
      existing.name,
      existing.required_state,
      new Some(new_state),
    );
  } else {
    _block = new ScenarioState("", new None(), new Some(new_state));
  }
  let scenario = _block;
  return new StubBuilder(
    builder.matcher,
    builder.response,
    builder.id,
    builder.priority,
    new Some(scenario),
  );
}

/**
 * Builds the concrete `Stub` from this builder.
 *
 * Only callable when both `matching` and `responding_with` have been called —
 * the phantom types enforce this at compile time.
 *
 * Pass the result to `http_server_mock.with_stub` or `http_server_mock.add_stub`.
 */
export function build(builder) {
  let $ = builder.matcher;
  let matcher;
  if ($ instanceof Some) {
    matcher = $[0];
  } else {
    throw makeError(
      "let_assert",
      FILEPATH,
      "http_server_mock/stub_builder",
      136,
      "build",
      "Pattern match failed, no pattern matched the value.",
      {
        value: $,
        start: 4800,
        end: 4842,
        pattern_start: 4811,
        pattern_end: 4824
      }
    )
  }
  let $1 = builder.response;
  let response;
  if ($1 instanceof Some) {
    response = $1[0];
  } else {
    throw makeError(
      "let_assert",
      FILEPATH,
      "http_server_mock/stub_builder",
      137,
      "build",
      "Pattern match failed, no pattern matched the value.",
      {
        value: $1,
        start: 4845,
        end: 4889,
        pattern_start: 4856,
        pattern_end: 4870
      }
    )
  }
  let _block;
  let $2 = builder.id;
  if ($2 instanceof Some) {
    let id = $2[0];
    _block = id;
  } else {
    _block = generate_id();
  }
  let id = _block;
  return new Stub(id, builder.priority, matcher, response, builder.scenario);
}
