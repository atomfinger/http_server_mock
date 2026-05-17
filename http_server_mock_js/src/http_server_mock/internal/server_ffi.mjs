// Node.js HTTP server for the JS target of http_server_mock.
//
// The HTTP server and its state (stubs, recorded requests, scenarios) run in a
// dedicated Worker thread (see worker.mjs).  All exported functions are
// synchronous: they post a command to the worker and spin on a SharedArrayBuffer
// signal until the worker replies, then drain the reply with receiveMessageOnPort.
// Worker threads run in true OS threads so the main-thread spin loop does NOT
// prevent the worker from making progress.

import { Ok, Error as GError } from "../../gleam.mjs";
import { Worker, MessageChannel, receiveMessageOnPort } from "node:worker_threads";

// Atomics.wait() is not allowed on the main thread (V8/Node restriction), so
// we spin on Atomics.load(). Worker threads run as true OS threads, so the
// main-thread spin loop does NOT starve the worker.
const SPIN_TIMEOUT_MS = 5000;

function spinWait(signal) {
  const deadline = Date.now() + SPIN_TIMEOUT_MS;
  while (Atomics.load(signal, 0) === 0) {
    if (Date.now() > deadline) return false;
  }
  return true;
}

function sendCommand(handle, command, data) {
  Atomics.store(handle.signal, 0, 0);
  handle.port.postMessage({ cmd: command, data });
  if (!spinWait(handle.signal)) return null;
  Atomics.store(handle.signal, 0, 0);
  const envelope = receiveMessageOnPort(handle.port);
  return envelope ? envelope.message.result : null;
}

function waitForStartup(handle) {
  if (!spinWait(handle.signal)) return null;
  Atomics.store(handle.signal, 0, 0);
  return receiveMessageOnPort(handle.port);
}

export function startServer(port) {
  const { port1: mainPort, port2: workerPort } = new MessageChannel();
  const signalBuffer = new SharedArrayBuffer(4);
  const signal = new Int32Array(signalBuffer);

  let worker;
  try {
    worker = new Worker(new URL("./worker.mjs", import.meta.url), {
      workerData: { signalBuffer, requestedPort: port, workerPort },
      transferList: [workerPort],
    });
  } catch (err) {
    return new GError("Failed to start worker: " + err.message);
  }

  const handle = { worker, port: mainPort, signal };
  const envelope = waitForStartup(handle);
  if (!envelope) return new GError("Worker did not respond within timeout");

  const message = envelope.message;
  if (!message.ok) return new GError(message.error);

  return new Ok([message.port, handle]);
}

export function stopServer(handle) {
  if (!handle) return;
  sendCommand(handle, "stop", null);
  handle.worker.terminate();
}

export function addStub(handle, stubJson) {
  const stubId = sendCommand(handle, "addStub", stubJson);
  if (typeof stubId === "string") return new Ok(stubId);
  return new GError((stubId && stubId.error) || "Unknown error");
}

export function removeStub(handle, stubId) {
  sendCommand(handle, "removeStub", stubId);
}

export function clearStubs(handle) {
  sendCommand(handle, "clearStubs", null);
}

export function getStubs(handle) {
  return sendCommand(handle, "getStubs", null) ?? "[]";
}

export function getRequests(handle) {
  return sendCommand(handle, "getRequests", null) ?? "[]";
}

export function clearRequests(handle) {
  sendCommand(handle, "clearRequests", null);
}
