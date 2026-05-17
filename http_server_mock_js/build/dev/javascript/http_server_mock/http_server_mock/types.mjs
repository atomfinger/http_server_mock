import * as $http from "../../gleam_http/gleam/http.mjs";
import * as $dict from "../../gleam_stdlib/gleam/dict.mjs";
import * as $option from "../../gleam_stdlib/gleam/option.mjs";
import { CustomType as $CustomType } from "../gleam.mjs";

/**
 * The field must be exactly equal to the given string.
 */
export class Exact extends $CustomType {
  constructor($0) {
    super();
    this[0] = $0;
  }
}
export const StringMatcher$Exact = ($0) => new Exact($0);
export const StringMatcher$isExact = (value) => value instanceof Exact;
export const StringMatcher$Exact$0 = (value) => value[0];

/**
 * The field must contain the given string as a substring.
 */
export class Contains extends $CustomType {
  constructor($0) {
    super();
    this[0] = $0;
  }
}
export const StringMatcher$Contains = ($0) => new Contains($0);
export const StringMatcher$isContains = (value) => value instanceof Contains;
export const StringMatcher$Contains$0 = (value) => value[0];

/**
 * The field must start with the given string.
 */
export class Prefix extends $CustomType {
  constructor($0) {
    super();
    this[0] = $0;
  }
}
export const StringMatcher$Prefix = ($0) => new Prefix($0);
export const StringMatcher$isPrefix = (value) => value instanceof Prefix;
export const StringMatcher$Prefix$0 = (value) => value[0];

/**
 * The field must end with the given string.
 */
export class Suffix extends $CustomType {
  constructor($0) {
    super();
    this[0] = $0;
  }
}
export const StringMatcher$Suffix = ($0) => new Suffix($0);
export const StringMatcher$isSuffix = (value) => value instanceof Suffix;
export const StringMatcher$Suffix$0 = (value) => value[0];

/**
 * Any value is accepted (the field is not checked).
 */
export class AnyString extends $CustomType {}
export const StringMatcher$AnyString = () => new AnyString();
export const StringMatcher$isAnyString = (value) => value instanceof AnyString;

/**
 * Any body is accepted (including an empty body).
 */
export class AnyBody extends $CustomType {}
export const BodyMatcher$AnyBody = () => new AnyBody();
export const BodyMatcher$isAnyBody = (value) => value instanceof AnyBody;

/**
 * The body must be exactly equal to the given string.
 */
export class ExactBody extends $CustomType {
  constructor($0) {
    super();
    this[0] = $0;
  }
}
export const BodyMatcher$ExactBody = ($0) => new ExactBody($0);
export const BodyMatcher$isExactBody = (value) => value instanceof ExactBody;
export const BodyMatcher$ExactBody$0 = (value) => value[0];

/**
 * The body must contain the given string as a substring.
 */
export class ContainsBody extends $CustomType {
  constructor($0) {
    super();
    this[0] = $0;
  }
}
export const BodyMatcher$ContainsBody = ($0) => new ContainsBody($0);
export const BodyMatcher$isContainsBody = (value) =>
  value instanceof ContainsBody;
export const BodyMatcher$ContainsBody$0 = (value) => value[0];

/**
 * The body must be semantically equal to the given JSON string (whitespace
 * and key order are ignored).
 */
export class JsonBody extends $CustomType {
  constructor($0) {
    super();
    this[0] = $0;
  }
}
export const BodyMatcher$JsonBody = ($0) => new JsonBody($0);
export const BodyMatcher$isJsonBody = (value) => value instanceof JsonBody;
export const BodyMatcher$JsonBody$0 = (value) => value[0];

export class RequestMatcher extends $CustomType {
  constructor(method, path, query_params, headers, body) {
    super();
    this.method = method;
    this.path = path;
    this.query_params = query_params;
    this.headers = headers;
    this.body = body;
  }
}
export const RequestMatcher$RequestMatcher = (method, path, query_params, headers, body) =>
  new RequestMatcher(method, path, query_params, headers, body);
export const RequestMatcher$isRequestMatcher = (value) =>
  value instanceof RequestMatcher;
export const RequestMatcher$RequestMatcher$method = (value) => value.method;
export const RequestMatcher$RequestMatcher$0 = (value) => value.method;
export const RequestMatcher$RequestMatcher$path = (value) => value.path;
export const RequestMatcher$RequestMatcher$1 = (value) => value.path;
export const RequestMatcher$RequestMatcher$query_params = (value) =>
  value.query_params;
export const RequestMatcher$RequestMatcher$2 = (value) => value.query_params;
export const RequestMatcher$RequestMatcher$headers = (value) => value.headers;
export const RequestMatcher$RequestMatcher$3 = (value) => value.headers;
export const RequestMatcher$RequestMatcher$body = (value) => value.body;
export const RequestMatcher$RequestMatcher$4 = (value) => value.body;

/**
 * A plain text string body.
 */
export class StringBody extends $CustomType {
  constructor($0) {
    super();
    this[0] = $0;
  }
}
export const ResponseBody$StringBody = ($0) => new StringBody($0);
export const ResponseBody$isStringBody = (value) => value instanceof StringBody;
export const ResponseBody$StringBody$0 = (value) => value[0];

/**
 * A raw JSON string body (sent as-is, without re-serialisation).
 */
export class RawJsonBody extends $CustomType {
  constructor($0) {
    super();
    this[0] = $0;
  }
}
export const ResponseBody$RawJsonBody = ($0) => new RawJsonBody($0);
export const ResponseBody$isRawJsonBody = (value) =>
  value instanceof RawJsonBody;
export const ResponseBody$RawJsonBody$0 = (value) => value[0];

/**
 * A binary body.
 */
export class BytesBody extends $CustomType {
  constructor($0) {
    super();
    this[0] = $0;
  }
}
export const ResponseBody$BytesBody = ($0) => new BytesBody($0);
export const ResponseBody$isBytesBody = (value) => value instanceof BytesBody;
export const ResponseBody$BytesBody$0 = (value) => value[0];

/**
 * No body — the response has an empty body.
 */
export class NoBody extends $CustomType {}
export const ResponseBody$NoBody = () => new NoBody();
export const ResponseBody$isNoBody = (value) => value instanceof NoBody;

export class ResponseDefinition extends $CustomType {
  constructor(status, headers, body, delay_ms) {
    super();
    this.status = status;
    this.headers = headers;
    this.body = body;
    this.delay_ms = delay_ms;
  }
}
export const ResponseDefinition$ResponseDefinition = (status, headers, body, delay_ms) =>
  new ResponseDefinition(status, headers, body, delay_ms);
export const ResponseDefinition$isResponseDefinition = (value) =>
  value instanceof ResponseDefinition;
export const ResponseDefinition$ResponseDefinition$status = (value) =>
  value.status;
export const ResponseDefinition$ResponseDefinition$0 = (value) => value.status;
export const ResponseDefinition$ResponseDefinition$headers = (value) =>
  value.headers;
export const ResponseDefinition$ResponseDefinition$1 = (value) => value.headers;
export const ResponseDefinition$ResponseDefinition$body = (value) => value.body;
export const ResponseDefinition$ResponseDefinition$2 = (value) => value.body;
export const ResponseDefinition$ResponseDefinition$delay_ms = (value) =>
  value.delay_ms;
export const ResponseDefinition$ResponseDefinition$3 = (value) =>
  value.delay_ms;

export class ScenarioState extends $CustomType {
  constructor(name, required_state, new_state) {
    super();
    this.name = name;
    this.required_state = required_state;
    this.new_state = new_state;
  }
}
export const ScenarioState$ScenarioState = (name, required_state, new_state) =>
  new ScenarioState(name, required_state, new_state);
export const ScenarioState$isScenarioState = (value) =>
  value instanceof ScenarioState;
export const ScenarioState$ScenarioState$name = (value) => value.name;
export const ScenarioState$ScenarioState$0 = (value) => value.name;
export const ScenarioState$ScenarioState$required_state = (value) =>
  value.required_state;
export const ScenarioState$ScenarioState$1 = (value) => value.required_state;
export const ScenarioState$ScenarioState$new_state = (value) => value.new_state;
export const ScenarioState$ScenarioState$2 = (value) => value.new_state;

export class Stub extends $CustomType {
  constructor(id, priority, matcher, response, scenario) {
    super();
    this.id = id;
    this.priority = priority;
    this.matcher = matcher;
    this.response = response;
    this.scenario = scenario;
  }
}
export const Stub$Stub = (id, priority, matcher, response, scenario) =>
  new Stub(id, priority, matcher, response, scenario);
export const Stub$isStub = (value) => value instanceof Stub;
export const Stub$Stub$id = (value) => value.id;
export const Stub$Stub$0 = (value) => value.id;
export const Stub$Stub$priority = (value) => value.priority;
export const Stub$Stub$1 = (value) => value.priority;
export const Stub$Stub$matcher = (value) => value.matcher;
export const Stub$Stub$2 = (value) => value.matcher;
export const Stub$Stub$response = (value) => value.response;
export const Stub$Stub$3 = (value) => value.response;
export const Stub$Stub$scenario = (value) => value.scenario;
export const Stub$Stub$4 = (value) => value.scenario;

export class RecordedRequest extends $CustomType {
  constructor(id, method, path, query, headers, body, timestamp_ms, matched_stub_id) {
    super();
    this.id = id;
    this.method = method;
    this.path = path;
    this.query = query;
    this.headers = headers;
    this.body = body;
    this.timestamp_ms = timestamp_ms;
    this.matched_stub_id = matched_stub_id;
  }
}
export const RecordedRequest$RecordedRequest = (id, method, path, query, headers, body, timestamp_ms, matched_stub_id) =>
  new RecordedRequest(id,
  method,
  path,
  query,
  headers,
  body,
  timestamp_ms,
  matched_stub_id);
export const RecordedRequest$isRecordedRequest = (value) =>
  value instanceof RecordedRequest;
export const RecordedRequest$RecordedRequest$id = (value) => value.id;
export const RecordedRequest$RecordedRequest$0 = (value) => value.id;
export const RecordedRequest$RecordedRequest$method = (value) => value.method;
export const RecordedRequest$RecordedRequest$1 = (value) => value.method;
export const RecordedRequest$RecordedRequest$path = (value) => value.path;
export const RecordedRequest$RecordedRequest$2 = (value) => value.path;
export const RecordedRequest$RecordedRequest$query = (value) => value.query;
export const RecordedRequest$RecordedRequest$3 = (value) => value.query;
export const RecordedRequest$RecordedRequest$headers = (value) => value.headers;
export const RecordedRequest$RecordedRequest$4 = (value) => value.headers;
export const RecordedRequest$RecordedRequest$body = (value) => value.body;
export const RecordedRequest$RecordedRequest$5 = (value) => value.body;
export const RecordedRequest$RecordedRequest$timestamp_ms = (value) =>
  value.timestamp_ms;
export const RecordedRequest$RecordedRequest$6 = (value) => value.timestamp_ms;
export const RecordedRequest$RecordedRequest$matched_stub_id = (value) =>
  value.matched_stub_id;
export const RecordedRequest$RecordedRequest$7 = (value) =>
  value.matched_stub_id;
