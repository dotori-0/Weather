//
//  Endpoint.swift
//  Weather
//
//  Created by SC on 2022/08/14.
//

import Foundation

struct Endpoint {
    static let currentWeatherBaseURL = "https://api.openweathermap.org/data/2.5/weather?"
    // https://api.openweathermap.org/data/2.5/weather?lat={lat}&lon={lon}&appid={API key}
    
    static func getCurrentWeatherURL(lat: Double, lon: Double) -> String {
        let url = "\(currentWeatherBaseURL)lat=\(lat)&lon=\(lon)&appid=\(APIKey.OpenWeather)"
        
        return url
    }
}
