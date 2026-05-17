import * as $option from "../../gleam_stdlib/gleam/option.mjs";
import { None, Some } from "../../gleam_stdlib/gleam/option.mjs";
import { toList, prepend as listPrepend } from "../gleam.mjs";
import * as $types from "../http_server_mock/types.mjs";
import { NoBody, RawJsonBody, ResponseDefinition, StringBody } from "../http_server_mock/types.mjs";

/**
 * Returns a new `ResponseDefinition` with status 200, no headers, and no body.
 */
export function new$() {
  return new ResponseDefinition(200, toList([]), new NoBody(), new None());
}

/**
 * Sets the HTTP status code for the response.
 */
export function status(response_def, code) {
  return new ResponseDefinition(
    code,
    response_def.headers,
    response_def.body,
    response_def.delay_ms,
  );
}

/**
 * Adds a response header. Can be called multiple times to add several headers.
 */
export function header(response_def, key, value) {
  return new ResponseDefinition(
    response_def.status,
    listPrepend([key, value], response_def.headers),
    response_def.body,
    response_def.delay_ms,
  );
}

/**
 * Sets the response body to a plain text string.
 */
export function body(response_def, text) {
  return new ResponseDefinition(
    response_def.status,
    response_def.headers,
    new StringBody(text),
    response_def.delay_ms,
  );
}

/**
 * Sets the response body to a JSON string and automatically adds a
 * `content-type: application/json` header.
 */
export function json_body(response_def, json) {
  let with_content_type = new ResponseDefinition(
    response_def.status,
    listPrepend(["content-type", "application/json"], response_def.headers),
    response_def.body,
    response_def.delay_ms,
  );
  return new ResponseDefinition(
    with_content_type.status,
    with_content_type.headers,
    new RawJsonBody(json),
    with_content_type.delay_ms,
  );
}

/**
 * Delays the response by `milliseconds` before sending it.
 *
 * Useful for testing timeout handling or slow-network behaviour.
 */
export function delay(response_def, milliseconds) {
  return new ResponseDefinition(
    response_def.status,
    response_def.headers,
    response_def.body,
    new Some(milliseconds),
  );
}

/**
 * Returns a `ResponseDefinition` for HTTP 200 OK with no body.
 */
export function ok() {
  return new ResponseDefinition(200, toList([]), new NoBody(), new None());
}

/**
 * Returns a `ResponseDefinition` for HTTP 404 Not Found with no body.
 */
export function not_found() {
  return new ResponseDefinition(404, toList([]), new NoBody(), new None());
}

/**
 * Returns a `ResponseDefinition` for HTTP 500 Internal Server Error with no body.
 */
export function server_error() {
  return new ResponseDefinition(500, toList([]), new NoBody(), new None());
}
