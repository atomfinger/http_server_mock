import gleam/dynamic.{type Dynamic}

/// A record of functions that a runtime package must supply to drive the mock
/// server. Core uses these to start/stop the server and manage stubs and
/// recorded requests without knowing anything about the underlying runtime.
///
/// Construct one with `http_server_mock_erlang.server()` or
/// `http_server_mock_js.server()` and pass it to `http_server_mock.new/1`.
pub type ServerAdapter {
  ServerAdapter(
    start: fn(Int) -> Result(#(Int, Dynamic), String),
    stop: fn(Dynamic) -> Nil,
    add_stub: fn(Dynamic, String) -> Result(String, String),
    remove_stub: fn(Dynamic, String) -> Nil,
    clear_stubs: fn(Dynamic) -> Nil,
    get_stubs: fn(Dynamic) -> String,
    get_requests: fn(Dynamic) -> String,
    clear_requests: fn(Dynamic) -> Nil,
  )
}
