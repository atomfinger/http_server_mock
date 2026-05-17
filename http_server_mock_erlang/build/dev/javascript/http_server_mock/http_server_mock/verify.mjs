import * as $http from "../../gleam_http/gleam/http.mjs";
import * as $int from "../../gleam_stdlib/gleam/int.mjs";
import * as $list from "../../gleam_stdlib/gleam/list.mjs";
import * as $option from "../../gleam_stdlib/gleam/option.mjs";
import * as $string from "../../gleam_stdlib/gleam/string.mjs";
import { Ok, Empty as $Empty, makeError } from "../gleam.mjs";
import * as $server from "../http_server_mock/internal/server.mjs";
import * as $matcher from "../http_server_mock/matcher.mjs";
import * as $types from "../http_server_mock/types.mjs";

const FILEPATH = "src/http_server_mock/verify.gleam";

function format_requests(recorded_requests) {
  if (recorded_requests instanceof $Empty) {
    return "  (none)";
  } else {
    let _pipe = recorded_requests;
    let _pipe$1 = $list.map(
      _pipe,
      (recorded_request) => {
        return ((("  " + (() => {
          let _pipe$1 = $http.method_to_string(recorded_request.method);
          return $string.uppercase(_pipe$1);
        })()) + " ") + recorded_request.path) + (() => {
          let $ = recorded_request.query;
          if ($ instanceof $option.Some) {
            let query_string = $[0];
            return "?" + query_string;
          } else {
            return "";
          }
        })();
      },
    );
    return $string.join(_pipe$1, "\n");
  }
}

function format_matcher(request_matcher) {
  let _block;
  let $ = request_matcher.method;
  if ($ instanceof $option.Some) {
    let method = $[0];
    let _pipe = $http.method_to_string(method);
    _block = $string.uppercase(_pipe);
  } else {
    _block = "ANY";
  }
  let method = _block;
  let _block$1;
  let $1 = request_matcher.path;
  if ($1 instanceof $option.Some) {
    let $2 = $1[0];
    if ($2 instanceof $types.Exact) {
      let path = $2[0];
      _block$1 = path;
    } else if ($2 instanceof $types.Contains) {
      let fragment = $2[0];
      _block$1 = "CONTAINS " + fragment;
    } else if ($2 instanceof $types.Prefix) {
      let prefix = $2[0];
      _block$1 = "PREFIX " + prefix;
    } else if ($2 instanceof $types.Suffix) {
      let suffix = $2[0];
      _block$1 = "SUFFIX " + suffix;
    } else {
      _block$1 = "ANY PATH";
    }
  } else {
    _block$1 = "ANY PATH";
  }
  let path = _block$1;
  return (("Matcher: " + method) + " ") + path;
}

function fetch_requests(mock_server) {
  let $ = $server.recorded_requests(mock_server);
  if ($ instanceof Ok) {
    let requests = $[0];
    return requests;
  } else {
    let reason = $[0];
    throw makeError(
      "panic",
      FILEPATH,
      "http_server_mock/verify",
      133,
      "fetch_requests",
      ("Failed to fetch recorded requests: " + reason),
      {}
    )
  }
}

/**
 * Asserts that at least one recorded request matches `request_matcher`.
 *
 * Returns the matching requests so you can chain further assertions.
 * Panics with a descriptive message if no matching request was recorded.
 */
export function called(mock_server, request_matcher) {
  let recorded_requests = fetch_requests(mock_server);
  let matched = $list.filter(
    recorded_requests,
    (_capture) => { return $matcher.matches(request_matcher, _capture); },
  );
  if (matched instanceof $Empty) {
    throw makeError(
      "panic",
      FILEPATH,
      "http_server_mock/verify",
      36,
      "called",
      ((("Expected at least one matching request but got none.\n" + format_matcher(
        request_matcher,
      )) + "\nRecorded requests:\n") + format_requests(recorded_requests)),
      {}
    )
  } else {
    return matched;
  }
}

/**
 * Asserts that exactly `count` recorded requests match `request_matcher`.
 *
 * Returns the matching requests so you can chain further assertions.
 * Panics with a descriptive message if the actual count differs from `count`.
 */
export function called_times(mock_server, request_matcher, count) {
  let recorded_requests = fetch_requests(mock_server);
  let matched = $list.filter(
    recorded_requests,
    (_capture) => { return $matcher.matches(request_matcher, _capture); },
  );
  let matched_count = $list.length(matched);
  let $ = matched_count === count;
  if ($) {
    return matched;
  } else {
    throw makeError(
      "panic",
      FILEPATH,
      "http_server_mock/verify",
      62,
      "called_times",
      ((((((("Expected " + $int.to_string(count)) + " matching request(s) but got ") + $int.to_string(
        matched_count,
      )) + ".\n") + format_matcher(request_matcher)) + "\nRecorded requests:\n") + format_requests(
        recorded_requests,
      )),
      {}
    )
  }
}

/**
 * Asserts that at least `count` recorded requests match `request_matcher`.
 *
 * Returns the matching requests so you can chain further assertions.
 * Panics with a descriptive message if fewer than `count` requests matched.
 */
export function called_at_least(mock_server, request_matcher, count) {
  let recorded_requests = fetch_requests(mock_server);
  let matched = $list.filter(
    recorded_requests,
    (_capture) => { return $matcher.matches(request_matcher, _capture); },
  );
  let matched_count = $list.length(matched);
  let $ = matched_count >= count;
  if ($) {
    return matched;
  } else {
    throw makeError(
      "panic",
      FILEPATH,
      "http_server_mock/verify",
      91,
      "called_at_least",
      ((((((("Expected at least " + $int.to_string(count)) + " matching request(s) but got ") + $int.to_string(
        matched_count,
      )) + ".\n") + format_matcher(request_matcher)) + "\nRecorded requests:\n") + format_requests(
        recorded_requests,
      )),
      {}
    )
  }
}

/**
 * Asserts that no recorded request matches `request_matcher`.
 *
 * Panics with a descriptive message (including the unexpected requests) if
 * any matching request was recorded.
 */
export function never_called(mock_server, request_matcher) {
  let recorded_requests = fetch_requests(mock_server);
  let matched = $list.filter(
    recorded_requests,
    (_capture) => { return $matcher.matches(request_matcher, _capture); },
  );
  if (matched instanceof $Empty) {
    return undefined;
  } else {
    throw makeError(
      "panic",
      FILEPATH,
      "http_server_mock/verify",
      118,
      "never_called",
      ((((("Expected no matching requests but got " + $int.to_string(
        $list.length(matched),
      )) + ".\n") + format_matcher(request_matcher)) + "\nMatched requests:\n") + format_requests(
        matched,
      )),
      {}
    )
  }
}
