//
//  ViewController.swift
//  WeatherApp
//
//  Created by Dinura Wijayarathne on 2022-04-03.
//

import UIKit
import CoreLocation

struct WeatherResponse: Decodable {
    let location: Location;
    let current: Weather;
}

struct Location: Decodable {
    let name: String;
}

struct Weather: Decodable {
    let temp_c: Float;
    let condition: WeatherCondition;
}

struct WeatherCondition: Decodable {
    let text: String;
    let code: Int;
}

class ViewController: UIViewController, UITextFieldDelegate {
    
    @IBOutlet weak var weatherImage: UIImageView!
    @IBOutlet weak var temeratureLabel: UILabel!
    @IBOutlet weak var locationLabel: UILabel!
    @IBOutlet weak var searchTextField: UITextField!
    @IBOutlet weak var conditionLabel: UILabel!
    
    let locationManager = CLLocationManager()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        searchTextField.delegate = self;
        locationManager.delegate = self;
        
        let config = UIImage.SymbolConfiguration(paletteColors: [.systemGray2, .systemYellow, .systemGray]);
        weatherImage.preferredSymbolConfiguration = config;
        weatherImage.image = UIImage(systemName: "cloud.moon.fill");
    }
    
    @IBAction func onGetLocationTapped(_ sender: UIButton) {
        locationManager.requestWhenInUseAuthorization();
        locationManager.requestLocation();
    }
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        textField.endEditing(true);
        getWeather(search: textField.text);
        return true;
    }

    @IBAction func onSearchTapped(_ sender: UIButton) {
        searchTextField.endEditing(true);
        getWeather(search: searchTextField.text);
    }
    
    private func getWeather(search: String?) {
        guard let search = search else {
            return
        }
        
        let url = getUrl(search: search);
        
        guard let url = url else {
            print("could not get URL");
            return
        }
        
        let session = URLSession.shared;
        
        let dataTask = session.dataTask(with: url) { data, response, error in
            print("network call complete");
            
            guard error == nil else {
                print("recieved error");
                return
            }
            
            guard let data = data else {
                print("No data found");
                return
            }
            
            if let weather = self.parseJson(data: data) {
                DispatchQueue.main.async {
                    self.locationLabel.text = weather.location.name;
                    self.temeratureLabel.text = "\(weather.current.temp_c)C";
                    self.conditionLabel.text = "\(weather.current.condition.text)";
                    self.weatherImage.image = UIImage(systemName: self.getSymbolImage(conditionCode: weather.current.condition.code));
                }
            }
        }
        
        dataTask.resume();
    }
    
    private func parseJson(data: Data) -> WeatherResponse? {
        let decoder = JSONDecoder()
        var weatherResponse: WeatherResponse?
        
        do {
            weatherResponse = try decoder.decode(WeatherResponse.self, from: data);
        } catch {
            print("Error parsing weather data");
            print(error);
        }
        
        return weatherResponse;
    }
    
    private func getUrl(search: String) -> URL? {
        let baseUrl = "https://api.weatherapi.com/v1/";
        let currentEndpoint = "current.json";
        let apikey = "e1bb29e804d34ef2837135733220404";
        
        let url = "\(baseUrl)\(currentEndpoint)?key=\(apikey)&q=\(search)";
        return URL(string: url);
    }
    
    private func getSymbolImage(conditionCode: Int) -> String {
        var symbolName: String = "cloud.moon.fill";
        switch conditionCode {
        case 1000:
            symbolName = "sun.max.fill";
            break;
        case 1003:
            symbolName = "cloud.sun.fill";
            break;
        case 1006, 1009:
            symbolName = "cloud.fill";
            break;
        case 1150, 1153, 1168, 1072:
            symbolName = "cloud.drizzle.fill";
            break;
        case 1063, 1180, 1183, 1186, 1189, 1198:
            symbolName = "cloud.rain.fill";
            break;
        case 1192, 1195, 1201:
            symbolName = "cloud.heavyrain.fill";
            break;
        case 1135, 1147:
            symbolName = "cloud.fog.fill";
            break;
        case 1069, 1204, 1207, 1249, 1252:
            symbolName = "cloud.sleet.fill";
            break;
        case 1066, 1210, 1213, 1216, 1219, 1222, 1225, 1255, 1258:
            symbolName = "cloud.snow.fill";
            break;
        case 1114:
            symbolName = "wind.snow";
            break;
        case 1087, 1273, 1276:
            symbolName = "cloud.bolt.rain.fill";
            break;
        case 1279, 1282:
            symbolName = "cloud.bolt.fill";
            break;
        default:
            symbolName = "cloud.moon.fill";
        }
        
        return symbolName;
    }
}

extension ViewController: CLLocationManagerDelegate {
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        print("Got Location")
        
        if let location = locations.last {
            let latitude = location.coordinate.latitude;
            let longitude = location.coordinate.longitude;
            print("lat: \(latitude), long: \(longitude)")
            getWeather(search: "\(latitude),\(longitude)");
        }
    }
    
    func locationManager(_ manager: CLLocationManager, didFailWithError error: Error) {
        print(error);
    }
}



