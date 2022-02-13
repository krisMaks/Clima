//
//  WeatherManager.swift
//  Clima
//
//  Created by Кристина Максимова on 05.02.2022.
//  Copyright © 2022 App Brewery. All rights reserved.
//

import Foundation
import CoreLocation

protocol WeatherManagerDelegate {
    func didUpdateWeather(_ weatherManager: WeatherManager, weather: WeatherModel)
    func didFailWithError(error: Error)
}


struct WeatherManager {
    let weatherURL = "https://api.openweathermap.org/data/2.5/weather?units=metric&appid=20d32504dce81b878028d5c8d1655c33"
    var delegate: WeatherManagerDelegate?
    
    func fetchWeather(cityName: String) {
        let urlString = "\(weatherURL)&q=\(cityName)"
        performRequest(with: urlString)
    }
    
    func fetchWeather(lat: CLLocationDegrees, lon: CLLocationDegrees) {
        let urlString = "\(weatherURL)&lat=\(lat)&lon=\(lon)"
        performRequest(with: urlString)
    }
    
    func performRequest(with urlString: String) {
        guard let url = URL(string: urlString) else { return }
        let session = URLSession(configuration: .default)
        let task = session.dataTask(with: url) { data, response, error in
            if error != nil {
                delegate?.didFailWithError(error: error!)
                return
            }
            guard let data = data else { return }
            guard let weatherModel = parseJSON(data) else { return }
            delegate?.didUpdateWeather(self, weather: weatherModel)
        }
        task.resume()
    }
    
    func parseJSON(_ data: Data) -> WeatherModel? {
        let decoder = JSONDecoder()
        do {
            let decode = try decoder.decode(WeatherData.self, from: data)
            let id = decode.weather[0].id
            let name = decode.name
            let temp = decode.main.temp
            let weather = WeatherModel(conditionId: id, cityName: name, temperature: temp)
            return weather
        } catch {
            delegate?.didFailWithError(error: error)
            return nil
        }
    }
}
