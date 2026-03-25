
import Foundation
import CoreLocation

// MARK: - WeatherManagerDelegate Protocol
// The "contract" that any class must sign if it wants to receive weather updates.
protocol WeatherManagerDelegate {
    func didUpdateWeather(_ weatherManager: WeatherManager, weather: WeatherModel)
    func didFailWithError(error: Error)
}

struct WeatherManager {
    
    // The delegate is optional because the manager can exist without anyone listening to it.
    var delegate: WeatherManagerDelegate?
    
    let weatherURL = "https://api.openweathermap.org/data/2.5/weather?appid=8cda170f271f5450365dbed0c787ad43&units=metric"
    
    // MARK: - Fetching Methods (Overloading)
    
    // Fetch by City Name (triggered by the Search Bar)
    func fetchWeather(_ cityName: String) {
        let urlString = "\(weatherURL)&q=\(cityName)"
        performRequest(with: urlString)
    }
    
    // Fetch by Coordinates (triggered by the GPS button)
    func fetchWeather(latitude: CLLocationDegrees, longitude: CLLocationDegrees) {
        let urlString = "\(weatherURL)&lat=\(latitude)&lon=\(longitude)"
        performRequest(with: urlString)
    }
    
    // MARK: - Networking Logic
    
    func performRequest(with urlString: String) {
        // 1. Create a URL object (safely unwrapped)
        if let url = URL(string: urlString) {
            
            // 2. Create a URLSession (the "browser" that does the work)
            let session = URLSession(configuration: .default)
            
            // 3. Give the session a task.
            // This uses a "Trailing Closure" { data, response, error in ... }
            // This code runs in the BACKGROUND, not on the main thread.
            let task = session.dataTask(with: url) { data, response, error in
                
                // If there's a networking error (like no Wi-Fi)
                if error != nil {
                    self.delegate?.didFailWithError(error: error!)
                    return // Exit the closure
                }
                
                // If we successfully got data back
                if let safeData = data {
                    // Try to parse the raw JSON into our WeatherModel
                    if let weather = self.parseJSON(safeData) {
                        // Send the clean model back to the delegate (ViewController)
                        self.delegate?.didUpdateWeather(self, weather: weather)
                    }
                }
            }
            
            // 4. Start the task (Tasks start in a "suspended" state by default)
            task.resume()
        }
    }
    
    // MARK: - JSON Parsing
    
    func parseJSON(_ weatherData: Data) -> WeatherModel? {
        let decoder = JSONDecoder()
        do {
            // Decode raw data using the WeatherData struct template
            let decodedData = try decoder.decode(WeatherData.self, from: weatherData)
            
            // Extract the specific pieces of info we need
            let id = decodedData.weather[0].id
            let temp = decodedData.main.temp
            let name = decodedData.name
            
            // Initialize our UI-friendly WeatherModel
            let weather = WeatherModel(conditionId: id, cityName: name, temperature: temp)
            return weather
            
        } catch {
            // If the JSON format doesn't match our struct (Decoding Error)
            delegate?.didFailWithError(error: error)
            return nil
        }
    }
}
