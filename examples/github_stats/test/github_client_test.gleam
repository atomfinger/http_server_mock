import github_client
import gleam/http/request
import gleam/http/response
import gleam/json
import gleam/list
import gleeunit/should
import http_server_mock
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

fn config() -> http_server_mock.Config {
  http_server_mock.new(http_server_mock_erlang.server())
}

pub fn get_repo_returns_parsed_repo_on_200_test() {
  use server <- http_server_mock.with_stubs(config(), [
    http_server_mock.stub(
      fn(req) { req.path == "/repos/gleam-lang/gleam" },
      response.new(200)
        |> response.set_header("content-type", "application/json")
        |> response.set_body(repo_json("gleam", "gleam-lang/gleam", 4200, 88)),
    ),
  ])

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
}

pub fn get_repo_returns_not_found_on_404_test() {
  use server <- http_server_mock.with_stubs(config(), [
    http_server_mock.stub(
      fn(req) { req.path == "/repos/nobody/nothing" },
      response.new(404),
    ),
  ])

  github_client.get_repo(http_server_mock.base_url(server), "nobody", "nothing")
  |> should.equal(Error(github_client.NotFound))
}

pub fn get_repo_returns_server_error_on_500_test() {
  use server <- http_server_mock.with_stubs(config(), [
    http_server_mock.stub(
      fn(req) { req.path == "/repos/gleam-lang/gleam" },
      response.new(500),
    ),
  ])

  github_client.get_repo(
    http_server_mock.base_url(server),
    "gleam-lang",
    "gleam",
  )
  |> should.equal(Error(github_client.ServerError(500)))
}

pub fn get_repo_sends_github_accept_header_test() {
  use server <- http_server_mock.with_stubs(config(), [
    http_server_mock.stub(
      fn(req) {
        case req.path, request.get_header(req, "accept") {
          "/repos/gleam-lang/gleam", Ok("application/vnd.github+json") -> True
          _, _ -> False
        }
      },
      response.new(200)
        |> response.set_header("content-type", "application/json")
        |> response.set_body(repo_json("gleam", "gleam-lang/gleam", 0, 0)),
    ),
  ])

  // If the Accept header is absent the stub won't match and we'd get an error
  github_client.get_repo(
    http_server_mock.base_url(server),
    "gleam-lang",
    "gleam",
  )
  |> should.be_ok()
}

pub fn get_repo_records_each_call_test() {
  use server <- http_server_mock.with_stubs(config(), [
    http_server_mock.stub(
      fn(req) { req.path == "/repos/gleam-lang/gleam" },
      response.new(200)
        |> response.set_header("content-type", "application/json")
        |> response.set_body(repo_json("gleam", "gleam-lang/gleam", 0, 0)),
    ),
  ])

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

  let calls =
    list.filter(http_server_mock.received(server), fn(req) {
      req.path == "/repos/gleam-lang/gleam"
    })
  assert list.length(calls) == 3
}
