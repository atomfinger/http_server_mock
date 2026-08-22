import gleam/dynamic.{type Dynamic}
import gleam/http/request.{type Request}
import http_server_mock/internal/router.{type Stub}
import http_server_mock/internal/server_adapter.{
  type ServerAdapter, ServerAdapter,
}

/// Returns the JavaScript/Node.js server adapter.
///
/// Pass this to `http_server_mock.new/1` to create a mock server backed by a
/// Node.js Worker thread:
///
/// ```gleam
/// use server <- http_server_mock.with_handler(
///   http_server_mock.new(http_server_mock_js.server()),
///   fn(req) { ... },
/// )
/// ```
///
/// The Worker thread only transports raw HTTP requests; the actual `Stub`
/// closures run on the main thread, where they were created. See
/// `internal/server_ffi.mjs` for how the two sides talk to each other, and
/// the root README for why that split exists.
pub fn server() -> ServerAdapter {
  ServerAdapter(
    start: do_start,
    stop: do_stop,
    add_stub: do_add_stub,
    remove_stub: do_remove_stub,
    clear_stubs: do_clear_stubs,
    get_requests: do_get_requests,
    get_unmatched_requests: do_get_unmatched_requests,
    get_requests_by_stub: do_get_requests_by_stub,
    clear_requests: do_clear_requests,
  )
}

@external(javascript, "./http_server_mock/internal/server_ffi.mjs", "startServer")
fn do_start(port: Int, stubs: List(Stub)) -> Result(#(Int, Dynamic), String)

@external(javascript, "./http_server_mock/internal/server_ffi.mjs", "stopServer")
fn do_stop(handle: Dynamic) -> Nil

@external(javascript, "./http_server_mock/internal/server_ffi.mjs", "addStub")
fn do_add_stub(handle: Dynamic, stub: Stub) -> Nil

@external(javascript, "./http_server_mock/internal/server_ffi.mjs", "removeStub")
fn do_remove_stub(handle: Dynamic, stub: Stub) -> Nil

@external(javascript, "./http_server_mock/internal/server_ffi.mjs", "clearStubs")
fn do_clear_stubs(handle: Dynamic) -> Nil

@external(javascript, "./http_server_mock/internal/server_ffi.mjs", "getRequests")
fn do_get_requests(handle: Dynamic) -> List(Request(String))

@external(javascript, "./http_server_mock/internal/server_ffi.mjs", "getUnmatchedRequests")
fn do_get_unmatched_requests(handle: Dynamic) -> List(Request(String))

@external(javascript, "./http_server_mock/internal/server_ffi.mjs", "getRequestsByStub")
fn do_get_requests_by_stub(handle: Dynamic, stub: Stub) -> List(Request(String))

@external(javascript, "./http_server_mock/internal/server_ffi.mjs", "clearRequests")
fn do_clear_requests(handle: Dynamic) -> Nil
