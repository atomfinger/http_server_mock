// Main-thread side of the mock server. Owns the real Stub closures and all
// server state; the transport worker (worker.mjs) is a dumb HTTP listener
// that forwards each request here and waits for an answer. See
// sync_pump.mjs for why this side never uses a `.on("message", ...)`
// listener on its port - only `receiveMessageOnPort`, so both the idle
// (async) and spin-wait (fake-sync test) cases can drive the same drain
// function without racing over the port's delivery mode.

import { MessageChannel, Worker, receiveMessageOnPort } from "node:worker_threads";
import { Ok, Error, toList } from "../../gleam.mjs";
import { registerPump } from "./sync_pump.mjs";
import {
  add_stub as implAddStub,
  clear_requests as implClearRequests,
  clear_stubs as implClearStubs,
  get_requests as implGetRequests,
  get_requests_by_stub as implGetRequestsByStub,
  get_unmatched_requests as implGetUnmatchedRequests,
  handle_request as implHandleRequest,
  initial_state,
  remove_stub as implRemoveStub,
} from "./server_impl.mjs";

const WORKER_URL = new URL("./worker.mjs", import.meta.url);
const START_TIMEOUT_MS = 5000;
const SHUTDOWN_TIMEOUT_MS = 5000;
const NOT_FOUND_BODY_PREFIX = '{"status":404,"message":"No stub matched","path":"';

function drainOnce(handle) {
  const envelope = receiveMessageOnPort(handle.port);
  if (!envelope) return false;
  const msg = envelope.message;

  switch (msg.type) {
    case "listening":
      handle.listeningPort = msg.port;
      break;
    case "listen_error":
      handle.listenError = msg.message;
      break;
    case "closed":
      handle.closed = true;
      break;
    case "request":
      implHandleRequest(
        handle.state,
        msg.method,
        msg.path,
        msg.query,
        toGleamHeaders(msg.headers),
        msg.body,
        msg.host,
        msg.port,
        (newState, found, status, headers, body) => {
          handle.state = newState;
          handle.port.postMessage({
            type: "response",
            id: msg.id,
            status: found ? status : 404,
            headers: found
              ? [...headers]
              : [["content-type", "application/json"]],
            body: found
              ? body
              : NOT_FOUND_BODY_PREFIX + msg.path + '"}',
          });
        },
      );
      break;
  }
  return true;
}

function blockUntil(handle, isDone, timeoutMs) {
  const deadline = Date.now() + timeoutMs;
  while (!isDone()) {
    while (drainOnce(handle)) {
      if (isDone()) return true;
    }
    if (Date.now() > deadline) return false;
  }
  return true;
}

// Drives the ordinary (non-spin-wait) case: an async client - `fetch`, a
// Promise-based request - never calls `pumpAll()` itself, so without this
// nothing would ever drain `handle.port` for it and the request would hang
// forever. `setImmediate` runs this once per turn of the event loop's check
// phase, draining whatever's pending and yielding back in between - this is
// NOT a busy-spin (contrast with `blockUntil`, used only for the brief,
// timeout-bounded startup/shutdown handshake): it's the standard cooperative
// polling idiom for something that must run as long as the server is up
// without ever blocking the event loop.
function scheduleIdleDrain(handle) {
  while (drainOnce(handle)) {}
  if (!handle.stopping) {
    handle.idleTimer = setImmediate(() => scheduleIdleDrain(handle));
  }
}

function toGleamHeaders(pairs) {
  // A Gleam `#(String, String)` tuple compiles to a plain 2-element JS
  // array, so a JS array of `[key, value]` pairs is already shaped right -
  // `toList` just needs to wrap it in a real gleam_stdlib List instance.
  return toList(pairs);
}

export function startServer(port, stubs) {
  const { port1: mainPort, port2: workerPort } = new MessageChannel();
  const worker = new Worker(WORKER_URL, {
    workerData: { workerPort },
    transferList: [workerPort],
  });

  const handle = {
    worker,
    port: mainPort,
    state: initial_state(stubs),
    listeningPort: null,
    listenError: null,
    closed: false,
    unregisterPump: null,
    idleTimer: null,
    stopping: false,
  };

  mainPort.postMessage({ type: "listen", port });

  const answered = blockUntil(
    handle,
    () => handle.listeningPort !== null || handle.listenError !== null,
    START_TIMEOUT_MS,
  );

  if (!answered) {
    worker.terminate();
    return new Error(
      "Timed out waiting for the mock server's transport worker to start listening",
    );
  }
  if (handle.listenError !== null) {
    worker.terminate();
    return new Error(handle.listenError);
  }

  handle.unregisterPump = registerPump(() => drainOnce(handle));
  scheduleIdleDrain(handle);

  return new Ok([handle.listeningPort, handle]);
}

export function stopServer(handle) {
  handle.stopping = true;
  if (handle.idleTimer) clearImmediate(handle.idleTimer);
  if (handle.unregisterPump) handle.unregisterPump();
  handle.port.postMessage({ type: "shutdown" });
  blockUntil(handle, () => handle.closed, SHUTDOWN_TIMEOUT_MS);
  handle.worker.terminate();
  return undefined;
}

export function addStub(handle, stub) {
  handle.state = implAddStub(handle.state, stub);
  return undefined;
}

export function removeStub(handle, stub) {
  handle.state = implRemoveStub(handle.state, stub);
  return undefined;
}

export function clearStubs(handle) {
  handle.state = implClearStubs(handle.state);
  return undefined;
}

export function clearRequests(handle) {
  handle.state = implClearRequests(handle.state);
  return undefined;
}

export function getRequests(handle) {
  return implGetRequests(handle.state);
}

export function getUnmatchedRequests(handle) {
  return implGetUnmatchedRequests(handle.state);
}

export function getRequestsByStub(handle, stub) {
  return implGetRequestsByStub(handle.state, stub);
}
