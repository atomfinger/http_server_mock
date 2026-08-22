import gleam/http/request.{type Request}
import gleam/http/response.{type Response}
import gleam/list
import gleam/option.{type Option}

pub type Stub {
  Stub(handle: fn(Request(String)) -> Result(Response(String), Nil))
}

/// Finds the first stub, in registration order, whose `handle` succeeds for
/// `request`. Returns the stub alongside the response it produced, so the
/// caller can record which stub matched (used to serve `received_by`).
pub fn find_match(
  stubs: List(Stub),
  request: Request(String),
) -> Option(#(Stub, Response(String))) {
  stubs
  |> list.find_map(fn(stub) {
    case stub.handle(request) {
      Ok(response) -> Ok(#(stub, response))
      Error(Nil) -> Error(Nil)
    }
  })
  |> option.from_result
}
