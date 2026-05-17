//// Builder for `ResponseDefinition` — what the server sends back when a stub
//// matches an incoming request.
////
//// Start with `new()` (or one of the shorthand constructors) and pipe through
//// the functions you need.
////
//// ```gleam
//// let resp =
////   response.new()
////   |> response.status(201)
////   |> response.header("x-request-id", "abc123")
////   |> response.json_body("{\"id\":1,\"status\":\"created\"}")
//// ```

import gleam/option.{None, Some}
import http_server_mock/types.{
  type ResponseDefinition, NoBody, RawJsonBody, ResponseDefinition, StringBody,
}

/// Returns a new `ResponseDefinition` with status 200, no headers, and no body.
pub fn new() -> ResponseDefinition {
  ResponseDefinition(status: 200, headers: [], body: NoBody, delay_ms: None)
}

/// Sets the HTTP status code for the response.
pub fn status(response_def: ResponseDefinition, code: Int) -> ResponseDefinition {
  ResponseDefinition(..response_def, status: code)
}

/// Adds a response header. Can be called multiple times to add several headers.
pub fn header(
  response_def: ResponseDefinition,
  key: String,
  value: String,
) -> ResponseDefinition {
  ResponseDefinition(
    ..response_def,
    headers: [#(key, value), ..response_def.headers],
  )
}

/// Sets the response body to a plain text string.
pub fn body(response_def: ResponseDefinition, text: String) -> ResponseDefinition {
  ResponseDefinition(..response_def, body: StringBody(text))
}

/// Sets the response body to a JSON string and automatically adds a
/// `content-type: application/json` header.
pub fn json_body(
  response_def: ResponseDefinition,
  json: String,
) -> ResponseDefinition {
  let with_content_type =
    ResponseDefinition(
      ..response_def,
      headers: [
        #("content-type", "application/json"),
        ..response_def.headers
      ],
    )
  ResponseDefinition(..with_content_type, body: RawJsonBody(json))
}

/// Delays the response by `milliseconds` before sending it.
///
/// Useful for testing timeout handling or slow-network behaviour.
pub fn delay(
  response_def: ResponseDefinition,
  milliseconds: Int,
) -> ResponseDefinition {
  ResponseDefinition(..response_def, delay_ms: Some(milliseconds))
}

/// Returns a `ResponseDefinition` for HTTP 200 OK with no body.
pub fn ok() -> ResponseDefinition {
  ResponseDefinition(status: 200, headers: [], body: NoBody, delay_ms: None)
}

/// Returns a `ResponseDefinition` for HTTP 404 Not Found with no body.
pub fn not_found() -> ResponseDefinition {
  ResponseDefinition(status: 404, headers: [], body: NoBody, delay_ms: None)
}

/// Returns a `ResponseDefinition` for HTTP 500 Internal Server Error with no body.
pub fn server_error() -> ResponseDefinition {
  ResponseDefinition(status: 500, headers: [], body: NoBody, delay_ms: None)
}
