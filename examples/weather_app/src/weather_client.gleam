import gleam/dynamic/decode
import gleam/json
import gleam/result

pub type CurrentWeather {
  CurrentWeather(
    city: String,
    temperature_celsius: Float,
    description: String,
    humidity_percent: Int,
  )
}

pub type WeatherError {
  CityNotFound
  ServiceUnavailable
  ParseError(String)
}

pub fn get_current_weather(
  base_url: String,
  city: String,
) -> Result(CurrentWeather, WeatherError) {
  let resp = do_get(base_url <> "/weather/" <> city)
  case resp.status {
    200 ->
      decode_weather(city, resp.body)
      |> result.map_error(ParseError)
    404 -> Error(CityNotFound)
    _ -> Error(ServiceUnavailable)
  }
}

fn decode_weather(city: String, body: String) -> Result(CurrentWeather, String) {
  let decoder = {
    use temperature <- decode.field("temperature", decode.float)
    use description <- decode.field("description", decode.string)
    use humidity <- decode.field("humidity", decode.int)
    decode.success(CurrentWeather(
      city: city,
      temperature_celsius: temperature,
      description: description,
      humidity_percent: humidity,
    ))
  }
  json.parse(from: body, using: decoder)
  |> result.map_error(fn(_) { "unexpected response format" })
}

type HttpResponse {
  HttpResponse(status: Int, body: String)
}

@external(javascript, "./http_ffi.mjs", "syncGet")
fn do_get(_url: String) -> HttpResponse {
  HttpResponse(status: 0, body: "")
}
