//
//  APIManager.swift
//  Weather
//
//  Created by SC on 2022/08/14.
//

import Foundation

import Alamofire
import SwiftyJSON


class APIManager {
    static let shared = APIManager()
    
    private init() { }
    
    
    func fetchCurrentWeather(lat: Double, lon: Double, completion: @escaping (JSON) -> ()) {
        let url = Endpoint.getCurrentWeatherURL(lat: lat, lon: lon)
        
        AF.request(url).validate(statusCode: 200...400).responseData { response in
            switch response.result {
                case .success(let value):
                    let json = JSON(value)
                    print(json)
                    print(type(of: json))
                    
                    completion(json)
                case.failure(let error):
                    print(error)
            }
        }
    }
}
