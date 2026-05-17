//// Core data types shared across all modules.
////
//// Most of these types are produced by the builder modules (`matcher`,
//// `response`, `stub`) and consumed by the server or `verify`. You generally
//// interact with them through those builders rather than constructing them
//// directly.

import gleam/dict.{type Dict}
import gleam/http.{type Method}
import gleam/option.{type Option}

/// Describes how a single string field of a request (path, header value, query
/// parameter value) must look for a stub to match.
pub type StringMatcher {
  /// The field must be exactly equal to the given string.
  Exact(String)
  /// The field must contain the given string as a substring.
  Contains(String)
  /// The field must start with the given string.
  Prefix(String)
  /// The field must end with the given string.
  Suffix(String)
  /// Any value is accepted (the field is not checked).
  AnyString
}

/// Describes how the request body must look for a stub to match.
pub type BodyMatcher {
  /// Any body is accepted (including an empty body).
  AnyBody
  /// The body must be exactly equal to the given string.
  ExactBody(String)
  /// The body must contain the given string as a substring.
  ContainsBody(String)
  /// The body must be semantically equal to the given JSON string (whitespace
  /// and key order are ignored).
  JsonBody(String)
}

/// The full set of conditions an incoming request must satisfy for a stub to
/// be selected. Conditions that are `None` or empty match anything.
///
/// Build one using the `matcher` module rather than constructing it directly.
pub type RequestMatcher {
  RequestMatcher(
    method: Option(Method),
    path: Option(StringMatcher),
    query_params: List(#(String, StringMatcher)),
    headers: List(#(String, StringMatcher)),
    body: BodyMatcher,
  )
}

/// The body of a stub response.
pub type ResponseBody {
  /// A plain text string body.
  StringBody(String)
  /// A raw JSON string body (sent as-is, without re-serialisation).
  RawJsonBody(String)
  /// A binary body.
  BytesBody(BitArray)
  /// No body — the response has an empty body.
  NoBody
}

/// Describes the HTTP response the server sends when a stub is matched.
///
/// Build one using the `response` module rather than constructing it directly.
pub type ResponseDefinition {
  ResponseDefinition(
    status: Int,
    headers: List(#(String, String)),
    body: ResponseBody,
    delay_ms: Option(Int),
  )
}

/// The state of a named scenario, used to model stateful request sequences.
///
/// Set via `stub.in_scenario`, `stub.when_state_is`, and
/// `stub.then_transition_to` rather than constructing this directly.
pub type ScenarioState {
  ScenarioState(
    /// The name of the scenario this stub belongs to.
    name: String,
    /// The scenario state that must be active for this stub to match.
    /// `None` means the stub is active only before the scenario has started.
    required_state: Option(String),
    /// The scenario state to transition to after this stub is matched.
    /// `None` means the scenario state does not change.
    new_state: Option(String),
  )
}

/// A stub pairs a `RequestMatcher` with a `ResponseDefinition`.
///
/// Build one using `stub.new` rather than constructing this directly.
pub type Stub {
  Stub(
    /// Unique identifier for this stub. Used in `RecordedRequest.matched_stub_id`
    /// and the `/__admin/stubs` listing.
    id: String,
    /// Lower values take precedence when multiple stubs match the same request.
    priority: Int,
    matcher: RequestMatcher,
    response: ResponseDefinition,
    scenario: Option(ScenarioState),
  )
}

/// A request that the mock server received and recorded.
///
/// Returned by `http_server_mock.recorded_requests` and used with the `verify`
/// module to assert that expected requests were made.
pub type RecordedRequest {
  RecordedRequest(
    /// Unique identifier for this recorded request.
    id: String,
    method: Method,
    path: String,
    /// The raw query string, without the leading `?`. `None` if absent.
    query: Option(String),
    /// All request headers, with names normalised to lowercase.
    headers: Dict(String, String),
    body: String,
    /// Unix timestamp in milliseconds when the request was received.
    timestamp_ms: Int,
    /// The ID of the stub that matched this request, or `None` if no stub
    /// matched (in which case the server returned 404).
    matched_stub_id: Option(String),
  )
}
