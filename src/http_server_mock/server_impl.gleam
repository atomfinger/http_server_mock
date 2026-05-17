import gleam/bit_array
import gleam/bytes_tree
import gleam/dict
import gleam/dynamic.{type Dynamic}
import gleam/erlang/atom
import gleam/erlang/process.{type Subject}
import gleam/http
import gleam/http/request
import gleam/http/response
import gleam/int
import gleam/list
import gleam/option.{None, Some}
import gleam/order
import gleam/otp/actor
import gleam/result
import gleam/string
import http_server_mock/json_codec
import http_server_mock/router
import http_server_mock/types.{
  type RecordedRequest, type ResponseDefinition, type Stub, RecordedRequest,
}
import mist

type ServerState {
  ServerState(
    stubs: List(Stub),
    recorded_requests: List(RecordedRequest),
    scenarios: dict.Dict(String, String),
  )
}

type ServerMessage {
  AddStub(stub: Stub, reply_with: Subject(String))
  RemoveStub(id: String, reply_with: Subject(Nil))
  ClearStubs(reply_with: Subject(Nil))
  GetStubs(reply_with: Subject(String))
  MatchRequest(
    recorded_request: RecordedRequest,
    reply_with: Subject(option.Option(ResponseDefinition)),
  )
  GetRequests(reply_with: Subject(String))
  ClearRequests(reply_with: Subject(Nil))
  Shutdown
}

type Handle {
  Handle(subject: Subject(ServerMessage), supervisor_pid: process.Pid)
}

@target(erlang)
pub fn start_server(port: Int) -> Result(#(Int, Dynamic), String) {
  let initial_state =
    ServerState(stubs: [], recorded_requests: [], scenarios: dict.new())

  use started <- result.try(
    actor.new(initial_state)
    |> actor.on_message(handle_message)
    |> actor.start
    |> result.map_error(fn(_) { "Failed to start state actor" }),
  )
  let subject = started.data

  let port_channel = process.new_subject()
  let port_selector = process.new_selector() |> process.select(port_channel)

  use mist_started <- result.try(
    mist.new(fn(mist_request) { handle_http(subject, mist_request) })
    |> mist.port(port)
    |> mist.bind("0.0.0.0")
    |> mist.after_start(fn(actual_port, _scheme, _ip) {
      process.send(port_channel, actual_port)
    })
    |> mist.start
    |> result.map_error(fn(_) { "Failed to start HTTP server" }),
  )

  let actual_port = case process.selector_receive(port_selector, 5000) {
    Ok(assigned_port) -> assigned_port
    Error(Nil) -> port
  }

  let server_handle = Handle(subject: subject, supervisor_pid: mist_started.pid)
  Ok(#(actual_port, identity(server_handle)))
}

@target(erlang)
pub fn stop_server(handle: Dynamic) -> Nil {
  let server_handle: Handle = identity(handle)
  process.send(server_handle.subject, Shutdown)
  process.send_exit(server_handle.supervisor_pid)
}

@target(erlang)
pub fn add_stub(handle: Dynamic, stub_json: String) -> Result(String, String) {
  let server_handle: Handle = identity(handle)
  case json_codec.decode_stub(stub_json) {
    Error(error_message) -> Error("Invalid stub JSON: " <> error_message)
    Ok(stub) -> {
      let stub_id =
        process.call(server_handle.subject, 5000, fn(reply_subject) {
          AddStub(stub, reply_subject)
        })
      Ok(stub_id)
    }
  }
}

@target(erlang)
pub fn remove_stub(handle: Dynamic, id: String) -> Nil {
  let server_handle: Handle = identity(handle)
  process.call(server_handle.subject, 5000, fn(reply_subject) {
    RemoveStub(id, reply_subject)
  })
}

@target(erlang)
pub fn clear_stubs(handle: Dynamic) -> Nil {
  let server_handle: Handle = identity(handle)
  process.call(server_handle.subject, 5000, fn(reply_subject) {
    ClearStubs(reply_subject)
  })
}

@target(erlang)
pub fn get_stubs(handle: Dynamic) -> String {
  let server_handle: Handle = identity(handle)
  process.call(server_handle.subject, 5000, fn(reply_subject) {
    GetStubs(reply_subject)
  })
}

@target(erlang)
pub fn get_requests(handle: Dynamic) -> String {
  let server_handle: Handle = identity(handle)
  process.call(server_handle.subject, 5000, fn(reply_subject) {
    GetRequests(reply_subject)
  })
}

@target(erlang)
pub fn clear_requests(handle: Dynamic) -> Nil {
  let server_handle: Handle = identity(handle)
  process.call(server_handle.subject, 5000, fn(reply_subject) {
    ClearRequests(reply_subject)
  })
}

@target(erlang)
fn handle_message(
  state: ServerState,
  message: ServerMessage,
) -> actor.Next(ServerState, ServerMessage) {
  case message {
    Shutdown -> actor.stop()

    AddStub(stub, reply_subject) -> {
      process.send(reply_subject, stub.id)
      actor.continue(
        ServerState(..state, stubs: insert_stub(state.stubs, stub)),
      )
    }

    RemoveStub(id, reply_subject) -> {
      process.send(reply_subject, Nil)
      actor.continue(
        ServerState(
          ..state,
          stubs: list.filter(state.stubs, fn(stub) { stub.id != id }),
        ),
      )
    }

    ClearStubs(reply_subject) -> {
      process.send(reply_subject, Nil)
      actor.continue(ServerState(..state, stubs: []))
    }

    GetStubs(reply_subject) -> {
      process.send(reply_subject, json_codec.encode_stubs(state.stubs))
      actor.continue(state)
    }

    MatchRequest(recorded_request, reply_subject) -> {
      case router.find_match(state.stubs, state.scenarios, recorded_request) {
        None -> {
          let recorded =
            RecordedRequest(..recorded_request, matched_stub_id: None)
          process.send(reply_subject, None)
          actor.continue(
            ServerState(..state, recorded_requests: [
              recorded,
              ..state.recorded_requests
            ]),
          )
        }
        Some(#(stub, response_def)) -> {
          let recorded =
            RecordedRequest(..recorded_request, matched_stub_id: Some(stub.id))
          let updated_scenarios = advance_scenario(state.scenarios, stub)
          process.send(reply_subject, Some(response_def))
          actor.continue(
            ServerState(
              ..state,
              scenarios: updated_scenarios,
              recorded_requests: [recorded, ..state.recorded_requests],
            ),
          )
        }
      }
    }

    GetRequests(reply_subject) -> {
      process.send(
        reply_subject,
        json_codec.encode_recorded_requests(state.recorded_requests),
      )
      actor.continue(state)
    }

    ClearRequests(reply_subject) -> {
      process.send(reply_subject, Nil)
      actor.continue(ServerState(..state, recorded_requests: []))
    }
  }
}

@target(erlang)
fn handle_http(
  subject: Subject(ServerMessage),
  mist_request: request.Request(mist.Connection),
) -> response.Response(mist.ResponseData) {
  case string.starts_with(mist_request.path, "/__admin") {
    True -> handle_admin(subject, mist_request)
    False -> handle_stub(subject, mist_request)
  }
}

@target(erlang)
fn read_body_string(mist_request: request.Request(mist.Connection)) -> String {
  case mist.read_body(mist_request, 4_194_304) {
    Ok(request_with_body) ->
      request_with_body.body
      |> bit_array.to_string
      |> result.unwrap("")
    Error(_) -> ""
  }
}

@target(erlang)
fn handle_stub(
  subject: Subject(ServerMessage),
  mist_request: request.Request(mist.Connection),
) -> response.Response(mist.ResponseData) {
  let body_string = read_body_string(mist_request)

  let headers_dict =
    list.fold(mist_request.headers, dict.new(), fn(header_dict, header_pair) {
      let #(key, value) = header_pair
      dict.insert(header_dict, string.lowercase(key), value)
    })

  let recorded_request =
    RecordedRequest(
      id: new_id(),
      method: mist_request.method,
      path: mist_request.path,
      query: mist_request.query,
      headers: headers_dict,
      body: body_string,
      timestamp_ms: now_ms(),
      matched_stub_id: None,
    )

  case
    process.call(subject, 5000, fn(reply_subject) {
      MatchRequest(recorded_request, reply_subject)
    })
  {
    None ->
      json_response(
        "{\"status\":404,\"message\":\"No stub matched\",\"path\":\""
          <> mist_request.path
          <> "\"}",
        404,
      )
    Some(response_def) -> {
      case response_def.delay_ms {
        Some(milliseconds) -> sleep(milliseconds)
        None -> Nil
      }
      build_response(response_def)
    }
  }
}

@target(erlang)
fn handle_admin(
  subject: Subject(ServerMessage),
  mist_request: request.Request(mist.Connection),
) -> response.Response(mist.ResponseData) {
  let body_string = read_body_string(mist_request)
  let path = mist_request.path
  let method = mist_request.method

  case method, path {
    http.Get, "/__admin/health" -> json_response("{\"status\":\"ok\"}", 200)

    http.Get, "/__admin/stubs" ->
      json_response(
        process.call(subject, 5000, fn(reply_subject) {
          GetStubs(reply_subject)
        }),
        200,
      )

    http.Post, "/__admin/stubs" ->
      case json_codec.decode_stub(body_string) {
        Error(error_message) ->
          json_response("{\"error\":\"" <> error_message <> "\"}", 400)
        Ok(stub) -> {
          let stub_id =
            process.call(subject, 5000, fn(reply_subject) {
              AddStub(stub, reply_subject)
            })
          json_response("{\"id\":\"" <> stub_id <> "\"}", 201)
        }
      }

    http.Delete, "/__admin/stubs" -> {
      process.call(subject, 5000, fn(reply_subject) {
        ClearStubs(reply_subject)
      })
      json_response("{\"status\":\"ok\"}", 200)
    }

    http.Get, "/__admin/requests" ->
      json_response(
        process.call(subject, 5000, fn(reply_subject) {
          GetRequests(reply_subject)
        }),
        200,
      )

    http.Delete, "/__admin/requests" -> {
      process.call(subject, 5000, fn(reply_subject) {
        ClearRequests(reply_subject)
      })
      json_response("{\"status\":\"ok\"}", 200)
    }

    http.Post, "/__admin/reset" -> {
      process.call(subject, 5000, fn(reply_subject) {
        ClearStubs(reply_subject)
      })
      process.call(subject, 5000, fn(reply_subject) {
        ClearRequests(reply_subject)
      })
      json_response("{\"status\":\"ok\"}", 200)
    }

    http.Post, "/__admin/stubs/import" ->
      case json_codec.decode_stubs(body_string) {
        Error(error_message) ->
          json_response("{\"error\":\"" <> error_message <> "\"}", 400)
        Ok(stubs) -> {
          list.each(stubs, fn(stub) {
            process.call(subject, 5000, fn(reply_subject) {
              AddStub(stub, reply_subject)
            })
          })
          json_response(
            "{\"imported\":" <> int.to_string(list.length(stubs)) <> "}",
            201,
          )
        }
      }

    _, _ -> json_response("{\"error\":\"Not found\"}", 404)
  }
}

@target(erlang)
fn build_response(
  response_def: ResponseDefinition,
) -> response.Response(mist.ResponseData) {
  let body_tree = case response_def.body {
    types.NoBody -> bytes_tree.new()
    types.StringBody(text) -> bytes_tree.from_string(text)
    types.RawJsonBody(json_text) -> bytes_tree.from_string(json_text)
    types.BytesBody(bytes) -> bytes_tree.from_bit_array(bytes)
  }
  let base_response =
    response.new(response_def.status)
    |> response.set_body(mist.Bytes(body_tree))
  list.fold(
    response_def.headers,
    base_response,
    fn(current_response, header_pair) {
      let #(key, value) = header_pair
      response.set_header(current_response, key, value)
    },
  )
}

@target(erlang)
fn json_response(
  body: String,
  status: Int,
) -> response.Response(mist.ResponseData) {
  response.new(status)
  |> response.set_header("content-type", "application/json")
  |> response.set_body(mist.Bytes(bytes_tree.from_string(body)))
}

@target(erlang)
fn insert_stub(stubs: List(Stub), new_stub: Stub) -> List(Stub) {
  let without_existing = list.filter(stubs, fn(stub) { stub.id != new_stub.id })
  list.sort([new_stub, ..without_existing], fn(left, right) {
    case left.priority < right.priority {
      True -> order.Lt
      False ->
        case left.priority > right.priority {
          True -> order.Gt
          False -> order.Eq
        }
    }
  })
}

@target(erlang)
fn advance_scenario(
  scenarios: dict.Dict(String, String),
  stub: Stub,
) -> dict.Dict(String, String) {
  case stub.scenario {
    None -> scenarios
    Some(scenario_state) ->
      case scenario_state.new_state {
        None -> scenarios
        Some(new_state) ->
          dict.insert(scenarios, scenario_state.name, new_state)
      }
  }
}

@target(erlang)
@external(erlang, "gleam_stdlib", "identity")
fn identity(value: input) -> output

@target(erlang)
@external(erlang, "erlang", "unique_integer")
fn unique_int() -> Int

@target(erlang)
fn new_id() -> String {
  "req_" <> int.to_string(unique_int())
}

@target(erlang)
fn now_ms() -> Int {
  erlang_system_time(atom.create("millisecond"))
}

@target(erlang)
@external(erlang, "erlang", "system_time")
fn erlang_system_time(unit: atom.Atom) -> Int

@target(erlang)
@external(erlang, "timer", "sleep")
fn sleep(milliseconds: Int) -> Nil
