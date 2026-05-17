import * as $http from "../../../gleam_http/gleam/http.mjs";
import * as $json from "../../../gleam_json/gleam/json.mjs";
import * as $dict from "../../../gleam_stdlib/gleam/dict.mjs";
import * as $decode from "../../../gleam_stdlib/gleam/dynamic/decode.mjs";
import * as $int from "../../../gleam_stdlib/gleam/int.mjs";
import * as $list from "../../../gleam_stdlib/gleam/list.mjs";
import * as $option from "../../../gleam_stdlib/gleam/option.mjs";
import { None, Some } from "../../../gleam_stdlib/gleam/option.mjs";
import * as $string from "../../../gleam_stdlib/gleam/string.mjs";
import { Ok, Error, toList } from "../../gleam.mjs";
import * as $types from "../../http_server_mock/types.mjs";
import {
  AnyBody,
  AnyString,
  BytesBody,
  Contains,
  ContainsBody,
  Exact,
  ExactBody,
  JsonBody,
  NoBody,
  Prefix,
  RawJsonBody,
  RecordedRequest,
  RequestMatcher,
  ResponseDefinition,
  ScenarioState,
  StringBody,
  Stub,
  Suffix,
} from "../../http_server_mock/types.mjs";

function encode_scenario_json(scenario_state) {
  return $json.object(
    toList([
      ["name", $json.string(scenario_state.name)],
      [
        "required_state",
        (() => {
          let $ = scenario_state.required_state;
          if ($ instanceof Some) {
            let state = $[0];
            return $json.string(state);
          } else {
            return $json.null$();
          }
        })(),
      ],
      [
        "new_state",
        (() => {
          let $ = scenario_state.new_state;
          if ($ instanceof Some) {
            let state = $[0];
            return $json.string(state);
          } else {
            return $json.null$();
          }
        })(),
      ],
    ]),
  );
}

function encode_response_body_json(body) {
  if (body instanceof StringBody) {
    let text = body[0];
    return $json.object(
      toList([["type", $json.string("string")], ["value", $json.string(text)]]),
    );
  } else if (body instanceof RawJsonBody) {
    let json_text = body[0];
    return $json.object(
      toList([
        ["type", $json.string("json")],
        ["value", $json.string(json_text)],
      ]),
    );
  } else if (body instanceof BytesBody) {
    return $json.object(toList([["type", $json.string("none")]]));
  } else {
    return $json.object(toList([["type", $json.string("none")]]));
  }
}

function encode_response_def_json(response_def) {
  return $json.object(
    toList([
      ["status", $json.int(response_def.status)],
      [
        "headers",
        $json.array(
          response_def.headers,
          (header_pair) => {
            let key;
            let value;
            key = header_pair[0];
            value = header_pair[1];
            return $json.object(
              toList([
                ["key", $json.string(key)],
                ["value", $json.string(value)],
              ]),
            );
          },
        ),
      ],
      ["body", encode_response_body_json(response_def.body)],
      [
        "delay_ms",
        (() => {
          let $ = response_def.delay_ms;
          if ($ instanceof Some) {
            let milliseconds = $[0];
            return $json.int(milliseconds);
          } else {
            return $json.null$();
          }
        })(),
      ],
    ]),
  );
}

function encode_body_matcher_json(body_matcher) {
  if (body_matcher instanceof AnyBody) {
    return $json.object(toList([["type", $json.string("any")]]));
  } else if (body_matcher instanceof ExactBody) {
    let value = body_matcher[0];
    return $json.object(
      toList([["type", $json.string("exact")], ["value", $json.string(value)]]),
    );
  } else if (body_matcher instanceof ContainsBody) {
    let value = body_matcher[0];
    return $json.object(
      toList([
        ["type", $json.string("contains")],
        ["value", $json.string(value)],
      ]),
    );
  } else {
    let value = body_matcher[0];
    return $json.object(
      toList([["type", $json.string("json")], ["value", $json.string(value)]]),
    );
  }
}

function encode_string_matcher_json(string_matcher) {
  if (string_matcher instanceof Exact) {
    let value = string_matcher[0];
    return $json.object(
      toList([["type", $json.string("exact")], ["value", $json.string(value)]]),
    );
  } else if (string_matcher instanceof Contains) {
    let value = string_matcher[0];
    return $json.object(
      toList([
        ["type", $json.string("contains")],
        ["value", $json.string(value)],
      ]),
    );
  } else if (string_matcher instanceof Prefix) {
    let value = string_matcher[0];
    return $json.object(
      toList([["type", $json.string("prefix")], ["value", $json.string(value)]]),
    );
  } else if (string_matcher instanceof Suffix) {
    let value = string_matcher[0];
    return $json.object(
      toList([["type", $json.string("suffix")], ["value", $json.string(value)]]),
    );
  } else {
    return $json.object(toList([["type", $json.string("any")]]));
  }
}

function encode_matcher_json(request_matcher) {
  return $json.object(
    toList([
      [
        "method",
        (() => {
          let $ = request_matcher.method;
          if ($ instanceof Some) {
            let method = $[0];
            return $json.string($http.method_to_string(method));
          } else {
            return $json.null$();
          }
        })(),
      ],
      [
        "path",
        (() => {
          let $ = request_matcher.path;
          if ($ instanceof Some) {
            let string_matcher = $[0];
            return encode_string_matcher_json(string_matcher);
          } else {
            return $json.null$();
          }
        })(),
      ],
      [
        "query_params",
        $json.array(
          request_matcher.query_params,
          (query_param_pair) => {
            let key;
            let string_matcher;
            key = query_param_pair[0];
            string_matcher = query_param_pair[1];
            return $json.object(
              toList([
                ["key", $json.string(key)],
                ["matcher", encode_string_matcher_json(string_matcher)],
              ]),
            );
          },
        ),
      ],
      [
        "headers",
        $json.array(
          request_matcher.headers,
          (header_pair) => {
            let key;
            let string_matcher;
            key = header_pair[0];
            string_matcher = header_pair[1];
            return $json.object(
              toList([
                ["key", $json.string(key)],
                ["matcher", encode_string_matcher_json(string_matcher)],
              ]),
            );
          },
        ),
      ],
      ["body", encode_body_matcher_json(request_matcher.body)],
    ]),
  );
}

function encode_stub_json(stub) {
  return $json.object(
    toList([
      ["id", $json.string(stub.id)],
      ["priority", $json.int(stub.priority)],
      ["request", encode_matcher_json(stub.matcher)],
      ["response", encode_response_def_json(stub.response)],
      [
        "scenario",
        (() => {
          let $ = stub.scenario;
          if ($ instanceof Some) {
            let scenario_state = $[0];
            return encode_scenario_json(scenario_state);
          } else {
            return $json.null$();
          }
        })(),
      ],
    ]),
  );
}

export function encode_stub(stub) {
  let _pipe = encode_stub_json(stub);
  return $json.to_string(_pipe);
}

export function encode_stubs(stubs) {
  let _pipe = $json.array(stubs, encode_stub_json);
  return $json.to_string(_pipe);
}

function encode_recorded_request_json(recorded_request) {
  return $json.object(
    toList([
      ["id", $json.string(recorded_request.id)],
      ["method", $json.string($http.method_to_string(recorded_request.method))],
      ["path", $json.string(recorded_request.path)],
      [
        "query",
        (() => {
          let $ = recorded_request.query;
          if ($ instanceof Some) {
            let query_string = $[0];
            return $json.string(query_string);
          } else {
            return $json.null$();
          }
        })(),
      ],
      [
        "headers",
        $json.object(
          (() => {
            let _pipe = $dict.to_list(recorded_request.headers);
            return $list.map(
              _pipe,
              (header_pair) => {
                let key;
                let value;
                key = header_pair[0];
                value = header_pair[1];
                return [key, $json.string(value)];
              },
            );
          })(),
        ),
      ],
      ["body", $json.string(recorded_request.body)],
      ["timestamp_ms", $json.int(recorded_request.timestamp_ms)],
      [
        "matched_stub_id",
        (() => {
          let $ = recorded_request.matched_stub_id;
          if ($ instanceof Some) {
            let stub_id = $[0];
            return $json.string(stub_id);
          } else {
            return $json.null$();
          }
        })(),
      ],
    ]),
  );
}

export function encode_recorded_request(recorded_request) {
  let _pipe = encode_recorded_request_json(recorded_request);
  return $json.to_string(_pipe);
}

export function encode_recorded_requests(recorded_requests) {
  let _pipe = $json.array(recorded_requests, encode_recorded_request_json);
  return $json.to_string(_pipe);
}

function map_decode_error(result) {
  if (result instanceof Ok) {
    return result;
  } else {
    let $ = result[0];
    if ($ instanceof $json.UnexpectedEndOfInput) {
      return new Error("Unexpected end of input");
    } else if ($ instanceof $json.UnexpectedByte) {
      let byte = $[0];
      return new Error("Unexpected byte: " + byte);
    } else if ($ instanceof $json.UnexpectedSequence) {
      let sequence = $[0];
      return new Error("Unexpected sequence: " + sequence);
    } else {
      let decode_errors = $[0];
      return new Error(
        "Decode error: " + (() => {
          let _pipe = $list.map(
            decode_errors,
            (decode_error) => {
              return (("expected " + decode_error.expected) + " at ") + $int.to_string(
                $list.length(decode_error.path),
              );
            },
          );
          return $string.join(_pipe, ", ");
        })(),
      );
    }
  }
}

function scenario_decoder() {
  return $decode.field(
    "name",
    $decode.string,
    (name) => {
      return $decode.field(
        "required_state",
        $decode.optional($decode.string),
        (required_state) => {
          return $decode.field(
            "new_state",
            $decode.optional($decode.string),
            (new_state) => {
              return $decode.success(
                new ScenarioState(name, required_state, new_state),
              );
            },
          );
        },
      );
    },
  );
}

function response_body_decoder() {
  return $decode.field(
    "type",
    $decode.string,
    (type_value) => {
      if (type_value === "none") {
        return $decode.success(new NoBody());
      } else if (type_value === "string") {
        return $decode.field(
          "value",
          $decode.string,
          (value) => { return $decode.success(new StringBody(value)); },
        );
      } else if (type_value === "json") {
        return $decode.field(
          "value",
          $decode.string,
          (value) => { return $decode.success(new RawJsonBody(value)); },
        );
      } else {
        return $decode.success(new NoBody());
      }
    },
  );
}

function key_value_decoder() {
  return $decode.field(
    "key",
    $decode.string,
    (key) => {
      return $decode.field(
        "value",
        $decode.string,
        (value) => { return $decode.success([key, value]); },
      );
    },
  );
}

function response_def_decoder() {
  return $decode.field(
    "status",
    $decode.int,
    (status) => {
      return $decode.field(
        "headers",
        $decode.list(key_value_decoder()),
        (headers) => {
          return $decode.field(
            "body",
            response_body_decoder(),
            (body) => {
              return $decode.field(
                "delay_ms",
                $decode.optional($decode.int),
                (delay_ms) => {
                  return $decode.success(
                    new ResponseDefinition(status, headers, body, delay_ms),
                  );
                },
              );
            },
          );
        },
      );
    },
  );
}

function body_matcher_decoder() {
  return $decode.field(
    "type",
    $decode.string,
    (type_value) => {
      if (type_value === "any") {
        return $decode.success(new AnyBody());
      } else if (type_value === "exact") {
        return $decode.field(
          "value",
          $decode.string,
          (value) => { return $decode.success(new ExactBody(value)); },
        );
      } else if (type_value === "contains") {
        return $decode.field(
          "value",
          $decode.string,
          (value) => { return $decode.success(new ContainsBody(value)); },
        );
      } else if (type_value === "json") {
        return $decode.field(
          "value",
          $decode.string,
          (value) => { return $decode.success(new JsonBody(value)); },
        );
      } else {
        return $decode.failure(new AnyBody(), "BodyMatcher type");
      }
    },
  );
}

function string_matcher_decoder() {
  return $decode.field(
    "type",
    $decode.string,
    (type_value) => {
      if (type_value === "any") {
        return $decode.success(new AnyString());
      } else if (type_value === "exact") {
        return $decode.field(
          "value",
          $decode.string,
          (value) => { return $decode.success(new Exact(value)); },
        );
      } else if (type_value === "contains") {
        return $decode.field(
          "value",
          $decode.string,
          (value) => { return $decode.success(new Contains(value)); },
        );
      } else if (type_value === "prefix") {
        return $decode.field(
          "value",
          $decode.string,
          (value) => { return $decode.success(new Prefix(value)); },
        );
      } else if (type_value === "suffix") {
        return $decode.field(
          "value",
          $decode.string,
          (value) => { return $decode.success(new Suffix(value)); },
        );
      } else {
        return $decode.failure(new AnyString(), "StringMatcher type");
      }
    },
  );
}

function key_matcher_decoder() {
  return $decode.field(
    "key",
    $decode.string,
    (key) => {
      return $decode.field(
        "matcher",
        string_matcher_decoder(),
        (string_matcher) => { return $decode.success([key, string_matcher]); },
      );
    },
  );
}

function request_matcher_decoder() {
  return $decode.field(
    "method",
    $decode.optional($decode.string),
    (method_string) => {
      return $decode.field(
        "path",
        $decode.optional(string_matcher_decoder()),
        (path_matcher) => {
          return $decode.field(
            "query_params",
            $decode.list(key_matcher_decoder()),
            (query_params) => {
              return $decode.field(
                "headers",
                $decode.list(key_matcher_decoder()),
                (headers) => {
                  return $decode.field(
                    "body",
                    body_matcher_decoder(),
                    (body_matcher) => {
                      return $decode.success(
                        new RequestMatcher(
                          (() => {
                            if (method_string instanceof Some) {
                              let method_str = method_string[0];
                              let $ = $http.parse_method(method_str);
                              if ($ instanceof Ok) {
                                let method = $[0];
                                return new Some(method);
                              } else {
                                return new None();
                              }
                            } else {
                              return method_string;
                            }
                          })(),
                          path_matcher,
                          query_params,
                          headers,
                          body_matcher,
                        ),
                      );
                    },
                  );
                },
              );
            },
          );
        },
      );
    },
  );
}

function stub_decoder() {
  return $decode.field(
    "id",
    $decode.string,
    (id) => {
      return $decode.field(
        "priority",
        $decode.int,
        (priority) => {
          return $decode.field(
            "request",
            request_matcher_decoder(),
            (request_matcher) => {
              return $decode.field(
                "response",
                response_def_decoder(),
                (response_def) => {
                  return $decode.field(
                    "scenario",
                    $decode.optional(scenario_decoder()),
                    (scenario_state) => {
                      return $decode.success(
                        new Stub(
                          id,
                          priority,
                          request_matcher,
                          response_def,
                          scenario_state,
                        ),
                      );
                    },
                  );
                },
              );
            },
          );
        },
      );
    },
  );
}

export function decode_stub(json_string) {
  let _pipe = $json.parse(json_string, stub_decoder());
  return map_decode_error(_pipe);
}

export function decode_stubs(json_string) {
  let _pipe = $json.parse(json_string, $decode.list(stub_decoder()));
  return map_decode_error(_pipe);
}

function recorded_request_decoder() {
  return $decode.field(
    "id",
    $decode.string,
    (id) => {
      return $decode.field(
        "method",
        $decode.string,
        (method_string) => {
          return $decode.field(
            "path",
            $decode.string,
            (path) => {
              return $decode.field(
                "query",
                $decode.optional($decode.string),
                (query) => {
                  return $decode.field(
                    "headers",
                    $decode.dict($decode.string, $decode.string),
                    (headers) => {
                      return $decode.field(
                        "body",
                        $decode.string,
                        (body) => {
                          return $decode.field(
                            "timestamp_ms",
                            $decode.int,
                            (timestamp_ms) => {
                              return $decode.field(
                                "matched_stub_id",
                                $decode.optional($decode.string),
                                (matched_stub_id) => {
                                  let _block;
                                  let $ = $http.parse_method(method_string);
                                  if ($ instanceof Ok) {
                                    let method = $[0];
                                    _block = method;
                                  } else {
                                    _block = new $http.Get();
                                  }
                                  let method = _block;
                                  return $decode.success(
                                    new RecordedRequest(
                                      id,
                                      method,
                                      path,
                                      query,
                                      headers,
                                      body,
                                      timestamp_ms,
                                      matched_stub_id,
                                    ),
                                  );
                                },
                              );
                            },
                          );
                        },
                      );
                    },
                  );
                },
              );
            },
          );
        },
      );
    },
  );
}

export function decode_recorded_requests(json_string) {
  let _pipe = $json.parse(json_string, $decode.list(recorded_request_decoder()));
  return map_decode_error(_pipe);
}
