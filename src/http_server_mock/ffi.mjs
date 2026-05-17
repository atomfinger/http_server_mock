// General-purpose FFI utilities for the http_server_mock JS target.

let _idCounter = 0;

export function generateId() {
  return "id_" + Date.now() + "_" + ++_idCounter;
}
