import * as $http from "../../gleam_http/gleam/http.mjs";
import * as $dict from "../../gleam_stdlib/gleam/dict.mjs";
import * as $list from "../../gleam_stdlib/gleam/list.mjs";
import * as $option from "../../gleam_stdlib/gleam/option.mjs";
import { None, Some } from "../../gleam_stdlib/gleam/option.mjs";
import * as $string from "../../gleam_stdlib/gleam/string.mjs";
import { Ok, toList, Empty as $Empty, prepend as listPrepend, isEqual } from "../gleam.mjs";
import * as $types from "../http_server_mock/types.mjs";
import {
  AnyBody,
  AnyString,
  Contains,
  ContainsBody,
  Exact,
  ExactBody,
  JsonBody,
  Prefix,
  RequestMatcher,
  Suffix,
} from "../http_server_mock/types.mjs";

/**
 * Returns a new `RequestMatcher` with no constraints — matches every request.
 */
export function new$() {
  return new RequestMatcher(
    new None(),
    new None(),
    toList([]),
    toList([]),
    new AnyBody(),
  );
}

/**
 * Constrains the matcher to only match requests with the given HTTP method.
 */
export function method(request_matcher, method) {
  return new RequestMatcher(
    new Some(method),
    request_matcher.path,
    request_matcher.query_params,
    request_matcher.headers,
    request_matcher.body,
  );
}

/**
 * Constrains the matcher to only match requests whose path is exactly equal
 * to `path`.
 *
 * Use `path_matching` or `path_contains` for partial matches.
 */
export function path(request_matcher, path) {
  return new RequestMatcher(
    request_matcher.method,
    new Some(new Exact(path)),
    request_matcher.query_params,
    request_matcher.headers,
    request_matcher.body,
  );
}

/**
 * Constrains the matcher to only match requests whose path satisfies the
 * given `StringMatcher`.
 *
 * Use this when you need `Contains`, `Prefix`, or `Suffix` path matching
 * instead of an exact match.
 */
export function path_matching(request_matcher, string_matcher) {
  return new RequestMatcher(
    request_matcher.method,
    new Some(string_matcher),
    request_matcher.query_params,
    request_matcher.headers,
    request_matcher.body,
  );
}

/**
 * Constrains the matcher to only match requests whose path contains
 * `fragment` as a substring.
 */
export function path_contains(request_matcher, fragment) {
  return new RequestMatcher(
    request_matcher.method,
    new Some(new Contains(fragment)),
    request_matcher.query_params,
    request_matcher.headers,
    request_matcher.body,
  );
}

/**
 * Constrains the matcher to only match requests that have the query parameter
 * `key` set to exactly `value`.
 *
 * Can be called multiple times to require several query parameters.
 */
export function query_param(request_matcher, key, value) {
  return new RequestMatcher(
    request_matcher.method,
    request_matcher.path,
    listPrepend([key, new Exact(value)], request_matcher.query_params),
    request_matcher.headers,
    request_matcher.body,
  );
}

/**
 * Constrains the matcher to only match requests that have the query parameter
 * `key` satisfying the given `StringMatcher`.
 *
 * Can be called multiple times to require several query parameters.
 */
export function query_param_matching(request_matcher, key, string_matcher) {
  return new RequestMatcher(
    request_matcher.method,
    request_matcher.path,
    listPrepend([key, string_matcher], request_matcher.query_params),
    request_matcher.headers,
    request_matcher.body,
  );
}

/**
 * Constrains the matcher to only match requests that have the header `key`
 * set to exactly `value`. Header names are compared case-insensitively.
 *
 * Can be called multiple times to require several headers.
 */
export function header(request_matcher, key, value) {
  return new RequestMatcher(
    request_matcher.method,
    request_matcher.path,
    request_matcher.query_params,
    listPrepend(
      [$string.lowercase(key), new Exact(value)],
      request_matcher.headers,
    ),
    request_matcher.body,
  );
}

/**
 * Constrains the matcher to only match requests that have the header `key`
 * satisfying the given `StringMatcher`. Header names are compared
 * case-insensitively.
 *
 * Can be called multiple times to require several headers.
 */
export function header_matching(request_matcher, key, string_matcher) {
  return new RequestMatcher(
    request_matcher.method,
    request_matcher.path,
    request_matcher.query_params,
    listPrepend(
      [$string.lowercase(key), string_matcher],
      request_matcher.headers,
    ),
    request_matcher.body,
  );
}

/**
 * Constrains the matcher to only match requests whose body is exactly equal
 * to `body`.
 */
export function body_equal_to(request_matcher, body) {
  return new RequestMatcher(
    request_matcher.method,
    request_matcher.path,
    request_matcher.query_params,
    request_matcher.headers,
    new ExactBody(body),
  );
}

/**
 * Constrains the matcher to only match requests whose body contains
 * `fragment` as a substring.
 */
export function body_containing(request_matcher, fragment) {
  return new RequestMatcher(
    request_matcher.method,
    request_matcher.path,
    request_matcher.query_params,
    request_matcher.headers,
    new ContainsBody(fragment),
  );
}

/**
 * Constrains the matcher to only match requests whose body is semantically
 * equal to `json` when both are parsed as JSON (whitespace and key order are
 * ignored).
 */
export function body_json(request_matcher, json) {
  return new RequestMatcher(
    request_matcher.method,
    request_matcher.path,
    request_matcher.query_params,
    request_matcher.headers,
    new JsonBody(json),
  );
}

/**
 * Constrains the matcher using a custom `BodyMatcher`.
 *
 * Use this when none of the convenience functions (`body_equal_to`,
 * `body_containing`, `body_json`) cover your use case.
 */
export function body_matcher(request_matcher, body_matcher) {
  return new RequestMatcher(
    request_matcher.method,
    request_matcher.path,
    request_matcher.query_params,
    request_matcher.headers,
    body_matcher,
  );
}

function normalize_json(json_string) {
  let _pipe = json_string;
  let _pipe$1 = $string.replace(_pipe, " ", "");
  let _pipe$2 = $string.replace(_pipe$1, "\n", "");
  let _pipe$3 = $string.replace(_pipe$2, "\t", "");
  return $string.replace(_pipe$3, "\r", "");
}

function body_matches(expected, actual) {
  if (expected instanceof AnyBody) {
    return true;
  } else if (expected instanceof ExactBody) {
    let body = expected[0];
    return actual === body;
  } else if (expected instanceof ContainsBody) {
    let fragment = expected[0];
    return $string.contains(actual, fragment);
  } else {
    let expected_json = expected[0];
    return normalize_json(actual) === normalize_json(expected_json);
  }
}

/**
 * Applies a `StringMatcher` to `value`, returning `True` if it matches.
 *
 * Exposed for use in custom filtering logic over `recorded_requests`.
 */
export function apply_string_matcher(string_matcher, value) {
  if (string_matcher instanceof Exact) {
    let expected = string_matcher[0];
    return value === expected;
  } else if (string_matcher instanceof Contains) {
    let fragment = string_matcher[0];
    return $string.contains(value, fragment);
  } else if (string_matcher instanceof Prefix) {
    let prefix = string_matcher[0];
    return $string.starts_with(value, prefix);
  } else if (string_matcher instanceof Suffix) {
    let suffix = string_matcher[0];
    return $string.ends_with(value, suffix);
  } else {
    return true;
  }
}

function headers_match(expected, actual) {
  return $list.all(
    expected,
    (header_pair) => {
      let key;
      let string_matcher;
      key = header_pair[0];
      string_matcher = header_pair[1];
      let $ = $dict.get(actual, $string.lowercase(key));
      if ($ instanceof Ok) {
        let value = $[0];
        return apply_string_matcher(string_matcher, value);
      } else {
        return string_matcher instanceof AnyString;
      }
    },
  );
}

function parse_query(query_string) {
  if (query_string instanceof Some) {
    let query = query_string[0];
    let _pipe = query;
    let _pipe$1 = $string.split(_pipe, "&");
    return $list.filter_map(
      _pipe$1,
      (part) => {
        let $ = $string.split_once(part, "=");
        if ($ instanceof Ok) {
          return $;
        } else {
          return new Ok([part, ""]);
        }
      },
    );
  } else {
    return toList([]);
  }
}

function query_params_match(expected, query_string) {
  if (expected instanceof $Empty) {
    return true;
  } else {
    let params = parse_query(query_string);
    return $list.all(
      expected,
      (query_param_pair) => {
        let key;
        let string_matcher;
        key = query_param_pair[0];
        string_matcher = query_param_pair[1];
        let $ = $list.key_find(params, key);
        if ($ instanceof Ok) {
          let value = $[0];
          return apply_string_matcher(string_matcher, value);
        } else {
          return string_matcher instanceof AnyString;
        }
      },
    );
  }
}

function path_matches(expected, actual) {
  if (expected instanceof Some) {
    let string_matcher = expected[0];
    return apply_string_matcher(string_matcher, actual);
  } else {
    return true;
  }
}

function method_matches(expected, actual) {
  if (expected instanceof Some) {
    let method$1 = expected[0];
    return isEqual(method$1, actual);
  } else {
    return true;
  }
}

/**
 * Returns `True` if `recorded_request` satisfies all constraints on
 * `request_matcher`.
 *
 * This is the same matching logic the server uses internally. You can call it
 * directly when filtering `recorded_requests` for custom assertions.
 */
export function matches(request_matcher, recorded_request) {
  return (((method_matches(request_matcher.method, recorded_request.method) && path_matches(
    request_matcher.path,
    recorded_request.path,
  )) && query_params_match(request_matcher.query_params, recorded_request.query)) && headers_match(
    request_matcher.headers,
    recorded_request.headers,
  )) && body_matches(request_matcher.body, recorded_request.body);
}
