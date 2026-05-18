import github_client
import gleam/int
import gleam/io

pub fn main() {
  case github_client.get_repo("https://api.github.com", "gleam-lang", "gleam") {
    Ok(repo) ->
      io.println(
        repo.full_name <> " — " <> int.to_string(repo.stars) <> " stars",
      )
    Error(_) -> io.println("Failed to fetch repo info")
  }
}
