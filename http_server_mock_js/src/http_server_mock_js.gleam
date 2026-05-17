import gleam/dynamic.{type Dynamic}
import http_server_mock/server_adapter.{type ServerAdapter, ServerAdapter}

/// Returns the JavaScript/Node.js server adapter.
///
/// Pass this to `http_server_mock.new/1` to create a mock server backed by a
/// Node.js Worker thread:
///
/// ```gleam
/// let server =
///   http_server_mock.new(http_server_mock_js.server())
///   |> http_server_mock.start()
/// ```
pub fn server() -> ServerAdapter {
  ServerAdapter(
    start: do_start,
    stop: do_stop,
    add_stub: do_add_stub,
    remove_stub: do_remove_stub,
    clear_stubs: do_clear_stubs,
    get_stubs: do_get_stubs,
    get_requests: do_get_requests,
    clear_requests: do_clear_requests,
  )
}

@external(javascript, "./http_server_mock/internal/server_ffi.mjs", "startServer")
fn do_start(port: Int) -> Result(#(Int, Dynamic), String)

@external(javascript, "./http_server_mock/internal/server_ffi.mjs", "stopServer")
fn do_stop(handle: Dynamic) -> Nil

@external(javascript, "./http_server_mock/internal/server_ffi.mjs", "addStub")
fn do_add_stub(handle: Dynamic, stub_json: String) -> Result(String, String)

@external(javascript, "./http_server_mock/internal/server_ffi.mjs", "removeStub")
fn do_remove_stub(handle: Dynamic, id: String) -> Nil

@external(javascript, "./http_server_mock/internal/server_ffi.mjs", "clearStubs")
fn do_clear_stubs(handle: Dynamic) -> Nil

@external(javascript, "./http_server_mock/internal/server_ffi.mjs", "getStubs")
fn do_get_stubs(handle: Dynamic) -> String

@external(javascript, "./http_server_mock/internal/server_ffi.mjs", "getRequests")
fn do_get_requests(handle: Dynamic) -> String

@external(javascript, "./http_server_mock/internal/server_ffi.mjs", "clearRequests")
fn do_clear_requests(handle: Dynamic) -> Nil
