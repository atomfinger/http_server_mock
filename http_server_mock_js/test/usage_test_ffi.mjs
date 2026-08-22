// Synchronous HTTP helpers for http_server_mock_js_test.gleam. See
// http_server_mock/integration_test_ffi.mjs for the full explanation of why
// this spin loop also pumps the mock server's callback channel.

import { Worker, receiveMessageOnPort, MessageChannel } from "node:worker_threads";
import { pumpAll } from "./http_server_mock/internal/sync_pump.mjs";

const WORKER_SOURCE = `
import http from "node:http";
import { workerData, parentPort } from "node:worker_threads";

const { signalBuffer, workerPort } = workerData;
const signal = new Int32Array(signalBuffer);

workerPort.on("message", ({ url, method, body, headers }) => {
  const parsed = new URL(url);
  const options = {
    hostname: parsed.hostname,
    port: parseInt(parsed.port, 10) || 80,
    path: parsed.pathname + (parsed.search || ""),
    method: method || "GET",
    headers: headers || {},
  };

  const req = http.request(options, (res) => {
    const chunks = [];
    res.on("data", (chunk) => chunks.push(chunk));
    res.on("end", () => {
      workerPort.postMessage({
        status: res.statusCode,
        body: Buffer.concat(chunks).toString("utf8"),
      });
      Atomics.store(signal, 0, 1);
      Atomics.notify(signal, 0, 1);
    });
  });

  req.on("error", (err) => {
    workerPort.postMessage({ error: err.message });
    Atomics.store(signal, 0, 1);
    Atomics.notify(signal, 0, 1);
  });

  if (body) req.write(body);
  req.end();
});
`;

const SPIN_TIMEOUT_MS = 10_000;

function spinWait(signal) {
  const deadline = Date.now() + SPIN_TIMEOUT_MS;
  while (Atomics.load(signal, 0) === 0) {
    pumpAll();
    if (Date.now() > deadline) return false;
  }
  return true;
}

let handle = null;

function getHandle() {
  if (handle) return handle;
  const { port1: mainPort, port2: workerPort } = new MessageChannel();
  const signalBuffer = new SharedArrayBuffer(4);
  const signal = new Int32Array(signalBuffer);
  new Worker(
    new URL(`data:text/javascript,${encodeURIComponent(WORKER_SOURCE)}`),
    { workerData: { signalBuffer, workerPort }, transferList: [workerPort] },
  );
  handle = { port: mainPort, signal };
  return handle;
}

function request(url, method, body, headers) {
  const h = getHandle();
  Atomics.store(h.signal, 0, 0);
  h.port.postMessage({ url, method, body, headers });
  if (!spinWait(h.signal)) throw new Error("HTTP request timed out after " + SPIN_TIMEOUT_MS + "ms");
  Atomics.store(h.signal, 0, 0);
  const envelope = receiveMessageOnPort(h.port);
  if (!envelope) throw new Error("No response received from HTTP worker");
  const msg = envelope.message;
  if (msg.error) throw new Error("HTTP request failed: " + msg.error);
  // A plain 2-tuple (a Gleam `#(a, b)` compiles to a JS array) so the Gleam
  // side constructs TestResponse itself, rather than a duck-typed object
  // standing in for a type whose constructor Gleam never calls.
  return [msg.status, msg.body];
}

export function syncGet(url) {
  return request(url, "GET", null, {});
}

export function syncPost(url, body, contentType) {
  return request(url, "POST", body, { "content-type": contentType });
}
