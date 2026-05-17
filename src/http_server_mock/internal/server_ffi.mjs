// Node.js HTTP server for the JS target of http_server_mock.
//
// The entire HTTP server and its state (stubs, recorded requests, scenarios)
// run in a dedicated Worker thread.  All exported functions are synchronous:
// they post a command to the worker and spin on a SharedArrayBuffer signal
// until the worker replies, then drain the reply with receiveMessageOnPort.
// Worker threads run in true OS threads so the main-thread spin loop does NOT
// prevent the worker from making progress.

import { Ok, Error as GError } from "../../gleam.mjs";
import { Worker, MessageChannel, receiveMessageOnPort } from "node:worker_threads";

const WORKER_SOURCE = `
import http from "node:http";
import { workerData, parentPort } from "node:worker_threads";

const { signalBuffer, requestedPort, workerPort } = workerData;
const signal = new Int32Array(signalBuffer);

const state = {
  stubs: [],
  requests: [],
  scenarios: new Map(),
};

const server = http.createServer((req, res) => {
  const chunks = [];
  req.on("data", (chunk) => chunks.push(chunk));
  req.on("end", () => {
    const body = Buffer.concat(chunks).toString("utf8");
    const url = new URL(req.url, "http://localhost");
    const path = url.pathname;
    const query = url.search ? url.search.slice(1) : null;
    const headers = normalizeHeaders(req.headers);

    if (path.startsWith("/__admin")) {
      handleAdmin(req.method.toUpperCase(), path, body, (status, data) => {
        res.statusCode = status;
        res.setHeader("content-type", "application/json");
        res.end(JSON.stringify(data));
      });
    } else {
      handleStub(req.method.toUpperCase(), path, query, headers, body,
        (status, hdrs, content, delayMs) => {
          const send = () => {
            res.statusCode = status;
            for (const [k, v] of Object.entries(hdrs)) res.setHeader(k, v);
            res.end(content);
          };
          delayMs > 0 ? setTimeout(send, delayMs) : send();
        }
      );
    }
  });
});

server.listen(requestedPort, "0.0.0.0", () => {
  const actualPort = server.address().port;
  workerPort.postMessage({ ok: true, port: actualPort });
  signalReady();
});

server.on("error", (err) => {
  workerPort.postMessage({ ok: false, error: err.message });
  signalReady();
});

workerPort.on("message", ({ cmd, data }) => {
  let result;
  switch (cmd) {
    case "addStub":    result = addStub(data);             break;
    case "removeStub": removeStub(data); result = null;    break;
    case "clearStubs": state.stubs = []; result = null;    break;
    case "getStubs":   result = JSON.stringify(state.stubs);   break;
    case "getRequests": result = JSON.stringify(state.requests); break;
    case "clearRequests": state.requests = []; result = null;  break;
    case "stop":       server.close(); result = null;      break;
    default:           result = null;
  }
  workerPort.postMessage({ result });
  signalReady();
});

function signalReady() {
  Atomics.store(signal, 0, 1);
  Atomics.notify(signal, 0, 1);
}

function handleAdmin(method, path, body, send) {
  if (method === "GET"  && path === "/__admin/health")
    return send(200, { status: "ok" });
  if (method === "GET"  && path === "/__admin/stubs")
    return send(200, state.stubs);
  if (method === "POST" && path === "/__admin/stubs") {
    const id = addStub(body);
    return typeof id === "string"
      ? send(201, { id })
      : send(400, { error: id.error });
  }
  if (method === "DELETE" && path === "/__admin/stubs") {
    state.stubs = [];
    return send(200, { status: "ok" });
  }
  if (method === "GET"    && path === "/__admin/requests")
    return send(200, state.requests);
  if (method === "DELETE" && path === "/__admin/requests") {
    state.requests = [];
    return send(200, { status: "ok" });
  }
  send(404, { error: "Unknown admin endpoint" });
}

function addStub(stubJson) {
  try {
    const stub = JSON.parse(stubJson);
    const idx = state.stubs.findIndex((existing) => existing.id === stub.id);
    if (idx >= 0) state.stubs[idx] = stub;
    else          state.stubs.push(stub);
    state.stubs.sort((left, right) => left.priority - right.priority);
    return stub.id;
  } catch (err) {
    return { error: "Invalid stub JSON: " + err.message };
  }
}

function removeStub(stubId) {
  state.stubs = state.stubs.filter((stub) => stub.id !== stubId);
}

function handleStub(method, path, query, headers, body, send) {
  const recorded = {
    id: "req_" + Date.now() + "_" + Math.random().toString(36).slice(2),
    method, path, query, headers, body,
    timestamp_ms: Date.now(),
    matched_stub_id: null,
  };

  const match = findMatch(recorded);
  if (!match) {
    state.requests.push(recorded);
    return send(
      404,
      { "content-type": "application/json" },
      JSON.stringify({ status: 404, message: "No stub matched", path }),
      0,
    );
  }

  recorded.matched_stub_id = match.stub.id;
  state.requests.push(recorded);
  advanceScenario(match.stub);

  const def = match.stub.response;
  const responseHeaders = {};
  (def.headers || []).forEach(({ key, value }) => { responseHeaders[key] = value; });
  send(def.status, responseHeaders, getResponseBodyContent(def.body), def.delay_ms ?? 0);
}

function findMatch(recorded) {
  const candidates = state.stubs
    .filter((stub) => scenarioMatches(stub))
    .filter((stub) => stubMatches(stub, recorded))
    .sort((left, right) => {
      if (left.priority !== right.priority) return left.priority - right.priority;
      return scoreStub(right, recorded) - scoreStub(left, recorded);
    });
  return candidates.length === 0 ? null : { stub: candidates[0] };
}

function scenarioMatches(stub) {
  if (!stub.scenario) return true;
  const currentState = state.scenarios.get(stub.scenario.name);
  if (stub.scenario.required_state == null) return currentState === undefined;
  return currentState === stub.scenario.required_state;
}

function stubMatches(stub, recorded) {
  const matcher = stub.request;
  if (matcher.method && matcher.method !== recorded.method) return false;
  if (matcher.path   && !matchString(matcher.path, recorded.path)) return false;
  const queryParams = parseQuery(recorded.query || "");
  for (const { key, matcher: sm } of matcher.query_params || []) {
    const value = queryParams.get(key);
    if (value === undefined) { if (sm.type !== "any") return false; }
    else if (!matchString(sm, value)) return false;
  }
  for (const { key, matcher: sm } of matcher.headers || []) {
    const value = recorded.headers[key.toLowerCase()];
    if (value === undefined) { if (sm.type !== "any") return false; }
    else if (!matchString(sm, value)) return false;
  }
  if (matcher.body && !matchBody(matcher.body, recorded.body)) return false;
  return true;
}

function matchString(stringMatcher, value) {
  switch (stringMatcher.type) {
    case "exact":    return value === stringMatcher.value;
    case "contains": return value.includes(stringMatcher.value);
    case "prefix":   return value.startsWith(stringMatcher.value);
    case "suffix":   return value.endsWith(stringMatcher.value);
    case "any":      return true;
    default:         return false;
  }
}

function matchBody(bodyMatcher, actual) {
  switch (bodyMatcher.type) {
    case "any":      return true;
    case "exact":    return actual === bodyMatcher.value;
    case "contains": return actual.includes(bodyMatcher.value);
    case "json": {
      try {
        return JSON.stringify(JSON.parse(actual)) ===
               JSON.stringify(JSON.parse(bodyMatcher.value));
      } catch { return false; }
    }
    default: return false;
  }
}

function scoreStub(stub, _recorded) {
  const matcher = stub.request;
  let score = 0;
  if (matcher.method) score += 100;
  if (matcher.path)   score += matcher.path.type === "exact" ? 80 : 40;
  score += (matcher.query_params || []).length * 20;
  score += (matcher.headers || []).length * 10;
  if (matcher.body)   score += matcher.body.type === "exact" ? 50 : 30;
  return score;
}

function advanceScenario(stub) {
  if (!stub.scenario || !stub.scenario.new_state) return;
  state.scenarios.set(stub.scenario.name, stub.scenario.new_state);
}

function parseQuery(queryString) {
  const map = new Map();
  if (!queryString) return map;
  for (const part of queryString.split("&")) {
    const idx = part.indexOf("=");
    if (idx >= 0) map.set(part.slice(0, idx), part.slice(idx + 1));
    else          map.set(part, "");
  }
  return map;
}

function getResponseBodyContent(body) {
  if (!body || body.type === "none") return "";
  return body.value || "";
}

function normalizeHeaders(headers) {
  const normalized = {};
  for (const [key, value] of Object.entries(headers || {})) {
    normalized[key.toLowerCase()] = Array.isArray(value) ? value.join(", ") : value;
  }
  return normalized;
}
`;

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
    worker = new Worker(
      new URL(`data:text/javascript,${encodeURIComponent(WORKER_SOURCE)}`),
      {
        workerData: { signalBuffer, requestedPort: port, workerPort },
        transferList: [workerPort],
      },
    );
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
