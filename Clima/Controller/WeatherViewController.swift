
import UIKit
import CoreLocation

class WeatherViewController: UIViewController {
    
    // MARK: - IBOutlets
    @IBOutlet weak var conditionImageView: UIImageView!
    @IBOutlet weak var temperatureLabel: UILabel!
    @IBOutlet weak var cityLabel: UILabel!
    @IBOutlet weak var searchTextField: UITextField!
    
    // MARK: - Properties
    var weatherManager = WeatherManager() // Instance of our custom networking struct
    var locationManager = CLLocationManager() // Apple's object for GPS data
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // 1. Set the delegates first so the managers know who to talk back to
        locationManager.delegate = self
        searchTextField.delegate = self
        weatherManager.delegate = self
        
        // 2. Request permission from the user to access location
        locationManager.requestWhenInUseAuthorization()
        
        // 3. Immediately try to get the current location to show weather on startup
        locationManager.requestLocation()
    }
}

// MARK: - UITextFieldDelegate
// This extension handles everything related to the keyboard and the search bar
extension WeatherViewController: UITextFieldDelegate {
    
    @IBAction func searchPressed(_ sender: UIButton) {
        // Dismisses the keyboard
        searchTextField.endEditing(true)
    }
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        // Triggered when the "Go/Return" button is pressed on the keyboard
        searchTextField.endEditing(true)
        return true
    }
    
    // VALIDATION: Decides if the keyboard should actually close
    func textFieldShouldEndEditing(_ textField: UITextField) -> Bool {
        if textField.text != "" {
            return true // Allow keyboard to close
        } else {
            textField.placeholder = "Type something" // Prompt the user
            return false // Keep keyboard open
        }
    }
    
    // EXECUTION: Triggered once the keyboard is dismissed
    func textFieldDidEndEditing(_ textField: UITextField) {
        if let city = searchTextField.text {
            weatherManager.fetchWeather(city) // Start the API call
        }
        searchTextField.text = "" // Clear the search bar for next time
    }
}

// MARK: - WeatherManagerDelegate
// This extension handles the data coming back from the internet
extension WeatherViewController: WeatherManagerDelegate {
    
    // Triggered when fetchWeather succeeds and returns a WeatherModel
    func didUpdateWeather(_ weatherManager: WeatherManager, weather: WeatherModel) {
        // UI updates MUST happen on the Main Thread to prevent crashes/lag
        DispatchQueue.main.async {
            self.temperatureLabel.text = weather.temperatureString
            self.conditionImageView.image = UIImage(systemName: weather.conditionName)
            self.cityLabel.text = weather.cityName
        }
    }
    
    // Triggered if the API call fails (no internet, wrong city name, etc.)
    func didFailWithError(error: Error) {
        print("Weather Error: \(error)")
    }
}

// MARK: - CLLocationManagerDelegate
// This extension handles GPS data from the phone's hardware
extension WeatherViewController: CLLocationManagerDelegate {
    
    @IBAction func locationPressed(_ sender: UIButton) {
        // Request a fresh one-time location update when GPS button is tapped
        locationManager.requestLocation()
    }
    
    // Triggered when the GPS hardware successfully finds your coordinates
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        // 'locations' is an array; the last item is the most recent/accurate
        if let location = locations.last {
            // Stop searching once found to save battery
            locationManager.stopUpdatingLocation()
            
            let lat = location.coordinate.latitude
            let lon = location.coordinate.longitude
            
            // Pass the coordinates to our WeatherManager to get local weather
            weatherManager.fetchWeather(latitude: lat, longitude: lon)
        }
    }
    
    // Triggered if location fails (e.g., user denied permission or is in a tunnel)
    func locationManager(_ manager: CLLocationManager, didFailWithError error: Error) {
        print("Location Error: \(error)")
    }
}
