import * as $dynamic from "../../../gleam_stdlib/gleam/dynamic.mjs";
import * as $int from "../../../gleam_stdlib/gleam/int.mjs";
import { Ok, CustomType as $CustomType, makeError } from "../../gleam.mjs";
import * as $json_codec from "../../http_server_mock/internal/json_codec.mjs";
import * as $server_adapter from "../../http_server_mock/server_adapter.mjs";
import * as $types from "../../http_server_mock/types.mjs";

const FILEPATH = "src/http_server_mock/internal/server.gleam";

class MockServerNotStarted extends $CustomType {
  constructor(port, adapter) {
    super();
    this.port = port;
    this.adapter = adapter;
  }
}

class MockServerStarted extends $CustomType {
  constructor(port, handle, adapter) {
    super();
    this.port = port;
    this.handle = handle;
    this.adapter = adapter;
  }
}

class MockServerStopped extends $CustomType {
  constructor(port) {
    super();
    this.port = port;
  }
}

export function new$(adapter) {
  return new MockServerNotStarted(0, adapter);
}

export function with_port(mock_server, port_number) {
  let adapter;
  if (mock_server instanceof MockServerNotStarted) {
    adapter = mock_server.adapter;
  } else {
    throw makeError(
      "let_assert",
      FILEPATH,
      "http_server_mock/internal/server",
      30,
      "with_port",
      "Pattern match failed, no pattern matched the value.",
      {
        value: mock_server,
        start: 899,
        end: 956,
        pattern_start: 910,
        pattern_end: 942
      }
    )
  }
  return new MockServerNotStarted(port_number, adapter);
}

export function start(mock_server) {
  let port$1;
  let adapter;
  if (mock_server instanceof MockServerNotStarted) {
    port$1 = mock_server.port;
    adapter = mock_server.adapter;
  } else {
    throw makeError(
      "let_assert",
      FILEPATH,
      "http_server_mock/internal/server",
      37,
      "start",
      "Pattern match failed, no pattern matched the value.",
      {
        value: mock_server,
        start: 1118,
        end: 1178,
        pattern_start: 1129,
        pattern_end: 1164
      }
    )
  }
  let $ = adapter.start(port$1);
  if ($ instanceof Ok) {
    let actual_port = $[0][0];
    let handle = $[0][1];
    return new Ok(new MockServerStarted(actual_port, handle, adapter));
  } else {
    return $;
  }
}

export function port(mock_server) {
  let port$1;
  if (mock_server instanceof MockServerStarted) {
    port$1 = mock_server.port;
  } else {
    throw makeError(
      "let_assert",
      FILEPATH,
      "http_server_mock/internal/server",
      46,
      "port",
      "Pattern match failed, no pattern matched the value.",
      {
        value: mock_server,
        start: 1399,
        end: 1453,
        pattern_start: 1410,
        pattern_end: 1439
      }
    )
  }
  return port$1;
}

export function base_url(mock_server) {
  let port$1;
  if (mock_server instanceof MockServerStarted) {
    port$1 = mock_server.port;
  } else {
    throw makeError(
      "let_assert",
      FILEPATH,
      "http_server_mock/internal/server",
      51,
      "base_url",
      "Pattern match failed, no pattern matched the value.",
      {
        value: mock_server,
        start: 1528,
        end: 1582,
        pattern_start: 1539,
        pattern_end: 1568
      }
    )
  }
  return "http://localhost:" + $int.to_string(port$1);
}

export function stop(mock_server) {
  let port$1;
  let handle;
  let adapter;
  if (mock_server instanceof MockServerStarted) {
    port$1 = mock_server.port;
    handle = mock_server.handle;
    adapter = mock_server.adapter;
  } else {
    throw makeError(
      "let_assert",
      FILEPATH,
      "http_server_mock/internal/server",
      56,
      "stop",
      "Pattern match failed, no pattern matched the value.",
      {
        value: mock_server,
        start: 1704,
        end: 1769,
        pattern_start: 1715,
        pattern_end: 1755
      }
    )
  }
  adapter.stop(handle);
  return new MockServerStopped(port$1);
}

export function register(mock_server, stub) {
  let handle;
  let adapter;
  if (mock_server instanceof MockServerStarted) {
    handle = mock_server.handle;
    adapter = mock_server.adapter;
  } else {
    throw makeError(
      "let_assert",
      FILEPATH,
      "http_server_mock/internal/server",
      65,
      "register",
      "Pattern match failed, no pattern matched the value.",
      {
        value: mock_server,
        start: 1919,
        end: 1981,
        pattern_start: 1930,
        pattern_end: 1967
      }
    )
  }
  let stub_json = $json_codec.encode_stub(stub);
  let $ = adapter.add_stub(handle, stub_json);
  if ($ instanceof Ok) {
    return new Ok(stub);
  } else {
    return $;
  }
}

export function remove_stub(mock_server, id) {
  let handle;
  let adapter;
  if (mock_server instanceof MockServerStarted) {
    handle = mock_server.handle;
    adapter = mock_server.adapter;
  } else {
    throw makeError(
      "let_assert",
      FILEPATH,
      "http_server_mock/internal/server",
      74,
      "remove_stub",
      "Pattern match failed, no pattern matched the value.",
      {
        value: mock_server,
        start: 2214,
        end: 2276,
        pattern_start: 2225,
        pattern_end: 2262
      }
    )
  }
  return adapter.remove_stub(handle, id);
}

export function reset_stubs(mock_server) {
  let handle;
  let adapter;
  if (mock_server instanceof MockServerStarted) {
    handle = mock_server.handle;
    adapter = mock_server.adapter;
  } else {
    throw makeError(
      "let_assert",
      FILEPATH,
      "http_server_mock/internal/server",
      79,
      "reset_stubs",
      "Pattern match failed, no pattern matched the value.",
      {
        value: mock_server,
        start: 2378,
        end: 2440,
        pattern_start: 2389,
        pattern_end: 2426
      }
    )
  }
  return adapter.clear_stubs(handle);
}

export function get_stubs(mock_server) {
  let handle;
  let adapter;
  if (mock_server instanceof MockServerStarted) {
    handle = mock_server.handle;
    adapter = mock_server.adapter;
  } else {
    throw makeError(
      "let_assert",
      FILEPATH,
      "http_server_mock/internal/server",
      86,
      "get_stubs",
      "Pattern match failed, no pattern matched the value.",
      {
        value: mock_server,
        start: 2564,
        end: 2626,
        pattern_start: 2575,
        pattern_end: 2612
      }
    )
  }
  let _pipe = adapter.get_stubs(handle);
  return $json_codec.decode_stubs(_pipe);
}

export function recorded_requests(mock_server) {
  let handle;
  let adapter;
  if (mock_server instanceof MockServerStarted) {
    handle = mock_server.handle;
    adapter = mock_server.adapter;
  } else {
    throw makeError(
      "let_assert",
      FILEPATH,
      "http_server_mock/internal/server",
      94,
      "recorded_requests",
      "Pattern match failed, no pattern matched the value.",
      {
        value: mock_server,
        start: 2796,
        end: 2858,
        pattern_start: 2807,
        pattern_end: 2844
      }
    )
  }
  let _pipe = handle;
  let _pipe$1 = adapter.get_requests(_pipe);
  return $json_codec.decode_recorded_requests(_pipe$1);
}

export function reset_requests(mock_server) {
  let handle;
  let adapter;
  if (mock_server instanceof MockServerStarted) {
    handle = mock_server.handle;
    adapter = mock_server.adapter;
  } else {
    throw makeError(
      "let_assert",
      FILEPATH,
      "http_server_mock/internal/server",
      101,
      "reset_requests",
      "Pattern match failed, no pattern matched the value.",
      {
        value: mock_server,
        start: 3005,
        end: 3067,
        pattern_start: 3016,
        pattern_end: 3053
      }
    )
  }
  return adapter.clear_requests(handle);
}

export function reset(mock_server) {
  let handle;
  let adapter;
  if (mock_server instanceof MockServerStarted) {
    handle = mock_server.handle;
    adapter = mock_server.adapter;
  } else {
    throw makeError(
      "let_assert",
      FILEPATH,
      "http_server_mock/internal/server",
      106,
      "reset",
      "Pattern match failed, no pattern matched the value.",
      {
        value: mock_server,
        start: 3162,
        end: 3224,
        pattern_start: 3173,
        pattern_end: 3210
      }
    )
  }
  adapter.clear_stubs(handle);
  return adapter.clear_requests(handle);
}
