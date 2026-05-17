import * as $http from "../../gleam_http/gleam/http.mjs";
import * as $list from "../../gleam_stdlib/gleam/list.mjs";
import * as $option from "../../gleam_stdlib/gleam/option.mjs";
import * as $result from "../../gleam_stdlib/gleam/result.mjs";
import * as $string from "../../gleam_stdlib/gleam/string.mjs";
import * as $http_server_mock from "../../http_server_mock/http_server_mock.mjs";
import * as $matcher from "../../http_server_mock/http_server_mock/matcher.mjs";
import * as $mock_response from "../../http_server_mock/http_server_mock/response.mjs";
import * as $stub_builder from "../../http_server_mock/http_server_mock/stub_builder.mjs";
import * as $verify from "../../http_server_mock/http_server_mock/verify.mjs";
import { Ok, toList, CustomType as $CustomType, makeError, isEqual } from "../gleam.mjs";
import * as $http_server_mock_js from "../http_server_mock_js.mjs";
import { syncGet as get, syncPost as post, syncDelete as delete$ } from "./integration_test_ffi.mjs";

const FILEPATH = "test/http_server_mock/integration_test.gleam";

class TestResponse extends $CustomType {
  constructor(status, headers, body) {
    super();
    this.status = status;
    this.headers = headers;
    this.body = body;
  }
}

export function simple_get_stub_test() {
  let _block;
  let _pipe = $http_server_mock.new$($http_server_mock_js.server());
  _block = $http_server_mock.start(_pipe);
  let server = _block;
  let $ = $http_server_mock.add_stub(
    server,
    (() => {
      let _pipe$1 = $stub_builder.new$();
      let _pipe$2 = $stub_builder.matching(
        _pipe$1,
        (() => {
          let _pipe$2 = $matcher.new$();
          let _pipe$3 = $matcher.method(_pipe$2, new $http.Get());
          return $matcher.path(_pipe$3, "/hello");
        })(),
      );
      let _pipe$3 = $stub_builder.responding_with(
        _pipe$2,
        (() => {
          let _pipe$3 = $mock_response.new$();
          let _pipe$4 = $mock_response.status(_pipe$3, 200);
          return $mock_response.body(_pipe$4, "world");
        })(),
      );
      return $stub_builder.build(_pipe$3);
    })(),
  );
  if (!($ instanceof Ok)) {
    throw makeError(
      "let_assert",
      FILEPATH,
      "http_server_mock/integration_test",
      37,
      "simple_get_stub_test",
      "Pattern match failed, no pattern matched the value.",
      {
        value: $,
        start: 1042,
        end: 1474,
        pattern_start: 1053,
        pattern_end: 1058
      }
    )
  }
  let http_response = get($http_server_mock.base_url(server) + "/hello");
  let $1 = http_response.status;
  let $2 = 200;
  if (!($1 === $2)) {
    throw makeError(
      "assert",
      FILEPATH,
      "http_server_mock/integration_test",
      55,
      "simple_get_stub_test",
      "Assertion failed.",
      {
        kind: "binary_operator",
        operator: "==",
        left: { kind: "expression", value: $1, start: 1558, end: 1578 },
        right: { kind: "literal", value: $2, start: 1582, end: 1585 },
        start: 1551,
        end: 1585,
        expression_start: 1558
      }
    )
  }
  let $3 = http_response.body;
  let $4 = "world";
  if (!($3 === $4)) {
    throw makeError(
      "assert",
      FILEPATH,
      "http_server_mock/integration_test",
      56,
      "simple_get_stub_test",
      "Assertion failed.",
      {
        kind: "binary_operator",
        operator: "==",
        left: { kind: "expression", value: $3, start: 1595, end: 1613 },
        right: { kind: "literal", value: $4, start: 1617, end: 1624 },
        start: 1588,
        end: 1624,
        expression_start: 1595
      }
    )
  }
  return $http_server_mock.stop(server);
}

export function unmatched_request_returns_404_test() {
  let _block;
  let _pipe = $http_server_mock.new$($http_server_mock_js.server());
  _block = $http_server_mock.start(_pipe);
  let server = _block;
  let $ = get($http_server_mock.base_url(server) + "/no-such-path").status;
  let $1 = 404;
  if (!($ === $1)) {
    throw makeError(
      "assert",
      FILEPATH,
      "http_server_mock/integration_test",
      66,
      "unmatched_request_returns_404_test",
      "Assertion failed.",
      {
        kind: "binary_operator",
        operator: "==",
        left: { kind: "expression", value: $, start: 1819, end: 1883 },
        right: { kind: "literal", value: $1, start: 1887, end: 1890 },
        start: 1812,
        end: 1890,
        expression_start: 1819
      }
    )
  }
  return $http_server_mock.stop(server);
}

export function stub_with_response_headers_test() {
  let _block;
  let _pipe = $http_server_mock.new$($http_server_mock_js.server());
  _block = $http_server_mock.start(_pipe);
  let server = _block;
  let $ = $http_server_mock.add_stub(
    server,
    (() => {
      let _pipe$1 = $stub_builder.new$();
      let _pipe$2 = $stub_builder.matching(
        _pipe$1,
        (() => {
          let _pipe$2 = $matcher.new$();
          return $matcher.path(_pipe$2, "/json-data");
        })(),
      );
      let _pipe$3 = $stub_builder.responding_with(
        _pipe$2,
        (() => {
          let _pipe$3 = $mock_response.new$();
          let _pipe$4 = $mock_response.status(_pipe$3, 200);
          let _pipe$5 = $mock_response.header(
            _pipe$4,
            "content-type",
            "application/json",
          );
          return $mock_response.json_body(_pipe$5, "{\"ok\":true}");
        })(),
      );
      return $stub_builder.build(_pipe$3);
    })(),
  );
  if (!($ instanceof Ok)) {
    throw makeError(
      "let_assert",
      FILEPATH,
      "http_server_mock/integration_test",
      76,
      "stub_with_response_headers_test",
      "Pattern match failed, no pattern matched the value.",
      {
        value: $,
        start: 2075,
        end: 2525,
        pattern_start: 2086,
        pattern_end: 2091
      }
    )
  }
  let http_response = get($http_server_mock.base_url(server) + "/json-data");
  let $1 = http_response.status;
  let $2 = 200;
  if (!($1 === $2)) {
    throw makeError(
      "assert",
      FILEPATH,
      "http_server_mock/integration_test",
      91,
      "stub_with_response_headers_test",
      "Assertion failed.",
      {
        kind: "binary_operator",
        operator: "==",
        left: { kind: "expression", value: $1, start: 2613, end: 2633 },
        right: { kind: "literal", value: $2, start: 2637, end: 2640 },
        start: 2606,
        end: 2640,
        expression_start: 2613
      }
    )
  }
  let $3 = http_response.body;
  let $4 = "{\"ok\":true}";
  if (!($3 === $4)) {
    throw makeError(
      "assert",
      FILEPATH,
      "http_server_mock/integration_test",
      92,
      "stub_with_response_headers_test",
      "Assertion failed.",
      {
        kind: "binary_operator",
        operator: "==",
        left: { kind: "expression", value: $3, start: 2650, end: 2668 },
        right: { kind: "literal", value: $4, start: 2672, end: 2687 },
        start: 2643,
        end: 2687,
        expression_start: 2650
      }
    )
  }
  let _block$1;
  let _pipe$1 = http_response.headers;
  let _pipe$2 = $list.key_find(_pipe$1, "content-type");
  _block$1 = $result.unwrap(_pipe$2, "");
  let content_type = _block$1;
  let $5 = "application/json";
  if (!$string.contains(content_type, $5)) {
    throw makeError(
      "assert",
      FILEPATH,
      "http_server_mock/integration_test",
      97,
      "stub_with_response_headers_test",
      "Assertion failed.",
      {
        kind: "function_call",
        arguments: [
          { kind: "expression", value: content_type, start: 2822, end: 2834 },
          { kind: "literal", value: $5, start: 2836, end: 2854 },
        ],
        start: 2799,
        end: 2855,
        expression_start: 2806
      }
    )
  }
  return $http_server_mock.stop(server);
}

export function multiple_stubs_different_paths_test() {
  let _block;
  let _pipe = $http_server_mock.new$($http_server_mock_js.server());
  _block = $http_server_mock.start(_pipe);
  let server = _block;
  let $ = $http_server_mock.add_stub(
    server,
    (() => {
      let _pipe$1 = $stub_builder.new$();
      let _pipe$2 = $stub_builder.matching(
        _pipe$1,
        (() => {
          let _pipe$2 = $matcher.new$();
          return $matcher.path(_pipe$2, "/a");
        })(),
      );
      let _pipe$3 = $stub_builder.responding_with(
        _pipe$2,
        (() => {
          let _pipe$3 = $mock_response.new$();
          return $mock_response.body(_pipe$3, "response-a");
        })(),
      );
      return $stub_builder.build(_pipe$3);
    })(),
  );
  if (!($ instanceof Ok)) {
    throw makeError(
      "let_assert",
      FILEPATH,
      "http_server_mock/integration_test",
      107,
      "multiple_stubs_different_paths_test",
      "Pattern match failed, no pattern matched the value.",
      {
        value: $,
        start: 3044,
        end: 3359,
        pattern_start: 3055,
        pattern_end: 3060
      }
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
          return $matcher.path(_pipe$2, "/b");
        })(),
      );
      let _pipe$3 = $stub_builder.responding_with(
        _pipe$2,
        (() => {
          let _pipe$3 = $mock_response.new$();
          return $mock_response.body(_pipe$3, "response-b");
        })(),
      );
      return $stub_builder.build(_pipe$3);
    })(),
  );
  if (!($1 instanceof Ok)) {
    throw makeError(
      "let_assert",
      FILEPATH,
      "http_server_mock/integration_test",
      117,
      "multiple_stubs_different_paths_test",
      "Pattern match failed, no pattern matched the value.",
      {
        value: $1,
        start: 3362,
        end: 3677,
        pattern_start: 3373,
        pattern_end: 3378
      }
    )
  }
  let $2 = get($http_server_mock.base_url(server) + "/a").body;
  let $3 = "response-a";
  if (!($2 === $3)) {
    throw makeError(
      "assert",
      FILEPATH,
      "http_server_mock/integration_test",
      128,
      "multiple_stubs_different_paths_test",
      "Assertion failed.",
      {
        kind: "binary_operator",
        operator: "==",
        left: { kind: "expression", value: $2, start: 3688, end: 3739 },
        right: { kind: "literal", value: $3, start: 3743, end: 3755 },
        start: 3681,
        end: 3755,
        expression_start: 3688
      }
    )
  }
  let $4 = get($http_server_mock.base_url(server) + "/b").body;
  let $5 = "response-b";
  if (!($4 === $5)) {
    throw makeError(
      "assert",
      FILEPATH,
      "http_server_mock/integration_test",
      129,
      "multiple_stubs_different_paths_test",
      "Assertion failed.",
      {
        kind: "binary_operator",
        operator: "==",
        left: { kind: "expression", value: $4, start: 3765, end: 3816 },
        right: { kind: "literal", value: $5, start: 3820, end: 3832 },
        start: 3758,
        end: 3832,
        expression_start: 3765
      }
    )
  }
  return $http_server_mock.stop(server);
}

export function recorded_requests_tracks_calls_test() {
  let _block;
  let _pipe = $http_server_mock.new$($http_server_mock_js.server());
  _block = $http_server_mock.start(_pipe);
  let server = _block;
  let $ = $http_server_mock.add_stub(
    server,
    (() => {
      let _pipe$1 = $stub_builder.new$();
      let _pipe$2 = $stub_builder.matching(
        _pipe$1,
        (() => {
          let _pipe$2 = $matcher.new$();
          return $matcher.path(_pipe$2, "/track");
        })(),
      );
      let _pipe$3 = $stub_builder.responding_with(
        _pipe$2,
        (() => {
          let _pipe$3 = $mock_response.new$();
          return $mock_response.body(_pipe$3, "ok");
        })(),
      );
      return $stub_builder.build(_pipe$3);
    })(),
  );
  if (!($ instanceof Ok)) {
    throw makeError(
      "let_assert",
      FILEPATH,
      "http_server_mock/integration_test",
      139,
      "recorded_requests_tracks_calls_test",
      "Pattern match failed, no pattern matched the value.",
      {
        value: $,
        start: 4021,
        end: 4332,
        pattern_start: 4032,
        pattern_end: 4037
      }
    )
  }
  let $1 = get($http_server_mock.base_url(server) + "/track");
  
  let $2 = get($http_server_mock.base_url(server) + "/track");
  
  let $3 = $http_server_mock.recorded_requests(server);
  let recorded_requests;
  if ($3 instanceof Ok) {
    recorded_requests = $3[0];
  } else {
    throw makeError(
      "let_assert",
      FILEPATH,
      "http_server_mock/integration_test",
      153,
      "recorded_requests_tracks_calls_test",
      "Pattern match failed, no pattern matched the value.",
      {
        value: $3,
        start: 4459,
        end: 4536,
        pattern_start: 4470,
        pattern_end: 4491
      }
    )
  }
  let tracked = $list.filter(
    recorded_requests,
    (recorded) => { return recorded.path === "/track"; },
  );
  let $4 = $list.length(tracked);
  let $5 = 2;
  if (!($4 === $5)) {
    throw makeError(
      "assert",
      FILEPATH,
      "http_server_mock/integration_test",
      156,
      "recorded_requests_tracks_calls_test",
      "Assertion failed.",
      {
        kind: "binary_operator",
        operator: "==",
        left: { kind: "expression", value: $4, start: 4641, end: 4661 },
        right: { kind: "literal", value: $5, start: 4665, end: 4666 },
        start: 4634,
        end: 4666,
        expression_start: 4641
      }
    )
  }
  return $http_server_mock.stop(server);
}

export function verify_called_times_test() {
  let _block;
  let _pipe = $http_server_mock.new$($http_server_mock_js.server());
  _block = $http_server_mock.start(_pipe);
  let server = _block;
  let _block$1;
  let _pipe$1 = $matcher.new$();
  let _pipe$2 = $matcher.method(_pipe$1, new $http.Get());
  _block$1 = $matcher.path(_pipe$2, "/counted");
  let request_matcher = _block$1;
  let $ = $http_server_mock.add_stub(
    server,
    (() => {
      let _pipe$3 = $stub_builder.new$();
      let _pipe$4 = $stub_builder.matching(_pipe$3, request_matcher);
      let _pipe$5 = $stub_builder.responding_with(
        _pipe$4,
        (() => {
          let _pipe$5 = $mock_response.new$();
          return $mock_response.body(_pipe$5, "ok");
        })(),
      );
      return $stub_builder.build(_pipe$5);
    })(),
  );
  if (!($ instanceof Ok)) {
    throw makeError(
      "let_assert",
      FILEPATH,
      "http_server_mock/integration_test",
      168,
      "verify_called_times_test",
      "Pattern match failed, no pattern matched the value.",
      {
        value: $,
        start: 4942,
        end: 5229,
        pattern_start: 4953,
        pattern_end: 4958
      }
    )
  }
  let $1 = get($http_server_mock.base_url(server) + "/counted");
  
  let $2 = get($http_server_mock.base_url(server) + "/counted");
  
  let $3 = get($http_server_mock.base_url(server) + "/counted");
  
  $verify.called_times(server, request_matcher, 3);
  return $http_server_mock.stop(server);
}

export function reset_stubs_removes_all_stubs_test() {
  let _block;
  let _pipe = $http_server_mock.new$($http_server_mock_js.server());
  _block = $http_server_mock.start(_pipe);
  let server = _block;
  let $ = $http_server_mock.add_stub(
    server,
    (() => {
      let _pipe$1 = $stub_builder.new$();
      let _pipe$2 = $stub_builder.matching(
        _pipe$1,
        (() => {
          let _pipe$2 = $matcher.new$();
          return $matcher.path(_pipe$2, "/gone");
        })(),
      );
      let _pipe$3 = $stub_builder.responding_with(
        _pipe$2,
        (() => {
          let _pipe$3 = $mock_response.new$();
          return $mock_response.body(_pipe$3, "was here");
        })(),
      );
      return $stub_builder.build(_pipe$3);
    })(),
  );
  if (!($ instanceof Ok)) {
    throw makeError(
      "let_assert",
      FILEPATH,
      "http_server_mock/integration_test",
      193,
      "reset_stubs_removes_all_stubs_test",
      "Pattern match failed, no pattern matched the value.",
      {
        value: $,
        start: 5658,
        end: 5974,
        pattern_start: 5669,
        pattern_end: 5674
      }
    )
  }
  let $1 = get($http_server_mock.base_url(server) + "/gone").status;
  let $2 = 200;
  if (!($1 === $2)) {
    throw makeError(
      "assert",
      FILEPATH,
      "http_server_mock/integration_test",
      204,
      "reset_stubs_removes_all_stubs_test",
      "Assertion failed.",
      {
        kind: "binary_operator",
        operator: "==",
        left: { kind: "expression", value: $1, start: 5985, end: 6041 },
        right: { kind: "literal", value: $2, start: 6045, end: 6048 },
        start: 5978,
        end: 6048,
        expression_start: 5985
      }
    )
  }
  $http_server_mock.reset_stubs(server);
  let $3 = get($http_server_mock.base_url(server) + "/gone").status;
  let $4 = 404;
  if (!($3 === $4)) {
    throw makeError(
      "assert",
      FILEPATH,
      "http_server_mock/integration_test",
      206,
      "reset_stubs_removes_all_stubs_test",
      "Assertion failed.",
      {
        kind: "binary_operator",
        operator: "==",
        left: { kind: "expression", value: $3, start: 6097, end: 6153 },
        right: { kind: "literal", value: $4, start: 6157, end: 6160 },
        start: 6090,
        end: 6160,
        expression_start: 6097
      }
    )
  }
  return $http_server_mock.stop(server);
}

export function reset_requests_clears_history_test() {
  let _block;
  let _pipe = $http_server_mock.new$($http_server_mock_js.server());
  _block = $http_server_mock.start(_pipe);
  let server = _block;
  let $ = $http_server_mock.add_stub(
    server,
    (() => {
      let _pipe$1 = $stub_builder.new$();
      let _pipe$2 = $stub_builder.matching(
        _pipe$1,
        (() => {
          let _pipe$2 = $matcher.new$();
          return $matcher.path(_pipe$2, "/call");
        })(),
      );
      let _pipe$3 = $stub_builder.responding_with(
        _pipe$2,
        (() => {
          let _pipe$3 = $mock_response.new$();
          return $mock_response.body(_pipe$3, "ok");
        })(),
      );
      return $stub_builder.build(_pipe$3);
    })(),
  );
  if (!($ instanceof Ok)) {
    throw makeError(
      "let_assert",
      FILEPATH,
      "http_server_mock/integration_test",
      216,
      "reset_requests_clears_history_test",
      "Pattern match failed, no pattern matched the value.",
      {
        value: $,
        start: 6348,
        end: 6658,
        pattern_start: 6359,
        pattern_end: 6364
      }
    )
  }
  let $1 = get($http_server_mock.base_url(server) + "/call");
  
  $http_server_mock.reset_requests(server);
  let $2 = $http_server_mock.recorded_requests(server);
  let recorded_requests;
  if ($2 instanceof Ok) {
    recorded_requests = $2[0];
  } else {
    throw makeError(
      "let_assert",
      FILEPATH,
      "http_server_mock/integration_test",
      230,
      "reset_requests_clears_history_test",
      "Pattern match failed, no pattern matched the value.",
      {
        value: $2,
        start: 6765,
        end: 6842,
        pattern_start: 6776,
        pattern_end: 6797
      }
    )
  }
  let $3 = toList([]);
  if (!(isEqual(recorded_requests, $3))) {
    throw makeError(
      "assert",
      FILEPATH,
      "http_server_mock/integration_test",
      231,
      "reset_requests_clears_history_test",
      "Assertion failed.",
      {
        kind: "binary_operator",
        operator: "==",
        left: {
          kind: "expression",
          value: recorded_requests,
          start: 6852,
          end: 6869
        },
        right: { kind: "literal", value: $3, start: 6873, end: 6875 },
        start: 6845,
        end: 6875,
        expression_start: 6852
      }
    )
  }
  return $http_server_mock.stop(server);
}

export function query_param_matching_test() {
  let _block;
  let _pipe = $http_server_mock.new$($http_server_mock_js.server());
  _block = $http_server_mock.start(_pipe);
  let server = _block;
  let _block$1;
  let _pipe$1 = $matcher.new$();
  let _pipe$2 = $matcher.path(_pipe$1, "/search");
  _block$1 = $matcher.query_param(_pipe$2, "q", "gleam");
  let request_matcher = _block$1;
  let $ = $http_server_mock.add_stub(
    server,
    (() => {
      let _pipe$3 = $stub_builder.new$();
      let _pipe$4 = $stub_builder.matching(_pipe$3, request_matcher);
      let _pipe$5 = $stub_builder.responding_with(
        _pipe$4,
        (() => {
          let _pipe$5 = $mock_response.new$();
          return $mock_response.body(_pipe$5, "found");
        })(),
      );
      return $stub_builder.build(_pipe$5);
    })(),
  );
  if (!($ instanceof Ok)) {
    throw makeError(
      "let_assert",
      FILEPATH,
      "http_server_mock/integration_test",
      245,
      "query_param_matching_test",
      "Pattern match failed, no pattern matched the value.",
      {
        value: $,
        start: 7168,
        end: 7458,
        pattern_start: 7179,
        pattern_end: 7184
      }
    )
  }
  let $1 = get($http_server_mock.base_url(server) + "/search?q=gleam").body;
  let $2 = "found";
  if (!($1 === $2)) {
    throw makeError(
      "assert",
      FILEPATH,
      "http_server_mock/integration_test",
      256,
      "query_param_matching_test",
      "Assertion failed.",
      {
        kind: "binary_operator",
        operator: "==",
        left: { kind: "expression", value: $1, start: 7469, end: 7533 },
        right: { kind: "literal", value: $2, start: 7541, end: 7548 },
        start: 7462,
        end: 7548,
        expression_start: 7469
      }
    )
  }
  let $3 = get($http_server_mock.base_url(server) + "/search?q=other").status;
  let $4 = 404;
  if (!($3 === $4)) {
    throw makeError(
      "assert",
      FILEPATH,
      "http_server_mock/integration_test",
      258,
      "query_param_matching_test",
      "Assertion failed.",
      {
        kind: "binary_operator",
        operator: "==",
        left: { kind: "expression", value: $3, start: 7558, end: 7624 },
        right: { kind: "literal", value: $4, start: 7632, end: 7635 },
        start: 7551,
        end: 7635,
        expression_start: 7558
      }
    )
  }
  return $http_server_mock.stop(server);
}

export function admin_health_endpoint_test() {
  let _block;
  let _pipe = $http_server_mock.new$($http_server_mock_js.server());
  _block = $http_server_mock.start(_pipe);
  let server = _block;
  let http_response = get(
    $http_server_mock.base_url(server) + "/__admin/health",
  );
  let $ = http_response.status;
  let $1 = 200;
  if (!($ === $1)) {
    throw makeError(
      "assert",
      FILEPATH,
      "http_server_mock/integration_test",
      271,
      "admin_health_endpoint_test",
      "Assertion failed.",
      {
        kind: "binary_operator",
        operator: "==",
        left: { kind: "expression", value: $, start: 7908, end: 7928 },
        right: { kind: "literal", value: $1, start: 7932, end: 7935 },
        start: 7901,
        end: 7935,
        expression_start: 7908
      }
    )
  }
  let $2 = http_response.body;
  let $3 = "{\"status\":\"ok\"}";
  if (!($2 === $3)) {
    throw makeError(
      "assert",
      FILEPATH,
      "http_server_mock/integration_test",
      272,
      "admin_health_endpoint_test",
      "Assertion failed.",
      {
        kind: "binary_operator",
        operator: "==",
        left: { kind: "expression", value: $2, start: 7945, end: 7963 },
        right: { kind: "literal", value: $3, start: 7967, end: 7988 },
        start: 7938,
        end: 7988,
        expression_start: 7945
      }
    )
  }
  return $http_server_mock.stop(server);
}

export function admin_stubs_list_test() {
  let _block;
  let _pipe = $http_server_mock.new$($http_server_mock_js.server());
  _block = $http_server_mock.start(_pipe);
  let server = _block;
  let $ = $http_server_mock.add_stub(
    server,
    (() => {
      let _pipe$1 = $stub_builder.new$();
      let _pipe$2 = $stub_builder.matching(
        _pipe$1,
        (() => {
          let _pipe$2 = $matcher.new$();
          return $matcher.path(_pipe$2, "/listed");
        })(),
      );
      let _pipe$3 = $stub_builder.responding_with(
        _pipe$2,
        (() => {
          let _pipe$3 = $mock_response.new$();
          return $mock_response.body(_pipe$3, "ok");
        })(),
      );
      let _pipe$4 = $stub_builder.with_id(_pipe$3, "listed-stub");
      return $stub_builder.build(_pipe$4);
    })(),
  );
  if (!($ instanceof Ok)) {
    throw makeError(
      "let_assert",
      FILEPATH,
      "http_server_mock/integration_test",
      282,
      "admin_stubs_list_test",
      "Pattern match failed, no pattern matched the value.",
      {
        value: $,
        start: 8163,
        end: 8522,
        pattern_start: 8174,
        pattern_end: 8179
      }
    )
  }
  let http_response = get($http_server_mock.base_url(server) + "/__admin/stubs");
  let $1 = http_response.status;
  let $2 = 200;
  if (!($1 === $2)) {
    throw makeError(
      "assert",
      FILEPATH,
      "http_server_mock/integration_test",
      295,
      "admin_stubs_list_test",
      "Assertion failed.",
      {
        kind: "binary_operator",
        operator: "==",
        left: { kind: "expression", value: $1, start: 8614, end: 8634 },
        right: { kind: "literal", value: $2, start: 8638, end: 8641 },
        start: 8607,
        end: 8641,
        expression_start: 8614
      }
    )
  }
  let $3 = http_response.body;
  let $4 = "listed-stub";
  if (!$string.contains($3, $4)) {
    throw makeError(
      "assert",
      FILEPATH,
      "http_server_mock/integration_test",
      296,
      "admin_stubs_list_test",
      "Assertion failed.",
      {
        kind: "function_call",
        arguments: [
          { kind: "expression", value: $3, start: 8667, end: 8685 },
          { kind: "literal", value: $4, start: 8687, end: 8700 },
        ],
        start: 8644,
        end: 8701,
        expression_start: 8651
      }
    )
  }
  return $http_server_mock.stop(server);
}

export function admin_delete_stubs_test() {
  let _block;
  let _pipe = $http_server_mock.new$($http_server_mock_js.server());
  _block = $http_server_mock.start(_pipe);
  let server = _block;
  let $ = $http_server_mock.add_stub(
    server,
    (() => {
      let _pipe$1 = $stub_builder.new$();
      let _pipe$2 = $stub_builder.matching(
        _pipe$1,
        (() => {
          let _pipe$2 = $matcher.new$();
          return $matcher.path(_pipe$2, "/bye");
        })(),
      );
      let _pipe$3 = $stub_builder.responding_with(
        _pipe$2,
        (() => {
          let _pipe$3 = $mock_response.new$();
          return $mock_response.body(_pipe$3, "hi");
        })(),
      );
      return $stub_builder.build(_pipe$3);
    })(),
  );
  if (!($ instanceof Ok)) {
    throw makeError(
      "let_assert",
      FILEPATH,
      "http_server_mock/integration_test",
      306,
      "admin_delete_stubs_test",
      "Pattern match failed, no pattern matched the value.",
      {
        value: $,
        start: 8878,
        end: 9187,
        pattern_start: 8889,
        pattern_end: 8894
      }
    )
  }
  let $1 = get($http_server_mock.base_url(server) + "/bye").status;
  let $2 = 200;
  if (!($1 === $2)) {
    throw makeError(
      "assert",
      FILEPATH,
      "http_server_mock/integration_test",
      317,
      "admin_delete_stubs_test",
      "Assertion failed.",
      {
        kind: "binary_operator",
        operator: "==",
        left: { kind: "expression", value: $1, start: 9198, end: 9253 },
        right: { kind: "literal", value: $2, start: 9257, end: 9260 },
        start: 9191,
        end: 9260,
        expression_start: 9198
      }
    )
  }
  let $3 = delete$($http_server_mock.base_url(server) + "/__admin/stubs").status;
  let $4 = 200;
  if (!($3 === $4)) {
    throw makeError(
      "assert",
      FILEPATH,
      "http_server_mock/integration_test",
      318,
      "admin_delete_stubs_test",
      "Assertion failed.",
      {
        kind: "binary_operator",
        operator: "==",
        left: { kind: "expression", value: $3, start: 9270, end: 9338 },
        right: { kind: "literal", value: $4, start: 9346, end: 9349 },
        start: 9263,
        end: 9349,
        expression_start: 9270
      }
    )
  }
  let $5 = get($http_server_mock.base_url(server) + "/bye").status;
  let $6 = 404;
  if (!($5 === $6)) {
    throw makeError(
      "assert",
      FILEPATH,
      "http_server_mock/integration_test",
      320,
      "admin_delete_stubs_test",
      "Assertion failed.",
      {
        kind: "binary_operator",
        operator: "==",
        left: { kind: "expression", value: $5, start: 9359, end: 9414 },
        right: { kind: "literal", value: $6, start: 9418, end: 9421 },
        start: 9352,
        end: 9421,
        expression_start: 9359
      }
    )
  }
  return $http_server_mock.stop(server);
}

export function unmatched_requests_test() {
  let _block;
  let _pipe = $http_server_mock.new$($http_server_mock_js.server());
  _block = $http_server_mock.start(_pipe);
  let server = _block;
  let $ = $http_server_mock.add_stub(
    server,
    (() => {
      let _pipe$1 = $stub_builder.new$();
      let _pipe$2 = $stub_builder.matching(
        _pipe$1,
        (() => {
          let _pipe$2 = $matcher.new$();
          return $matcher.path(_pipe$2, "/known");
        })(),
      );
      let _pipe$3 = $stub_builder.responding_with(_pipe$2, $mock_response.ok());
      return $stub_builder.build(_pipe$3);
    })(),
  );
  if (!($ instanceof Ok)) {
    throw makeError(
      "let_assert",
      FILEPATH,
      "http_server_mock/integration_test",
      330,
      "unmatched_requests_test",
      "Pattern match failed, no pattern matched the value.",
      {
        value: $,
        start: 9598,
        end: 9859,
        pattern_start: 9609,
        pattern_end: 9614
      }
    )
  }
  let $1 = get($http_server_mock.base_url(server) + "/known");
  
  let $2 = get($http_server_mock.base_url(server) + "/unknown-a");
  
  let $3 = get($http_server_mock.base_url(server) + "/unknown-b");
  
  let $4 = $http_server_mock.unmatched_requests(server);
  let unmatched;
  if ($4 instanceof Ok) {
    unmatched = $4[0];
  } else {
    throw makeError(
      "let_assert",
      FILEPATH,
      "http_server_mock/integration_test",
      343,
      "unmatched_requests_test",
      "Pattern match failed, no pattern matched the value.",
      {
        value: $4,
        start: 10055,
        end: 10125,
        pattern_start: 10066,
        pattern_end: 10079
      }
    )
  }
  let $5 = $list.length(unmatched);
  let $6 = 2;
  if (!($5 === $6)) {
    throw makeError(
      "assert",
      FILEPATH,
      "http_server_mock/integration_test",
      344,
      "unmatched_requests_test",
      "Assertion failed.",
      {
        kind: "binary_operator",
        operator: "==",
        left: { kind: "expression", value: $5, start: 10135, end: 10157 },
        right: { kind: "literal", value: $6, start: 10161, end: 10162 },
        start: 10128,
        end: 10162,
        expression_start: 10135
      }
    )
  }
  let $7 = (req) => { return req.matched_stub_id instanceof $option.None; };
  if (!$list.all(unmatched, $7)) {
    throw makeError(
      "assert",
      FILEPATH,
      "http_server_mock/integration_test",
      345,
      "unmatched_requests_test",
      "Assertion failed.",
      {
        kind: "function_call",
        arguments: [
          { kind: "expression", value: unmatched, start: 10181, end: 10190 },
          { kind: "expression", value: $7, start: 10192, end: 10238 },
        ],
        start: 10165,
        end: 10239,
        expression_start: 10172
      }
    )
  }
  return $http_server_mock.stop(server);
}

export function post_with_body_matching_test() {
  let _block;
  let _pipe = $http_server_mock.new$($http_server_mock_js.server());
  _block = $http_server_mock.start(_pipe);
  let server = _block;
  let _block$1;
  let _pipe$1 = $matcher.new$();
  let _pipe$2 = $matcher.method(_pipe$1, new $http.Post());
  let _pipe$3 = $matcher.path(_pipe$2, "/submit");
  _block$1 = $matcher.body_containing(_pipe$3, "important");
  let request_matcher = _block$1;
  let $ = $http_server_mock.add_stub(
    server,
    (() => {
      let _pipe$4 = $stub_builder.new$();
      let _pipe$5 = $stub_builder.matching(_pipe$4, request_matcher);
      let _pipe$6 = $stub_builder.responding_with(
        _pipe$5,
        (() => {
          let _pipe$6 = $mock_response.new$();
          return $mock_response.status(_pipe$6, 201);
        })(),
      );
      return $stub_builder.build(_pipe$6);
    })(),
  );
  if (!($ instanceof Ok)) {
    throw makeError(
      "let_assert",
      FILEPATH,
      "http_server_mock/integration_test",
      360,
      "post_with_body_matching_test",
      "Pattern match failed, no pattern matched the value.",
      {
        value: $,
        start: 10571,
        end: 10859,
        pattern_start: 10582,
        pattern_end: 10587
      }
    )
  }
  let $1 = post(
    $http_server_mock.base_url(server) + "/submit",
    "{\"important\":true}",
    "application/json",
  ).status;
  let $2 = 201;
  if (!($1 === $2)) {
    throw makeError(
      "assert",
      FILEPATH,
      "http_server_mock/integration_test",
      371,
      "post_with_body_matching_test",
      "Assertion failed.",
      {
        kind: "binary_operator",
        operator: "==",
        left: { kind: "expression", value: $1, start: 10870, end: 10998 },
        right: { kind: "literal", value: $2, start: 11006, end: 11009 },
        start: 10863,
        end: 11009,
        expression_start: 10870
      }
    )
  }
  let $3 = post(
    $http_server_mock.base_url(server) + "/submit",
    "{\"other\":true}",
    "application/json",
  ).status;
  let $4 = 404;
  if (!($3 === $4)) {
    throw makeError(
      "assert",
      FILEPATH,
      "http_server_mock/integration_test",
      378,
      "post_with_body_matching_test",
      "Assertion failed.",
      {
        kind: "binary_operator",
        operator: "==",
        left: { kind: "expression", value: $3, start: 11020, end: 11144 },
        right: { kind: "literal", value: $4, start: 11152, end: 11155 },
        start: 11013,
        end: 11155,
        expression_start: 11020
      }
    )
  }
  return $http_server_mock.stop(server);
}
