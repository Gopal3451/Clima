
import Foundation

// MARK: - WeatherModel
// This struct stores the final, clean data that the View Controller uses to update the UI.
struct WeatherModel {
    let conditionId: Int
    let cityName: String
    let temperature: Double
    
    // MARK: - Computed Properties
    
    // 1. Converts the Double (e.g., 25.342) into a formatted String (e.g., "25.3")
    // The "%.1f" means "format as a float with 1 decimal place"
    var temperatureString: String {
        return String(format: "%.1f", temperature)
    }
    
    // 2. Maps the OpenWeatherMap ID to an Apple "SF Symbol" name
    // This allows the View Controller to simply call weather.conditionName
    // to get the correct icon name for a UIImageView.
    var conditionName: String {
        switch conditionId {
        case 200...232:
            return "cloud.bolt"
        case 300...321:
            return "cloud.drizzle"
        case 500...531:
            return "cloud.rain"
        case 600...622:
            return "cloud.snow"
        case 701...781:
            return "cloud.fog"
        case 800:
            return "sun.max"
        case 801...804:
            return "cloud.bolt"
        default:
            return "cloud"
        }
    }
}
