import github_client
import gleam/json
import gleeunit/should
import http_server_mock
import http_server_mock/matcher
import http_server_mock/response
import http_server_mock/stub_builder
import http_server_mock/verify
import http_server_mock_erlang

fn repo_json(
  name: String,
  full_name: String,
  stars: Int,
  open_issues: Int,
) -> String {
  json.object([
    #("name", json.string(name)),
    #("full_name", json.string(full_name)),
    #("stargazers_count", json.int(stars)),
    #("open_issues_count", json.int(open_issues)),
  ])
  |> json.to_string
}

pub fn get_repo_returns_parsed_repo_on_200_test() {
  let server =
    http_server_mock.new(http_server_mock_erlang.server())
    |> http_server_mock.start()
    |> http_server_mock.with_stub(
      stub_builder.new()
      |> stub_builder.matching(
        matcher.new() |> matcher.path("/repos/gleam-lang/gleam"),
      )
      |> stub_builder.responding_with(
        response.ok()
        |> response.json_body(repo_json("gleam", "gleam-lang/gleam", 4200, 88)),
      )
      |> stub_builder.build(),
    )

  let assert Ok(repo) =
    github_client.get_repo(
      http_server_mock.base_url(server),
      "gleam-lang",
      "gleam",
    )

  repo.name |> should.equal("gleam")
  repo.full_name |> should.equal("gleam-lang/gleam")
  repo.stars |> should.equal(4200)
  repo.open_issues |> should.equal(88)

  http_server_mock.stop(server)
}

pub fn get_repo_returns_not_found_on_404_test() {
  let server =
    http_server_mock.new(http_server_mock_erlang.server())
    |> http_server_mock.start()
    |> http_server_mock.with_stub(
      stub_builder.new()
      |> stub_builder.matching(
        matcher.new() |> matcher.path("/repos/nobody/nothing"),
      )
      |> stub_builder.responding_with(response.not_found())
      |> stub_builder.build(),
    )

  github_client.get_repo(http_server_mock.base_url(server), "nobody", "nothing")
  |> should.equal(Error(github_client.NotFound))

  http_server_mock.stop(server)
}

pub fn get_repo_returns_server_error_on_500_test() {
  let server =
    http_server_mock.new(http_server_mock_erlang.server())
    |> http_server_mock.start()
    |> http_server_mock.with_stub(
      stub_builder.new()
      |> stub_builder.matching(
        matcher.new() |> matcher.path("/repos/gleam-lang/gleam"),
      )
      |> stub_builder.responding_with(response.server_error())
      |> stub_builder.build(),
    )

  github_client.get_repo(
    http_server_mock.base_url(server),
    "gleam-lang",
    "gleam",
  )
  |> should.equal(Error(github_client.ServerError(500)))

  http_server_mock.stop(server)
}

pub fn get_repo_sends_github_accept_header_test() {
  let server =
    http_server_mock.new(http_server_mock_erlang.server())
    |> http_server_mock.start()
    |> http_server_mock.with_stub(
      stub_builder.new()
      |> stub_builder.matching(
        matcher.new()
        |> matcher.path("/repos/gleam-lang/gleam")
        |> matcher.header("accept", "application/vnd.github+json"),
      )
      |> stub_builder.responding_with(
        response.ok()
        |> response.json_body(repo_json("gleam", "gleam-lang/gleam", 0, 0)),
      )
      |> stub_builder.build(),
    )

  // If the Accept header is absent the stub won't match and we'd get an error
  github_client.get_repo(
    http_server_mock.base_url(server),
    "gleam-lang",
    "gleam",
  )
  |> should.be_ok()

  http_server_mock.stop(server)
}

pub fn get_repo_records_each_call_test() {
  let server =
    http_server_mock.new(http_server_mock_erlang.server())
    |> http_server_mock.start()
    |> http_server_mock.with_stub(
      stub_builder.new()
      |> stub_builder.matching(
        matcher.new() |> matcher.path("/repos/gleam-lang/gleam"),
      )
      |> stub_builder.responding_with(
        response.ok()
        |> response.json_body(repo_json("gleam", "gleam-lang/gleam", 0, 0)),
      )
      |> stub_builder.build(),
    )

  let _ =
    github_client.get_repo(
      http_server_mock.base_url(server),
      "gleam-lang",
      "gleam",
    )
  let _ =
    github_client.get_repo(
      http_server_mock.base_url(server),
      "gleam-lang",
      "gleam",
    )
  let _ =
    github_client.get_repo(
      http_server_mock.base_url(server),
      "gleam-lang",
      "gleam",
    )

  verify.called_times(
    server,
    matcher.new() |> matcher.path("/repos/gleam-lang/gleam"),
    3,
  )

  http_server_mock.stop(server)
}
