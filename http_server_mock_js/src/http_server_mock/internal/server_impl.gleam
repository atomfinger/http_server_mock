import gleam/http
import gleam/http/request.{type Request}
import gleam/int
import gleam/list
import gleam/option.{type Option, None, Some}
import http_server_mock/internal/router.{type Stub}

pub type ServerState {
  ServerState(
    stubs: List(Stub),
    recorded_requests: List(#(Request(String), Option(Stub))),
  )
}

@target(javascript)
pub fn initial_state(stubs: List(Stub)) -> ServerState {
  ServerState(stubs: stubs, recorded_requests: [])
}

@target(javascript)
pub fn add_stub(state: ServerState, stub: Stub) -> ServerState {
  // Appended, not prepended: `router.find_match` picks the first matching
  // stub in list order, so a stub added later must come after ones already
  // registered, not jump ahead of them.
  ServerState(..state, stubs: list.append(state.stubs, [stub]))
}

@target(javascript)
pub fn remove_stub(state: ServerState, stub_to_remove: Stub) -> ServerState {
  ServerState(
    ..state,
    stubs: list.filter(state.stubs, fn(stub) { stub != stub_to_remove }),
  )
}

@target(javascript)
pub fn clear_stubs(state: ServerState) -> ServerState {
  ServerState(..state, stubs: [])
}

@target(javascript)
pub fn clear_requests(state: ServerState) -> ServerState {
  ServerState(..state, recorded_requests: [])
}

@target(javascript)
pub fn get_requests(state: ServerState) -> List(Request(String)) {
  state.recorded_requests
  |> list.reverse
  |> list.map(fn(pair) { pair.0 })
}

@target(javascript)
pub fn get_unmatched_requests(state: ServerState) -> List(Request(String)) {
  state.recorded_requests
  |> list.reverse
  |> list.filter(fn(pair) {
    case pair.1 {
      None -> True
      Some(_) -> False
    }
  })
  |> list.map(fn(pair) { pair.0 })
}

@target(javascript)
pub fn get_requests_by_stub(
  state: ServerState,
  stub_to_match: Stub,
) -> List(Request(String)) {
  state.recorded_requests
  |> list.reverse
  |> list.filter(fn(pair) {
    case pair.1 {
      Some(matched_stub) -> matched_stub == stub_to_match
      None -> False
    }
  })
  |> list.map(fn(pair) { pair.0 })
}

@target(javascript)
/// Handles one incoming request: builds a `Request(String)` from primitive
/// fields (the shape the transport worker can hand over as plain data),
/// finds the matching stub via the same router the Erlang runtime uses,
/// updates recorded requests, and calls `on_result` with the new state plus
/// the outcome - kept as primitives too, so the FFI transport layer never
/// has to inspect a Gleam `Option`/`Response` value directly.
pub fn handle_request(
  state: ServerState,
  method_string: String,
  path: String,
  query: String,
  headers: List(#(String, String)),
  body: String,
  host: String,
  port: String,
  on_result: fn(ServerState, Bool, Int, List(#(String, String)), String) -> Nil,
) -> Nil {
  let method = case http.parse_method(method_string) {
    Ok(method) -> method
    Error(Nil) -> http.Get
  }
  let query_option = case query {
    "" -> None
    _ -> Some(query)
  }
  let port_option = case int.parse(port) {
    Ok(port_number) -> Some(port_number)
    Error(Nil) -> None
  }
  let incoming =
    request.Request(
      method: method,
      headers: headers,
      body: body,
      scheme: http.Http,
      host: host,
      port: port_option,
      path: path,
      query: query_option,
    )

  case router.find_match(state.stubs, incoming) {
    None -> {
      let new_state =
        ServerState(..state, recorded_requests: [
          #(incoming, None),
          ..state.recorded_requests
        ])
      on_result(new_state, False, 404, [], "")
    }
    Some(#(matched_stub, matched_response)) -> {
      let new_state =
        ServerState(..state, recorded_requests: [
          #(incoming, Some(matched_stub)),
          ..state.recorded_requests
        ])
      on_result(
        new_state,
        True,
        matched_response.status,
        matched_response.headers,
        matched_response.body,
      )
    }
  }
}
