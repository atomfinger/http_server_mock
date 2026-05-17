import gleam/dict.{type Dict}
import gleam/list
import gleam/option.{type Option, None, Some}
import gleam/order
import http_server_mock/matcher
import http_server_mock/types.{
  type RecordedRequest, type ResponseDefinition, type Stub,
}

pub fn find_match(
  stubs: List(Stub),
  scenarios: Dict(String, String),
  recorded_request: RecordedRequest,
) -> Option(#(Stub, ResponseDefinition)) {
  let scored =
    stubs
    |> list.map(fn(stub) { #(score(stub, scenarios, recorded_request), stub) })
    |> list.filter(fn(pair) { option.is_some(pair.0) })
    |> list.map(fn(pair) {
      let #(score_option, stub) = pair
      let assert Some(score_value) = score_option
      #(score_value, stub)
    })
    |> list.sort(fn(left, right) {
      let #(left_score, left_stub) = left
      let #(right_score, right_stub) = right
      case left_stub.priority == right_stub.priority {
        True -> order.negate(compare_ints(left_score, right_score))
        False -> compare_ints(left_stub.priority, right_stub.priority)
      }
    })
  case scored {
    [] -> None
    [#(_score, stub), ..] -> Some(#(stub, stub.response))
  }
}

pub fn score(
  stub: Stub,
  scenarios: Dict(String, String),
  recorded_request: RecordedRequest,
) -> Option(Int) {
  case
    scenario_matches(stub, scenarios)
    && matcher.matches(stub.matcher, recorded_request)
  {
    False -> None
    True -> Some(compute_score(stub.matcher, recorded_request))
  }
}

fn scenario_matches(stub: Stub, scenarios: Dict(String, String)) -> Bool {
  case stub.scenario {
    None -> True
    Some(scenario_state) -> {
      let current = dict.get(scenarios, scenario_state.name)
      case scenario_state.required_state {
        None ->
          case current {
            Error(Nil) -> True
            Ok(_) -> False
          }
        Some(required) ->
          case current {
            Ok(state) -> state == required
            Error(Nil) -> False
          }
      }
    }
  }
}

fn compute_score(
  request_matcher: types.RequestMatcher,
  _recorded_request: RecordedRequest,
) -> Int {
  let method_score = case request_matcher.method {
    Some(_) -> 100
    None -> 0
  }
  let path_score = case request_matcher.path {
    None -> 0
    Some(types.Exact(_)) -> 80
    Some(_) -> 40
  }
  let query_score = list.length(request_matcher.query_params) * 20
  let header_score = list.length(request_matcher.headers) * 10
  let body_score = case request_matcher.body {
    types.AnyBody -> 0
    types.ExactBody(_) -> 50
    types.ContainsBody(_) | types.JsonBody(_) -> 30
  }
  method_score + path_score + query_score + header_score + body_score
}

fn compare_ints(left: Int, right: Int) -> order.Order {
  case left < right {
    True -> order.Lt
    False ->
      case left > right {
        True -> order.Gt
        False -> order.Eq
      }
  }
}
