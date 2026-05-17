import gleam/dict
import gleam/dynamic/decode
import gleam/http
import gleam/int
import gleam/json
import gleam/list
import gleam/option.{None, Some}
import gleam/string
import http_server_mock/types.{
  type BodyMatcher, type RecordedRequest, type RequestMatcher,
  type ResponseBody, type ResponseDefinition, type ScenarioState, type Stub,
  type StringMatcher, AnyBody, AnyString, BytesBody, ContainsBody, Contains,
  Exact, ExactBody, JsonBody, NoBody, Prefix, RawJsonBody, RecordedRequest,
  RequestMatcher, ResponseDefinition, ScenarioState, StringBody, Stub, Suffix,
}

pub fn encode_stub(stub: Stub) -> String {
  encode_stub_json(stub) |> json.to_string
}

pub fn encode_stubs(stubs: List(Stub)) -> String {
  json.array(stubs, encode_stub_json) |> json.to_string
}

pub fn encode_recorded_request(recorded_request: RecordedRequest) -> String {
  encode_recorded_request_json(recorded_request) |> json.to_string
}

pub fn encode_recorded_requests(
  recorded_requests: List(RecordedRequest),
) -> String {
  json.array(recorded_requests, encode_recorded_request_json) |> json.to_string
}

fn encode_stub_json(stub: Stub) -> json.Json {
  json.object([
    #("id", json.string(stub.id)),
    #("priority", json.int(stub.priority)),
    #("request", encode_matcher_json(stub.matcher)),
    #("response", encode_response_def_json(stub.response)),
    #("scenario", case stub.scenario {
      None -> json.null()
      Some(scenario_state) -> encode_scenario_json(scenario_state)
    }),
  ])
}

fn encode_matcher_json(request_matcher: RequestMatcher) -> json.Json {
  json.object([
    #("method", case request_matcher.method {
      None -> json.null()
      Some(method) -> json.string(http.method_to_string(method))
    }),
    #("path", case request_matcher.path {
      None -> json.null()
      Some(string_matcher) -> encode_string_matcher_json(string_matcher)
    }),
    #("query_params", json.array(request_matcher.query_params, fn(query_param_pair) {
      let #(key, string_matcher) = query_param_pair
      json.object([
        #("key", json.string(key)),
        #("matcher", encode_string_matcher_json(string_matcher)),
      ])
    })),
    #("headers", json.array(request_matcher.headers, fn(header_pair) {
      let #(key, string_matcher) = header_pair
      json.object([
        #("key", json.string(key)),
        #("matcher", encode_string_matcher_json(string_matcher)),
      ])
    })),
    #("body", encode_body_matcher_json(request_matcher.body)),
  ])
}

fn encode_string_matcher_json(string_matcher: StringMatcher) -> json.Json {
  case string_matcher {
    Exact(value) ->
      json.object([#("type", json.string("exact")), #("value", json.string(value))])
    Contains(value) ->
      json.object([#("type", json.string("contains")), #("value", json.string(value))])
    Prefix(value) ->
      json.object([#("type", json.string("prefix")), #("value", json.string(value))])
    Suffix(value) ->
      json.object([#("type", json.string("suffix")), #("value", json.string(value))])
    AnyString -> json.object([#("type", json.string("any"))])
  }
}

fn encode_body_matcher_json(body_matcher: BodyMatcher) -> json.Json {
  case body_matcher {
    AnyBody -> json.object([#("type", json.string("any"))])
    ExactBody(value) ->
      json.object([#("type", json.string("exact")), #("value", json.string(value))])
    ContainsBody(value) ->
      json.object([#("type", json.string("contains")), #("value", json.string(value))])
    JsonBody(value) ->
      json.object([#("type", json.string("json")), #("value", json.string(value))])
  }
}

fn encode_response_def_json(response_def: ResponseDefinition) -> json.Json {
  json.object([
    #("status", json.int(response_def.status)),
    #("headers", json.array(response_def.headers, fn(header_pair) {
      let #(key, value) = header_pair
      json.object([#("key", json.string(key)), #("value", json.string(value))])
    })),
    #("body", encode_response_body_json(response_def.body)),
    #("delay_ms", case response_def.delay_ms {
      None -> json.null()
      Some(milliseconds) -> json.int(milliseconds)
    }),
  ])
}

fn encode_response_body_json(body: ResponseBody) -> json.Json {
  case body {
    NoBody -> json.object([#("type", json.string("none"))])
    StringBody(text) ->
      json.object([#("type", json.string("string")), #("value", json.string(text))])
    RawJsonBody(json_text) ->
      json.object([#("type", json.string("json")), #("value", json.string(json_text))])
    BytesBody(_) -> json.object([#("type", json.string("none"))])
  }
}

fn encode_scenario_json(scenario_state: ScenarioState) -> json.Json {
  json.object([
    #("name", json.string(scenario_state.name)),
    #("required_state", case scenario_state.required_state {
      None -> json.null()
      Some(state) -> json.string(state)
    }),
    #("new_state", case scenario_state.new_state {
      None -> json.null()
      Some(state) -> json.string(state)
    }),
  ])
}

fn encode_recorded_request_json(
  recorded_request: RecordedRequest,
) -> json.Json {
  json.object([
    #("id", json.string(recorded_request.id)),
    #("method", json.string(http.method_to_string(recorded_request.method))),
    #("path", json.string(recorded_request.path)),
    #("query", case recorded_request.query {
      None -> json.null()
      Some(query_string) -> json.string(query_string)
    }),
    #("headers", json.object(
      dict.to_list(recorded_request.headers)
      |> list.map(fn(header_pair) {
        let #(key, value) = header_pair
        #(key, json.string(value))
      }),
    )),
    #("body", json.string(recorded_request.body)),
    #("timestamp_ms", json.int(recorded_request.timestamp_ms)),
    #("matched_stub_id", case recorded_request.matched_stub_id {
      None -> json.null()
      Some(stub_id) -> json.string(stub_id)
    }),
  ])
}

pub fn decode_stub(json_string: String) -> Result(Stub, String) {
  json.parse(from: json_string, using: stub_decoder())
  |> map_decode_error
}

pub fn decode_stubs(json_string: String) -> Result(List(Stub), String) {
  json.parse(from: json_string, using: decode.list(stub_decoder()))
  |> map_decode_error
}

fn stub_decoder() -> decode.Decoder(Stub) {
  use id <- decode.field("id", decode.string)
  use priority <- decode.field("priority", decode.int)
  use request_matcher <- decode.field("request", request_matcher_decoder())
  use response_def <- decode.field("response", response_def_decoder())
  use scenario_state <- decode.field(
    "scenario",
    decode.optional(scenario_decoder()),
  )
  decode.success(Stub(
    id: id,
    priority: priority,
    matcher: request_matcher,
    response: response_def,
    scenario: scenario_state,
  ))
}

fn request_matcher_decoder() -> decode.Decoder(RequestMatcher) {
  use method_string <- decode.field("method", decode.optional(decode.string))
  use path_matcher <- decode.field(
    "path",
    decode.optional(string_matcher_decoder()),
  )
  use query_params <- decode.field(
    "query_params",
    decode.list(key_matcher_decoder()),
  )
  use headers <- decode.field("headers", decode.list(key_matcher_decoder()))
  use body_matcher <- decode.field("body", body_matcher_decoder())
  decode.success(RequestMatcher(
    method: case method_string {
      None -> None
      Some(method_str) ->
        case http.parse_method(method_str) {
          Ok(method) -> Some(method)
          Error(Nil) -> None
        }
    },
    path: path_matcher,
    query_params: query_params,
    headers: headers,
    body: body_matcher,
  ))
}

fn key_matcher_decoder() -> decode.Decoder(#(String, StringMatcher)) {
  use key <- decode.field("key", decode.string)
  use string_matcher <- decode.field("matcher", string_matcher_decoder())
  decode.success(#(key, string_matcher))
}

fn string_matcher_decoder() -> decode.Decoder(StringMatcher) {
  use type_value <- decode.field("type", decode.string)
  case type_value {
    "any" -> decode.success(AnyString)
    "exact" -> {
      use value <- decode.field("value", decode.string)
      decode.success(Exact(value))
    }
    "contains" -> {
      use value <- decode.field("value", decode.string)
      decode.success(Contains(value))
    }
    "prefix" -> {
      use value <- decode.field("value", decode.string)
      decode.success(Prefix(value))
    }
    "suffix" -> {
      use value <- decode.field("value", decode.string)
      decode.success(Suffix(value))
    }
    _ -> decode.failure(AnyString, "StringMatcher type")
  }
}

fn body_matcher_decoder() -> decode.Decoder(BodyMatcher) {
  use type_value <- decode.field("type", decode.string)
  case type_value {
    "any" -> decode.success(AnyBody)
    "exact" -> {
      use value <- decode.field("value", decode.string)
      decode.success(ExactBody(value))
    }
    "contains" -> {
      use value <- decode.field("value", decode.string)
      decode.success(ContainsBody(value))
    }
    "json" -> {
      use value <- decode.field("value", decode.string)
      decode.success(JsonBody(value))
    }
    _ -> decode.failure(AnyBody, "BodyMatcher type")
  }
}

fn response_def_decoder() -> decode.Decoder(ResponseDefinition) {
  use status <- decode.field("status", decode.int)
  use headers <- decode.field("headers", decode.list(key_value_decoder()))
  use body <- decode.field("body", response_body_decoder())
  use delay_ms <- decode.field("delay_ms", decode.optional(decode.int))
  decode.success(ResponseDefinition(
    status: status,
    headers: headers,
    body: body,
    delay_ms: delay_ms,
  ))
}

fn key_value_decoder() -> decode.Decoder(#(String, String)) {
  use key <- decode.field("key", decode.string)
  use value <- decode.field("value", decode.string)
  decode.success(#(key, value))
}

fn response_body_decoder() -> decode.Decoder(ResponseBody) {
  use type_value <- decode.field("type", decode.string)
  case type_value {
    "none" -> decode.success(NoBody)
    "string" -> {
      use value <- decode.field("value", decode.string)
      decode.success(StringBody(value))
    }
    "json" -> {
      use value <- decode.field("value", decode.string)
      decode.success(RawJsonBody(value))
    }
    _ -> decode.success(NoBody)
  }
}

fn scenario_decoder() -> decode.Decoder(ScenarioState) {
  use name <- decode.field("name", decode.string)
  use required_state <- decode.field(
    "required_state",
    decode.optional(decode.string),
  )
  use new_state <- decode.field("new_state", decode.optional(decode.string))
  decode.success(ScenarioState(
    name: name,
    required_state: required_state,
    new_state: new_state,
  ))
}

pub fn decode_recorded_requests(
  json_string: String,
) -> Result(List(RecordedRequest), String) {
  json.parse(
    from: json_string,
    using: decode.list(recorded_request_decoder()),
  )
  |> map_decode_error
}

fn recorded_request_decoder() -> decode.Decoder(RecordedRequest) {
  use id <- decode.field("id", decode.string)
  use method_string <- decode.field("method", decode.string)
  use path <- decode.field("path", decode.string)
  use query <- decode.field("query", decode.optional(decode.string))
  use headers <- decode.field(
    "headers",
    decode.dict(decode.string, decode.string),
  )
  use body <- decode.field("body", decode.string)
  use timestamp_ms <- decode.field("timestamp_ms", decode.int)
  use matched_stub_id <- decode.field(
    "matched_stub_id",
    decode.optional(decode.string),
  )
  let method = case http.parse_method(method_string) {
    Ok(method) -> method
    Error(Nil) -> http.Get
  }
  decode.success(RecordedRequest(
    id: id,
    method: method,
    path: path,
    query: query,
    headers: headers,
    body: body,
    timestamp_ms: timestamp_ms,
    matched_stub_id: matched_stub_id,
  ))
}

fn map_decode_error(
  result: Result(decoded, json.DecodeError),
) -> Result(decoded, String) {
  case result {
    Ok(value) -> Ok(value)
    Error(json.UnexpectedEndOfInput) -> Error("Unexpected end of input")
    Error(json.UnexpectedByte(byte)) -> Error("Unexpected byte: " <> byte)
    Error(json.UnexpectedSequence(sequence)) ->
      Error("Unexpected sequence: " <> sequence)
    Error(json.UnableToDecode(decode_errors)) ->
      Error(
        "Decode error: "
        <> list.map(decode_errors, fn(decode_error) {
            "expected "
            <> decode_error.expected
            <> " at "
            <> int.to_string(list.length(decode_error.path))
          })
        |> string.join(", "),
      )
  }
}
