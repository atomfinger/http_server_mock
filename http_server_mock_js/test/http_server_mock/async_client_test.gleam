//// This test deliberately does NOT use integration_test_ffi.mjs's fake-sync
//// client. It calls the mock server with a real, ordinary async client
//// (`fetch`, via async_fetch_ffi.mjs) and no manual pumping of any kind.
////
//// This is the regression test for the bug the reverse-callback design
//// originally shipped with: `server_ffi.mjs` only drained its port when
//// something explicitly called `pumpAll()`, so a normal async caller's
//// request would be forwarded to the main thread and then never answered.
//// If `server_ffi.mjs`'s `scheduleIdleDrain` idle loop (or its call sites in
//// `startServer`/`stopServer`) ever regresses, this test hangs rather than
//// failing fast - there is no other safety net for that class of bug, since
//// every other test in this suite uses the fake-sync client, which always
//// pumps.
////
//// This also exercises the manual `start`/`stop` escape hatch: `stop` has
//// to run only after the async fetch resolves, which `with_stubs`/`simple`
//// can't guarantee (they call `stop` immediately after getting back the
//// still-pending `Promise` from the callback, not after it settles).

import gleam/http/response
import gleam/javascript/promise.{type Promise}
import http_server_mock
import http_server_mock_js

@external(javascript, "./async_fetch_ffi.mjs", "fetchGet")
fn fetch_get(url: String) -> Promise(#(Int, String))

pub fn async_client_can_reach_the_server_with_no_manual_pump_test() -> Promise(
  Nil,
) {
  let assert Ok(server) =
    http_server_mock.start_with_stubs(
      http_server_mock.new(http_server_mock_js.server()),
      [
        http_server_mock.stub(
          fn(req) { req.path == "/hello" },
          response.new(200) |> response.set_body("world"),
        ),
      ],
    )

  let url = http_server_mock.base_url(server) <> "/hello"

  use #(status, body) <- promise.await(fetch_get(url))
  http_server_mock.stop(server)

  assert status == 200
  assert body == "world"

  promise.resolve(Nil)
}
