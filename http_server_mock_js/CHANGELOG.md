# Changelog

## 2.0.0 - 2026-08-22

Tracks the breaking `http_server_mock` 2.0.0 rewrite. See that package's
[CHANGELOG](https://hexdocs.pm/http_server_mock/changelog.html) and the
[migration guide](https://github.com/atomfinger/http_server_mock/blob/main/migration-guide/MIGRATION.md)
for the full picture.

### Changed

- The runtime was rebuilt from scratch. Stubs are now live Gleam closures,
  which can't cross a `Worker`'s `postMessage` boundary (only
  structured-cloneable data can) - the 1.x design shipped stub data as JSON
  strings, which no longer works once matching is arbitrary Gleam code.
  The Worker thread is now a dumb HTTP transport: it forwards each raw
  request to the main thread, where the real closures live, over an
  ordinary async message channel (no `Atomics`/`SharedArrayBuffer` needed
  for this part). See this package's README for the full design and the
  cooperative-pump requirement it places on hand-rolled synchronous test
  clients.

### Removed

- The `/__admin/*` HTTP endpoints. See the core package's changelog for
  why.

## 1.0.0 - 2026-05-18

Initial release.
