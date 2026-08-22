// Runs inside the transport Worker thread. This file has no knowledge of
// stubs, matching, or Gleam at all - it only accepts HTTP connections and
// forwards each request to the main thread (over `workerPort`, received via
// workerData), where the real Stub closures live. See server_ffi.mjs for the
// main-thread side of this exchange and the reasoning behind the split.

import http from "node:http";
import { workerData } from "node:worker_threads";

const { workerPort } = workerData;

let server = null;
let nextId = 0;
const pending = new Map();

// `Object.fromEntries` would silently keep only the last value for a
// repeated header name (e.g. multiple Set-Cookie headers) - a `Response`
// built with `gleam/http/response.prepend_header` can legitimately carry
// several entries under the same key, and Node's `writeHead` accepts an
// array as a header value to send them all.
function groupHeaders(pairs) {
  const grouped = {};
  for (const [key, value] of pairs) {
    if (key in grouped) {
      if (Array.isArray(grouped[key])) {
        grouped[key].push(value);
      } else {
        grouped[key] = [grouped[key], value];
      }
    } else {
      grouped[key] = value;
    }
  }
  return grouped;
}

workerPort.on("message", (msg) => {
  if (msg.type === "listen") {
    server = http.createServer((req, res) => {
      const chunks = [];
      req.on("data", (chunk) => chunks.push(chunk));
      req.on("end", () => {
        const url = new URL(req.url, "http://localhost");
        const id = nextId++;
        pending.set(id, res);
        // The client's actual Host header, not `req.url` (which never
        // carries an authority for a non-proxy request, so parsing it with
        // any base would always report that base's host - not the host the
        // client actually asked for).
        const [hostname, portStr] = (req.headers.host || "localhost").split(
          ":",
        );
        workerPort.postMessage({
          type: "request",
          id,
          method: req.method,
          path: url.pathname,
          query: url.search ? url.search.slice(1) : "",
          headers: Object.entries(req.headers).map(([key, value]) => [
            key,
            Array.isArray(value) ? value.join(", ") : value,
          ]),
          body: Buffer.concat(chunks).toString("utf8"),
          host: hostname,
          port: portStr || "",
        });
      });
    });

    server.on("error", (err) => {
      workerPort.postMessage({ type: "listen_error", message: String(err) });
    });

    server.listen(msg.port, "0.0.0.0", () => {
      workerPort.postMessage({ type: "listening", port: server.address().port });
    });
    return;
  }

  if (msg.type === "response") {
    const res = pending.get(msg.id);
    if (res === undefined) return;
    pending.delete(msg.id);
    res.writeHead(msg.status, groupHeaders(msg.headers));
    res.end(msg.body);
    return;
  }

  if (msg.type === "shutdown") {
    if (server) {
      server.close(() => workerPort.postMessage({ type: "closed" }));
    } else {
      workerPort.postMessage({ type: "closed" });
    }
  }
});
