# failing_tests

An example that deliberately fails every test, to show what a failing
`http_server_mock`-based assertion looks like in 2.0.0.

2.0.0 removed the `verify` module (it used to panic with a custom message on
failure). Instead, `http_server_mock.received(server)` returns a plain
`List(Request(String))`, and you write your own `assert` against it -
Gleam's built-in `assert` gives you a clear `left`/`right` diff on failure
without any library help needed. Each test here is a common mistake
(forgetting to call an endpoint, calling it the wrong number of times,
calling one you shouldn't have, using the wrong HTTP method) paired with the
assertion that catches it.

## Development

```sh
gleam test  # every test in here fails on purpose - that's the point
```
