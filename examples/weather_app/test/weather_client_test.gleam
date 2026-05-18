import gleam/json
import gleeunit/should
import http_server_mock
import http_server_mock/matcher
import http_server_mock/response
import http_server_mock/stub_builder
import http_server_mock/verify
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

pub fn get_current_weather_returns_parsed_weather_test() {
  let server =
    http_server_mock.new(http_server_mock_js.server())
    |> http_server_mock.start()
    |> http_server_mock.with_stub(
      stub_builder.new()
      |> stub_builder.matching(
        matcher.new() |> matcher.path("/weather/London"),
      )
      |> stub_builder.responding_with(
        response.ok()
        |> response.json_body(weather_json(12.5, "Partly cloudy", 80)),
      )
      |> stub_builder.build(),
    )

  let assert Ok(weather) =
    weather_client.get_current_weather(
      http_server_mock.base_url(server),
      "London",
    )

  weather.city |> should.equal("London")
  weather.temperature_celsius |> should.equal(12.5)
  weather.description |> should.equal("Partly cloudy")
  weather.humidity_percent |> should.equal(80)

  http_server_mock.stop(server)
}

pub fn get_current_weather_returns_city_not_found_on_404_test() {
  let server =
    http_server_mock.new(http_server_mock_js.server())
    |> http_server_mock.start()
    |> http_server_mock.with_stub(
      stub_builder.new()
      |> stub_builder.matching(
        matcher.new() |> matcher.path("/weather/Atlantis"),
      )
      |> stub_builder.responding_with(response.not_found())
      |> stub_builder.build(),
    )

  weather_client.get_current_weather(
    http_server_mock.base_url(server),
    "Atlantis",
  )
  |> should.equal(Error(weather_client.CityNotFound))

  http_server_mock.stop(server)
}

pub fn get_current_weather_returns_unavailable_on_500_test() {
  let server =
    http_server_mock.new(http_server_mock_js.server())
    |> http_server_mock.start()
    |> http_server_mock.with_stub(
      stub_builder.new()
      |> stub_builder.matching(
        matcher.new() |> matcher.path("/weather/London"),
      )
      |> stub_builder.responding_with(response.server_error())
      |> stub_builder.build(),
    )

  weather_client.get_current_weather(
    http_server_mock.base_url(server),
    "London",
  )
  |> should.equal(Error(weather_client.ServiceUnavailable))

  http_server_mock.stop(server)
}

pub fn get_current_weather_records_each_call_test() {
  let server =
    http_server_mock.new(http_server_mock_js.server())
    |> http_server_mock.start()
    |> http_server_mock.with_stub(
      stub_builder.new()
      |> stub_builder.matching(
        matcher.new() |> matcher.path("/weather/London"),
      )
      |> stub_builder.responding_with(
        response.ok()
        |> response.json_body(weather_json(15.0, "Sunny", 65)),
      )
      |> stub_builder.build(),
    )

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

  verify.called_times(
    server,
    matcher.new() |> matcher.path("/weather/London"),
    2,
  )

  http_server_mock.stop(server)
}
