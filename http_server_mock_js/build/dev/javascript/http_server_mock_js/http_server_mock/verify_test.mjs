import * as $list from "../../gleam_stdlib/gleam/list.mjs";
import * as $http_server_mock from "../../http_server_mock/http_server_mock.mjs";
import * as $matcher from "../../http_server_mock/http_server_mock/matcher.mjs";
import * as $response from "../../http_server_mock/http_server_mock/response.mjs";
import * as $stub_builder from "../../http_server_mock/http_server_mock/stub_builder.mjs";
import * as $verify from "../../http_server_mock/http_server_mock/verify.mjs";
import { Ok, Empty as $Empty, makeError } from "../gleam.mjs";
import * as $http_server_mock_js from "../http_server_mock_js.mjs";
import { syncGet as get } from "./integration_test_ffi.mjs";

const FILEPATH = "test/http_server_mock/verify_test.gleam";

export function called_returns_matched_requests_test() {
  let _block;
  let _pipe = $http_server_mock.new$($http_server_mock_js.server());
  _block = $http_server_mock.start(_pipe);
  let server = _block;
  let base = $http_server_mock.base_url(server);
  let $ = $http_server_mock.add_stub(
    server,
    (() => {
      let _pipe$1 = $stub_builder.new$();
      let _pipe$2 = $stub_builder.matching(
        _pipe$1,
        (() => {
          let _pipe$2 = $matcher.new$();
          return $matcher.path(_pipe$2, "/hello");
        })(),
      );
      let _pipe$3 = $stub_builder.responding_with(_pipe$2, $response.ok());
      return $stub_builder.build(_pipe$3);
    })(),
  );
  if (!($ instanceof Ok)) {
    throw makeError(
      "let_assert",
      FILEPATH,
      "http_server_mock/verify_test",
      20,
      "called_returns_matched_requests_test",
      "Pattern match failed, no pattern matched the value.",
      { value: $, start: 543, end: 799, pattern_start: 554, pattern_end: 559 }
    )
  }
  let $1 = $http_server_mock.add_stub(
    server,
    (() => {
      let _pipe$1 = $stub_builder.new$();
      let _pipe$2 = $stub_builder.matching(
        _pipe$1,
        (() => {
          let _pipe$2 = $matcher.new$();
          return $matcher.path(_pipe$2, "/other");
        })(),
      );
      let _pipe$3 = $stub_builder.responding_with(_pipe$2, $response.ok());
      return $stub_builder.build(_pipe$3);
    })(),
  );
  if (!($1 instanceof Ok)) {
    throw makeError(
      "let_assert",
      FILEPATH,
      "http_server_mock/verify_test",
      28,
      "called_returns_matched_requests_test",
      "Pattern match failed, no pattern matched the value.",
      { value: $1, start: 802, end: 1058, pattern_start: 813, pattern_end: 818 }
    )
  }
  get(base + "/hello");
  get(base + "/other");
  let result = $verify.called(
    server,
    (() => {
      let _pipe$1 = $matcher.new$();
      return $matcher.path(_pipe$1, "/hello");
    })(),
  );
  let req;
  if (result instanceof $Empty) {
    throw makeError(
      "let_assert",
      FILEPATH,
      "http_server_mock/verify_test",
      41,
      "called_returns_matched_requests_test",
      "Pattern match failed, no pattern matched the value.",
      {
        value: result,
        start: 1189,
        end: 1214,
        pattern_start: 1200,
        pattern_end: 1205
      }
    )
  } else {
    let $2 = result.tail;
    if ($2 instanceof $Empty) {
      req = result.head;
    } else {
      throw makeError(
        "let_assert",
        FILEPATH,
        "http_server_mock/verify_test",
        41,
        "called_returns_matched_requests_test",
        "Pattern match failed, no pattern matched the value.",
        {
          value: result,
          start: 1189,
          end: 1214,
          pattern_start: 1200,
          pattern_end: 1205
        }
      )
    }
  }
  let $3 = req.path;
  let $4 = "/hello";
  if (!($3 === $4)) {
    throw makeError(
      "assert",
      FILEPATH,
      "http_server_mock/verify_test",
      42,
      "called_returns_matched_requests_test",
      "Assertion failed.",
      {
        kind: "binary_operator",
        operator: "==",
        left: { kind: "expression", value: $3, start: 1224, end: 1232 },
        right: { kind: "literal", value: $4, start: 1236, end: 1244 },
        start: 1217,
        end: 1244,
        expression_start: 1224
      }
    )
  }
  return $http_server_mock.stop(server);
}

export function called_times_returns_matched_when_count_correct_test() {
  let _block;
  let _pipe = $http_server_mock.new$($http_server_mock_js.server());
  _block = $http_server_mock.start(_pipe);
  let server = _block;
  let base = $http_server_mock.base_url(server);
  let $ = $http_server_mock.add_stub(
    server,
    (() => {
      let _pipe$1 = $stub_builder.new$();
      let _pipe$2 = $stub_builder.matching(
        _pipe$1,
        (() => {
          let _pipe$2 = $matcher.new$();
          return $matcher.path(_pipe$2, "/api");
        })(),
      );
      let _pipe$3 = $stub_builder.responding_with(_pipe$2, $response.ok());
      return $stub_builder.build(_pipe$3);
    })(),
  );
  if (!($ instanceof Ok)) {
    throw makeError(
      "let_assert",
      FILEPATH,
      "http_server_mock/verify_test",
      53,
      "called_times_returns_matched_when_count_correct_test",
      "Pattern match failed, no pattern matched the value.",
      {
        value: $,
        start: 1497,
        end: 1751,
        pattern_start: 1508,
        pattern_end: 1513
      }
    )
  }
  get(base + "/api");
  get(base + "/api");
  let result = $verify.called_times(
    server,
    (() => {
      let _pipe$1 = $matcher.new$();
      return $matcher.path(_pipe$1, "/api");
    })(),
    2,
  );
  let $1 = $list.length(result);
  let $2 = 2;
  if (!($1 === $2)) {
    throw makeError(
      "assert",
      FILEPATH,
      "http_server_mock/verify_test",
      67,
      "called_times_returns_matched_when_count_correct_test",
      "Assertion failed.",
      {
        kind: "binary_operator",
        operator: "==",
        left: { kind: "expression", value: $1, start: 1896, end: 1915 },
        right: { kind: "literal", value: $2, start: 1919, end: 1920 },
        start: 1889,
        end: 1920,
        expression_start: 1896
      }
    )
  }
  return $http_server_mock.stop(server);
}

export function called_at_least_returns_matched_when_enough_test() {
  let _block;
  let _pipe = $http_server_mock.new$($http_server_mock_js.server());
  _block = $http_server_mock.start(_pipe);
  let server = _block;
  let base = $http_server_mock.base_url(server);
  let $ = $http_server_mock.add_stub(
    server,
    (() => {
      let _pipe$1 = $stub_builder.new$();
      let _pipe$2 = $stub_builder.matching(
        _pipe$1,
        (() => {
          let _pipe$2 = $matcher.new$();
          return $matcher.path(_pipe$2, "/x");
        })(),
      );
      let _pipe$3 = $stub_builder.responding_with(_pipe$2, $response.ok());
      return $stub_builder.build(_pipe$3);
    })(),
  );
  if (!($ instanceof Ok)) {
    throw makeError(
      "let_assert",
      FILEPATH,
      "http_server_mock/verify_test",
      78,
      "called_at_least_returns_matched_when_enough_test",
      "Pattern match failed, no pattern matched the value.",
      {
        value: $,
        start: 2169,
        end: 2421,
        pattern_start: 2180,
        pattern_end: 2185
      }
    )
  }
  get(base + "/x");
  get(base + "/x");
  get(base + "/x");
  let result = $verify.called_at_least(
    server,
    (() => {
      let _pipe$1 = $matcher.new$();
      return $matcher.path(_pipe$1, "/x");
    })(),
    2,
  );
  let $1 = $list.length(result);
  let $2 = 3;
  if (!($1 === $2)) {
    throw makeError(
      "assert",
      FILEPATH,
      "http_server_mock/verify_test",
      93,
      "called_at_least_returns_matched_when_enough_test",
      "Assertion failed.",
      {
        kind: "binary_operator",
        operator: "==",
        left: { kind: "expression", value: $1, start: 2583, end: 2602 },
        right: { kind: "literal", value: $2, start: 2606, end: 2607 },
        start: 2576,
        end: 2607,
        expression_start: 2583
      }
    )
  }
  return $http_server_mock.stop(server);
}

export function never_called_passes_when_no_requests_made_test() {
  let _block;
  let _pipe = $http_server_mock.new$($http_server_mock_js.server());
  _block = $http_server_mock.start(_pipe);
  let server = _block;
  $verify.never_called(
    server,
    (() => {
      let _pipe$1 = $matcher.new$();
      return $matcher.path(_pipe$1, "/never");
    })(),
  );
  return $http_server_mock.stop(server);
}
