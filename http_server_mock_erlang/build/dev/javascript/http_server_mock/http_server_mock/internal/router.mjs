import * as $dict from "../../../gleam_stdlib/gleam/dict.mjs";
import * as $list from "../../../gleam_stdlib/gleam/list.mjs";
import * as $option from "../../../gleam_stdlib/gleam/option.mjs";
import { None, Some } from "../../../gleam_stdlib/gleam/option.mjs";
import * as $order from "../../../gleam_stdlib/gleam/order.mjs";
import { Ok, Empty as $Empty, makeError } from "../../gleam.mjs";
import * as $matcher from "../../http_server_mock/matcher.mjs";
import * as $types from "../../http_server_mock/types.mjs";

const FILEPATH = "src/http_server_mock/internal/router.gleam";

function compare_ints(left, right) {
  let $ = left < right;
  if ($) {
    return new $order.Lt();
  } else {
    let $1 = left > right;
    if ($1) {
      return new $order.Gt();
    } else {
      return new $order.Eq();
    }
  }
}

function compute_score(request_matcher, _) {
  let _block;
  let $ = request_matcher.method;
  if ($ instanceof Some) {
    _block = 100;
  } else {
    _block = 0;
  }
  let method_score = _block;
  let _block$1;
  let $1 = request_matcher.path;
  if ($1 instanceof Some) {
    let $2 = $1[0];
    if ($2 instanceof $types.Exact) {
      _block$1 = 80;
    } else {
      _block$1 = 40;
    }
  } else {
    _block$1 = 0;
  }
  let path_score = _block$1;
  let query_score = $list.length(request_matcher.query_params) * 20;
  let header_score = $list.length(request_matcher.headers) * 10;
  let _block$2;
  let $2 = request_matcher.body;
  if ($2 instanceof $types.AnyBody) {
    _block$2 = 0;
  } else if ($2 instanceof $types.ExactBody) {
    _block$2 = 50;
  } else if ($2 instanceof $types.ContainsBody) {
    _block$2 = 30;
  } else {
    _block$2 = 30;
  }
  let body_score = _block$2;
  return (((method_score + path_score) + query_score) + header_score) + body_score;
}

function scenario_matches(stub, scenarios) {
  let $ = stub.scenario;
  if ($ instanceof Some) {
    let scenario_state = $[0];
    let current = $dict.get(scenarios, scenario_state.name);
    let $1 = scenario_state.required_state;
    if ($1 instanceof Some) {
      let required = $1[0];
      if (current instanceof Ok) {
        let state = current[0];
        return state === required;
      } else {
        return false;
      }
    } else {
      if (current instanceof Ok) {
        return false;
      } else {
        return true;
      }
    }
  } else {
    return true;
  }
}

export function score(stub, scenarios, recorded_request) {
  let $ = scenario_matches(stub, scenarios) && $matcher.matches(
    stub.matcher,
    recorded_request,
  );
  if ($) {
    return new Some(compute_score(stub.matcher, recorded_request));
  } else {
    return new None();
  }
}

export function find_match(stubs, scenarios, recorded_request) {
  let _block;
  let _pipe = stubs;
  let _pipe$1 = $list.map(
    _pipe,
    (stub) => { return [score(stub, scenarios, recorded_request), stub]; },
  );
  let _pipe$2 = $list.filter(
    _pipe$1,
    (pair) => { return $option.is_some(pair[0]); },
  );
  let _pipe$3 = $list.map(
    _pipe$2,
    (pair) => {
      let score_option;
      let stub;
      score_option = pair[0];
      stub = pair[1];
      let score_value;
      if (score_option instanceof Some) {
        score_value = score_option[0];
      } else {
        throw makeError(
          "let_assert",
          FILEPATH,
          "http_server_mock/internal/router",
          21,
          "find_match",
          "Pattern match failed, no pattern matched the value.",
          {
            value: score_option,
            start: 628,
            end: 671,
            pattern_start: 639,
            pattern_end: 656
          }
        )
      }
      return [score_value, stub];
    },
  );
  _block = $list.sort(
    _pipe$3,
    (left, right) => {
      let left_score;
      let left_stub;
      left_score = left[0];
      left_stub = left[1];
      let right_score;
      let right_stub;
      right_score = right[0];
      right_stub = right[1];
      let $ = left_stub.priority === right_stub.priority;
      if ($) {
        return $order.negate(compare_ints(left_score, right_score));
      } else {
        return compare_ints(left_stub.priority, right_stub.priority);
      }
    },
  );
  let scored = _block;
  if (scored instanceof $Empty) {
    return new None();
  } else {
    let stub = scored.head[1];
    return new Some([stub, stub.response]);
  }
}
