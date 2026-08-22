# Changelog

## 2.0.0 - 2026-08-22

Breaking rewrite in response to [review feedback](https://github.com/gleam-lang/awesome-gleam/pull/259)
on this library's awesome-gleam submission. See the [migration guide](https://github.com/atomfinger/http_server_mock/blob/main/migration-guide/MIGRATION.md)
for a full walkthrough with before/after code for every change below.

### Changed

- Collapsed the public API into a single module, `http_server_mock`. The
  `http_server_mock/matcher`, `http_server_mock/response`,
  `http_server_mock/stub_builder`, `http_server_mock/types`, and
  `http_server_mock/verify` modules are all gone.
- Matchers are now plain `fn(Request(String)) -> Bool` closures written with
  ordinary Gleam (`case`/pattern matching over `gleam/http/request`) instead
  of the `matcher` DSL.
- Responses are now plain `gleam/http/response.Response(String)` values
  instead of the custom `ResponseDefinition`/`ResponseBody` types.
- `http_server_mock.stub(matches, response)` replaces the `stub_builder`
  pipeline. `response` is a fixed value, not a function of the request: see
  the migration guide for why.
- Server lifecycle is now scoped by `use` (`http_server_mock.with_handler`/
  `with_stubs`) instead of explicit `start`/`stop` calls guarded by phantom
  types. `start`/`start_with_stubs`/`stop` remain as a manual escape hatch
  for tests that can't be structured as a `use` block.
- `recorded_requests` is renamed to `received`, and along with
  `unmatched_requests` no longer returns a `Result` - both return a plain
  `List(Request(String))`.
- Recorded requests are now `gleam/http/request.Request(String)` instead of
  the custom `RecordedRequest` type.

### Added

- `http_server_mock.with_handler`, a single-handler entry point for the
  common case of one endpoint with no cross-request state.
- `http_server_mock.received_by(server, stub)`, returning only the requests
  that matched a specific registered stub - pass the exact `Stub` value you
  registered, the same one `remove_stub` expects.

### Removed

- The `verify` module and its panicking assertion helpers (`called`,
  `called_times`, `called_at_least`, `never_called`). `received`/
  `unmatched_requests` return plain data; write your own `assert`s.
- Phantom types (`NotStarted`/`Started`/`Stopped` on `MockServer`; the
  three-parameter phantom typing on the old `StubBuilder`). `MockServer` and
  `Stub` are now plain opaque types.
- `RecordedRequest`'s `timestamp_ms` and `matched_stub_id` fields, judged
  not useful to test writers.
- `with_id`/`with_priority` on stubs, and the `Stub.id`/`Stub.priority`
  fields. `remove_stub` now takes the `Stub` value itself instead of a
  string id. Match order among overlapping stubs is always
  first-registered-wins; there's no priority number to override it.
- Scenarios (`in_scenario`/`when_state_is`/`then_transition_to`), for
  modelling stateful multi-call sequences. This is a deliberate feature cut
  for 2.0.0, not an oversight - it may return in a later release, in
  whatever shape fits best then.
- `response.delay`, for simulating a slow response. No replacement.
- All `/__admin/*` HTTP endpoints (`/__admin/stubs`, `/__admin/requests`,
  `/__admin/health`). Stubs are live closures now, not JSON-representable,
  so there's nothing to introspect over HTTP. Use `add_stub`/`reset_stubs`/
  `received`/`reset_requests` instead.

## 1.0.0 - 2026-05-18

Initial release.
