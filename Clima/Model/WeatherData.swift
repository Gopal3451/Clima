
import Foundation

// MARK: - WeatherData
// The top-level object representing the entire JSON response from the API.
struct WeatherData: Codable {
    let name: String      // The name of the city (e.g., "London")
    let main: Main        // A nested object containing temperature data
    let weather: [Weather] // An array of weather descriptions (rain, clouds, etc.)
}

// MARK: - Main
// This matches the "main" key in the JSON.
struct Main: Codable {
    let temp: Double      // The actual numerical temperature (Kelvin by default)
}

// MARK: - Weather
// This matches the objects inside the "weather" array in the JSON.
struct Weather: Codable {
    let description: String // A short text description (e.g., "light rain")
    let id: Int             // The Condition ID (used to determine the SF Symbol icon)
}



