import gleam/dynamic/decode
import gleam/http/request
import gleam/httpc
import gleam/json
import gleam/result
import gleam/string

pub type Repo {
  Repo(name: String, full_name: String, stars: Int, open_issues: Int)
}

pub type GitHubError {
  NotFound
  RateLimited
  ServerError(status: Int)
  RequestFailed(String)
}

pub fn get_repo(
  base_url: String,
  owner: String,
  name: String,
) -> Result(Repo, GitHubError) {
  use req <- result.try(
    request.to(base_url <> "/repos/" <> owner <> "/" <> name)
    |> result.map_error(fn(_) { RequestFailed("invalid url") }),
  )
  let req =
    req
    |> request.set_header("accept", "application/vnd.github+json")
    |> request.set_header("x-github-api-version", "2022-11-28")
  use resp <- result.try(
    httpc.send(req)
    |> result.map_error(fn(err) {
      RequestFailed("connection failed: " <> string.inspect(err))
    }),
  )
  case resp.status {
    200 ->
      decode_repo(resp.body)
      |> result.map_error(RequestFailed)
    403 -> Error(RateLimited)
    404 -> Error(NotFound)
    _ -> Error(ServerError(resp.status))
  }
}

fn decode_repo(body: String) -> Result(Repo, String) {
  let decoder = {
    use name <- decode.field("name", decode.string)
    use full_name <- decode.field("full_name", decode.string)
    use stars <- decode.field("stargazers_count", decode.int)
    use open_issues <- decode.field("open_issues_count", decode.int)
    decode.success(Repo(
      name: name,
      full_name: full_name,
      stars: stars,
      open_issues: open_issues,
    ))
  }
  json.parse(from: body, using: decoder)
  |> result.map_error(fn(_) { "failed to decode GitHub response" })
}
