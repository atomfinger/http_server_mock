import gleam/dynamic.{type Dynamic}
import gleam/http/request.{type Request}
import http_server_mock/internal/router.{type Stub}

/// A record of functions that a runtime package must supply to drive the mock
/// server. Core uses these to start/stop the server and manage stubs and
/// recorded requests without knowing anything about the underlying runtime.
///
/// Not part of the public API. Runtime package authors construct one and
/// hand it to `http_server_mock.new`. Since a `Stub`'s `handle` is a live
/// Gleam closure rather than serializable data, each runtime is responsible
/// for holding it somewhere that closure can actually run: an OTP actor's
/// state on Erlang, or the main thread on JS (its HTTP transport is a
/// Worker, which can't receive a closure over `postMessage` - see
/// `http_server_mock_js`'s internal `server_ffi.mjs`/`worker.mjs` for how
/// that split works).
pub type ServerAdapter {
  ServerAdapter(
    start: fn(Int, List(Stub)) -> Result(#(Int, Dynamic), String),
    stop: fn(Dynamic) -> Nil,
    add_stub: fn(Dynamic, Stub) -> Nil,
    remove_stub: fn(Dynamic, Stub) -> Nil,
    clear_stubs: fn(Dynamic) -> Nil,
    get_requests: fn(Dynamic) -> List(Request(String)),
    get_unmatched_requests: fn(Dynamic) -> List(Request(String)),
    get_requests_by_stub: fn(Dynamic, Stub) -> List(Request(String)),
    clear_requests: fn(Dynamic) -> Nil,
  )
}
