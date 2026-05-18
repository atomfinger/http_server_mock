import gleam/float
import gleam/int
import gleam/io
import weather_client

pub fn main() {
  case weather_client.get_current_weather("https://api.weather.example", "London") {
    Ok(weather) ->
      io.println(
        weather.city
        <> ": "
        <> float.to_string(weather.temperature_celsius)
        <> "°C — "
        <> weather.description
        <> ", humidity "
        <> int.to_string(weather.humidity_percent)
        <> "%",
      )
    Error(_) -> io.println("Failed to fetch weather")
  }
}
