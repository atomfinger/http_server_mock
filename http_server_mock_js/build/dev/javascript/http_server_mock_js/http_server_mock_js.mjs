import * as $dynamic from "../gleam_stdlib/gleam/dynamic.mjs";
import * as $server_adapter from "../http_server_mock/http_server_mock/server_adapter.mjs";
import { ServerAdapter } from "../http_server_mock/http_server_mock/server_adapter.mjs";
import {
  clearRequests as do_clear_requests,
  getRequests as do_get_requests,
  getStubs as do_get_stubs,
  clearStubs as do_clear_stubs,
  removeStub as do_remove_stub,
  addStub as do_add_stub,
  stopServer as do_stop,
  startServer as do_start,
} from "./http_server_mock/internal/server_ffi.mjs";

/**
 * Returns the JavaScript/Node.js server adapter.
 *
 * Pass this to `http_server_mock.new/1` to create a mock server backed by a
 * Node.js Worker thread:
 *
 * ```gleam
 * let server =
 *   http_server_mock.new(http_server_mock_js.server())
 *   |> http_server_mock.start()
 * ```
 */
export function server() {
  return new ServerAdapter(
    do_start,
    do_stop,
    do_add_stub,
    do_remove_stub,
    do_clear_stubs,
    do_get_stubs,
    do_get_requests,
    do_clear_requests,
  );
}
