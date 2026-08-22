import gleam/bit_array
import gleam/bytes_tree
import gleam/dynamic.{type Dynamic}
import gleam/erlang/process.{type Subject}
import gleam/http/request.{type Request}
import gleam/http/response
import gleam/list
import gleam/option.{type Option, None, Some}
import gleam/otp/actor
import gleam/result
import gleam/string
import http_server_mock/internal/router.{type Stub}
import mist

type ServerState {
  ServerState(
    stubs: List(Stub),
    recorded_requests: List(#(Request(String), Option(Stub))),
  )
}

type ServerMessage {
  AddStub(stub: Stub, reply_with: Subject(Nil))
  RemoveStub(stub: Stub, reply_with: Subject(Nil))
  ClearStubs(reply_with: Subject(Nil))
  MatchRequest(
    request: Request(String),
    reply_with: Subject(Option(response.Response(String))),
  )
  GetRequests(reply_with: Subject(List(Request(String))))
  GetUnmatchedRequests(reply_with: Subject(List(Request(String))))
  GetRequestsByStub(stub: Stub, reply_with: Subject(List(Request(String))))
  ClearRequests(reply_with: Subject(Nil))
  Shutdown
}

type Handle {
  Handle(subject: Subject(ServerMessage), supervisor_pid: process.Pid)
}

/// The two ways `start_server` can find out whether the HTTP listener
/// actually came up: either `mist.after_start` fires with the bound port, or
/// a trapped exit signal arrives first (e.g. `Eaddrinuse`). Unified into one
/// type so both can be waited for with a single `selector_receive` call.
type StartOutcome {
  PortBound(Int)
  StartFailed(String)
}

@target(erlang)
pub fn start_server(
  port: Int,
  stubs: List(Stub),
) -> Result(#(Int, Dynamic), String) {
  let initial_state = ServerState(stubs: stubs, recorded_requests: [])

  use started <- result.try(
    actor.new(initial_state)
    |> actor.on_message(handle_message)
    |> actor.start
    |> result.map_error(fn(_) { "Failed to start state actor" }),
  )
  let subject = started.data

  let port_channel = process.new_subject()

  // `mist.start` links its supervisor to this process (that's how
  // `start_link` works), so a failure while the listener is still coming up
  // - the common case being the port already being in use - arrives as an
  // EXIT signal to us, not as part of this function's Result. Left alone,
  // that kills this process outright, and since this runs inside whatever
  // supervises it (gleeunit's own test-running supervision tree, in this
  // package's own test suite), it can take down unrelated work sharing that
  // supervisor too - not just this one call.
  //
  // Trapping exits turns that signal into an ordinary message we can select
  // for instead, scoped as narrowly as possible: enabled just before
  // `mist.start`, restored to normal (non-trapping) behaviour as soon as we
  // know the outcome, so nothing about this process's exit-signal handling
  // is different before this call or after it returns.
  process.trap_exits(True)
  let start_result =
    mist.new(fn(mist_request) { handle_stub(subject, mist_request) })
    |> mist.port(port)
    |> mist.bind("0.0.0.0")
    |> mist.after_start(fn(actual_port, _scheme, _ip) {
      process.send(port_channel, actual_port)
    })
    |> mist.start

  case start_result {
    Error(reason) -> {
      process.trap_exits(False)
      process.send(subject, Shutdown)
      Error("Failed to start HTTP server: " <> string.inspect(reason))
    }
    Ok(mist_started) -> {
      let outcome_selector =
        process.new_selector()
        |> process.select_map(port_channel, PortBound)
        |> process.select_trapped_exits(fn(exit_message) {
          let process.ExitMessage(_pid, reason) = exit_message
          StartFailed(describe_exit_reason(reason))
        })

      let outcome = process.selector_receive(outcome_selector, 5000)
      process.trap_exits(False)

      case outcome {
        Ok(PortBound(actual_port)) -> {
          let server_handle =
            Handle(subject: subject, supervisor_pid: mist_started.pid)
          Ok(#(actual_port, identity(server_handle)))
        }
        Ok(StartFailed(reason)) -> {
          process.send(subject, Shutdown)
          Error("Failed to start HTTP server: " <> reason)
        }
        Error(Nil) -> {
          process.send(subject, Shutdown)
          process.send_exit(mist_started.pid)
          Error("Timed out waiting for the HTTP server to start listening")
        }
      }
    }
  }
}

@target(erlang)
fn describe_exit_reason(reason: process.ExitReason) -> String {
  case reason {
    process.Normal -> "normal"
    process.Killed -> "killed"
    process.Abnormal(detail) -> string.inspect(detail)
  }
}

@target(erlang)
pub fn stop_server(handle: Dynamic) -> Nil {
  let server_handle: Handle = identity(handle)
  process.send(server_handle.subject, Shutdown)
  process.send_exit(server_handle.supervisor_pid)
}

@target(erlang)
pub fn add_stub(handle: Dynamic, stub: Stub) -> Nil {
  let server_handle: Handle = identity(handle)
  process.call(server_handle.subject, 5000, fn(reply_subject) {
    AddStub(stub, reply_subject)
  })
}

@target(erlang)
pub fn remove_stub(handle: Dynamic, stub: Stub) -> Nil {
  let server_handle: Handle = identity(handle)
  process.call(server_handle.subject, 5000, fn(reply_subject) {
    RemoveStub(stub, reply_subject)
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
pub fn get_requests(handle: Dynamic) -> List(Request(String)) {
  let server_handle: Handle = identity(handle)
  process.call(server_handle.subject, 5000, fn(reply_subject) {
    GetRequests(reply_subject)
  })
}

@target(erlang)
pub fn get_unmatched_requests(handle: Dynamic) -> List(Request(String)) {
  let server_handle: Handle = identity(handle)
  process.call(server_handle.subject, 5000, fn(reply_subject) {
    GetUnmatchedRequests(reply_subject)
  })
}

@target(erlang)
pub fn get_requests_by_stub(
  handle: Dynamic,
  stub: Stub,
) -> List(Request(String)) {
  let server_handle: Handle = identity(handle)
  process.call(server_handle.subject, 5000, fn(reply_subject) {
    GetRequestsByStub(stub, reply_subject)
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

    AddStub(stub, reply_with) -> {
      process.send(reply_with, Nil)
      // Appended, not prepended: router.find_match picks the first matching
      // stub in list order, so a stub added later must come after ones
      // already registered, not jump ahead of them.
      actor.continue(
        ServerState(..state, stubs: list.append(state.stubs, [stub])),
      )
    }

    RemoveStub(stub_to_remove, reply_with) -> {
      process.send(reply_with, Nil)
      actor.continue(
        ServerState(
          ..state,
          stubs: list.filter(state.stubs, fn(stub) { stub != stub_to_remove }),
        ),
      )
    }

    ClearStubs(reply_with) -> {
      process.send(reply_with, Nil)
      actor.continue(ServerState(..state, stubs: []))
    }

    MatchRequest(request, reply_with) -> {
      case router.find_match(state.stubs, request) {
        None -> {
          process.send(reply_with, None)
          actor.continue(
            ServerState(..state, recorded_requests: [
              #(request, None),
              ..state.recorded_requests
            ]),
          )
        }
        Some(#(matched_stub, matched_response)) -> {
          process.send(reply_with, Some(matched_response))
          actor.continue(
            ServerState(..state, recorded_requests: [
              #(request, Some(matched_stub)),
              ..state.recorded_requests
            ]),
          )
        }
      }
    }

    GetRequests(reply_with) -> {
      process.send(
        reply_with,
        state.recorded_requests
          |> list.reverse
          |> list.map(fn(pair) { pair.0 }),
      )
      actor.continue(state)
    }

    GetUnmatchedRequests(reply_with) -> {
      process.send(
        reply_with,
        state.recorded_requests
          |> list.reverse
          |> list.filter(fn(pair) {
            case pair.1 {
              None -> True
              Some(_) -> False
            }
          })
          |> list.map(fn(pair) { pair.0 }),
      )
      actor.continue(state)
    }

    GetRequestsByStub(stub_to_match, reply_with) -> {
      process.send(
        reply_with,
        state.recorded_requests
          |> list.reverse
          |> list.filter(fn(pair) {
            case pair.1 {
              Some(matched_stub) -> matched_stub == stub_to_match
              None -> False
            }
          })
          |> list.map(fn(pair) { pair.0 }),
      )
      actor.continue(state)
    }

    ClearRequests(reply_with) -> {
      process.send(reply_with, Nil)
      actor.continue(ServerState(..state, recorded_requests: []))
    }
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
  let incoming_request =
    request.Request(
      method: mist_request.method,
      headers: mist_request.headers,
      body: body_string,
      scheme: mist_request.scheme,
      host: mist_request.host,
      port: mist_request.port,
      path: mist_request.path,
      query: mist_request.query,
    )

  case
    process.call(subject, 5000, fn(reply_subject) {
      MatchRequest(incoming_request, reply_subject)
    })
  {
    None ->
      json_response(
        "{\"status\":404,\"message\":\"No stub matched\",\"path\":\""
          <> mist_request.path
          <> "\"}",
        404,
      )
    Some(matched_response) ->
      response.map(matched_response, fn(body) {
        mist.Bytes(bytes_tree.from_string(body))
      })
  }
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
@external(erlang, "gleam_stdlib", "identity")
fn identity(value: input) -> output
