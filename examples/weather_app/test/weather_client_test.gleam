import gleam/http/response
import gleam/json
import gleam/list
import gleeunit/should
import http_server_mock
import http_server_mock_js
import weather_client

fn weather_json(
  temperature: Float,
  description: String,
  humidity: Int,
) -> String {
  json.object([
    #("temperature", json.float(temperature)),
    #("description", json.string(description)),
    #("humidity", json.int(humidity)),
  ])
  |> json.to_string
}

fn config() -> http_server_mock.Config {
  http_server_mock.new(http_server_mock_js.server())
}

pub fn get_current_weather_returns_parsed_weather_test() {
  use server <- http_server_mock.with_stubs(config(), [
    http_server_mock.stub(
      fn(req) { req.path == "/weather/London" },
      response.new(200)
        |> response.set_header("content-type", "application/json")
        |> response.set_body(weather_json(12.5, "Partly cloudy", 80)),
    ),
  ])

  let assert Ok(weather) =
    weather_client.get_current_weather(
      http_server_mock.base_url(server),
      "London",
    )

  weather.city |> should.equal("London")
  weather.temperature_celsius |> should.equal(12.5)
  weather.description |> should.equal("Partly cloudy")
  weather.humidity_percent |> should.equal(80)
}

pub fn get_current_weather_returns_city_not_found_on_404_test() {
  use server <- http_server_mock.with_stubs(config(), [
    http_server_mock.stub(
      fn(req) { req.path == "/weather/Atlantis" },
      response.new(404),
    ),
  ])

  weather_client.get_current_weather(
    http_server_mock.base_url(server),
    "Atlantis",
  )
  |> should.equal(Error(weather_client.CityNotFound))
}

pub fn get_current_weather_returns_unavailable_on_500_test() {
  use server <- http_server_mock.with_stubs(config(), [
    http_server_mock.stub(
      fn(req) { req.path == "/weather/London" },
      response.new(500),
    ),
  ])

  weather_client.get_current_weather(
    http_server_mock.base_url(server),
    "London",
  )
  |> should.equal(Error(weather_client.ServiceUnavailable))
}

pub fn get_current_weather_records_each_call_test() {
  use server <- http_server_mock.with_stubs(config(), [
    http_server_mock.stub(
      fn(req) { req.path == "/weather/London" },
      response.new(200)
        |> response.set_header("content-type", "application/json")
        |> response.set_body(weather_json(15.0, "Sunny", 65)),
    ),
  ])

  let _ =
    weather_client.get_current_weather(
      http_server_mock.base_url(server),
      "London",
    )
  let _ =
    weather_client.get_current_weather(
      http_server_mock.base_url(server),
      "London",
    )

  let calls =
    list.filter(http_server_mock.received(server), fn(req) {
      req.path == "/weather/London"
    })
  assert list.length(calls) == 2
}
