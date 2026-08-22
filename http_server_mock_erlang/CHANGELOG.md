# Changelog

## 2.0.0 - 2026-08-22

Tracks the breaking `http_server_mock` 2.0.0 rewrite. See that package's
[CHANGELOG](https://hexdocs.pm/http_server_mock/changelog.html) and the
[migration guide](https://github.com/atomfinger/http_server_mock/blob/main/migration-guide/MIGRATION.md)
for the full picture.

### Changed

- Stubs are now stored as live Gleam closures directly in the OTP actor's
  state, since they can no longer be JSON-encoded (matching is now
  arbitrary Gleam code, not serializable matcher data). The actor and the
  test process run on the same node, so this needs no serialization step -
  it's simpler than the 1.x JSON-over-the-actor design, not more complex.

### Fixed

- `start`/`start_with_stubs` now return a clean `Error` when the requested
  port is already in use, instead of crashing the calling process's
  supervision tree. `mist.start` links its supervisor to the caller, so a
  startup failure previously arrived as a hard exit signal rather than
  through the function's `Result`.

### Removed

- The `/__admin/*` HTTP endpoints (`/__admin/stubs`, `/__admin/requests`,
  `/__admin/health`). See the core package's changelog for why.

## 1.0.0 - 2026-05-18

Initial release.
