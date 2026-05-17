import gleam/result
import http_server_mock/json_codec
import http_server_mock/types.{type Stub}
import simplifile

pub fn save_stubs(path: String, stubs: List(Stub)) -> Result(Nil, String) {
  let json = json_codec.encode_stubs(stubs)
  simplifile.write(to: path, contents: json)
  |> result.map_error(simplifile.describe_error)
}

pub fn load_stubs(path: String) -> Result(List(Stub), String) {
  simplifile.read(from: path)
  |> result.map_error(simplifile.describe_error)
  |> result.try(json_codec.decode_stubs)
}
