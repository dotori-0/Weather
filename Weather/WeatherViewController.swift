//
//  WeatherViewController.swift
//  Weather
//
//  Created by SC on 2022/08/14.
//

import MapKit
import UIKit


import SwiftyJSON


class WeatherViewController: UIViewController {
    
    @IBOutlet weak var iconImageView: UIImageView!
    @IBOutlet weak var temperatureLabel: UILabel!
    @IBOutlet weak var weatherLabel: UILabel!
    @IBOutlet weak var feelsLikeLabel: UILabel!
    @IBOutlet weak var humidityLabel: UILabel!
    @IBOutlet weak var windSpeedLabel: UILabel!
    
    var weather = ""
    var temperature = ""
    var apparentTemperature = ""
    var humidity = ""
    var windSpeed = ""
    
    let locationManager = CLLocationManager()
    

    override func viewDidLoad() {
        super.viewDidLoad()

        locationManager.delegate = self
        
        designLabels()
    }
    
    func designLabels() {
        temperatureLabel.textAlignment = .center
        temperatureLabel.font = .boldSystemFont(ofSize: 32)
        weatherLabel.textAlignment = .center
        weatherLabel.font = .boldSystemFont(ofSize: 32)
    }
    
    
    func setLabels() {
        temperatureLabel.text = temperature
        weatherLabel.text = weather
        feelsLikeLabel.text = "체감온도: \(apparentTemperature)"
        humidityLabel.text = "습도: \(humidity)"
        windSpeedLabel.text = "풍속: \(windSpeed)"
    }
    
    
    func setImage(id: Int) {
        print(#function, id)
        let image: UIImage
        
        switch id {
            case 200...232: image = UIImage.image_200_232 ?? UIImage.image_801!  // Thunderstorm
            case 300...321: image = UIImage.image_300_321 ?? UIImage.image_801!  // Drizzle
            case 511, 615...616: image = UIImage.image_511_615_616 ?? UIImage.image_801!  // Freezing Rain, or Rain and Snow
            case 500...531: image = UIImage.image_500_531 ?? UIImage.image_801!  // Rain
            case 600...622: image = UIImage.image_600_622 ?? UIImage.image_801!  // Snow
            case 701...721: image = UIImage.image_701_721 ?? UIImage.image_801!  // Mist, Smoke, Haze
            case 731...762: image = UIImage.image_731_762 ?? UIImage.image_801!  // Dust, Fog, Sand, Dust, Ash
            case 771...781: image = UIImage.image_771_781 ?? UIImage.image_801!  // Squall, Tornado
            case 800: image = UIImage.image_800 ?? UIImage.image_801!            // Clear
            case 801: image = UIImage.image_801!                                 // Clouds(few)
            case 802: image = UIImage.image_802 ?? UIImage.image_801!            // Clouds(scattered)
            case 803...804: image = UIImage.image_803_804 ?? UIImage.image_801!  // Clouds(broken, overcast)
            default: return
        }
        
        iconImageView.image = image
    }
    
    
    func requestWeather(lat: Double, lon: Double) {
        APIManager.shared.fetchCurrentWeather(lat: lat, lon: lon) { json in
            self.parseData(json)
        }
    }
    
    
    func parseData(_ json: JSON) {
        var weather = json["weather"][0]["main"].stringValue
        weather.translate()
        self.weather = weather
        
//        let temperature = json["main"]["temp"].doubleValue
        let temperature = Measurement(value: json["main"]["temp"].doubleValue, unit: UnitTemperature.kelvin)
        print(temperature)
        
        let formatter = MeasurementFormatter()
        formatter.unitStyle = .short
        formatter.locale = Locale.current  // A locale representing the user's region settings at the time the property is read.
        // ex. 아이폰 설정에서 지역을 독일로 설정하면 25,88° 와 같이 나옴
        let temperatureFormatted = formatter.string(from: temperature)
        print(temperatureFormatted)
        print(formatter.string(from: UnitTemperature.kelvin))
        self.temperature = temperatureFormatted
        
        humidity = "\(json["main"]["humidity"].intValue)%"
        
        let apparentTemperature = Measurement(value: json["main"]["feels_like"].doubleValue, unit: UnitTemperature.kelvin)
        let apparentTemperatureFormatted = formatter.string(from: apparentTemperature)
        self.apparentTemperature = apparentTemperatureFormatted
        
        let windSpeed = Measurement(value: json["wind"]["speed"].doubleValue, unit: UnitSpeed.metersPerSecond)
//        print("windSpeed: \(windSpeed)")  // 3.6 m/s
        print(type(of: windSpeed))  // Measurement<NSUnitSpeed>
//        let windSpeedFormatted = formatter.string(from: windSpeed)
//        print("windSpeedFormatted: \(windSpeedFormatted)")
        self.windSpeed = "\(windSpeed)"
        
        let id = json["weather"][0]["id"].intValue
        
        setLabels()
        setImage(id: id)
    }
}


// 위치 관련 메서드
extension WeatherViewController {
    // iOS 위치 서비스 활성화 여부 확인
    func checkUserDeviceLocationService() {
        let authorizationStatus: CLAuthorizationStatus
        
        if #available(iOS 14.0, *) {
            authorizationStatus = locationManager.authorizationStatus
            print(#function, authorizationStatus.rawValue)
        } else {
            authorizationStatus = CLLocationManager.authorizationStatus()
        }
        
        // iOS 위치 서비스 활성화 여부 확인
        if CLLocationManager.locationServicesEnabled() {
            // 위치 권한 종류 확인
            checkUserCurrentLocationAuthorization(authorizationStatus)
        } else {
            print("위치 서비스가 비활성화되어 있습니다. 위치 서비스를 켜 주세요.")  // 🍓 얼럿 띄우거나 설정으로 이동 유도
        }
    }
    
    
    func checkUserCurrentLocationAuthorization(_ authorizationStatus: CLAuthorizationStatus) {
        switch authorizationStatus {
            case .notDetermined:
                print("Not Determined")
                locationManager.desiredAccuracy = kCLLocationAccuracyBest
                locationManager.requestWhenInUseAuthorization()
            case .restricted:
                print("Restricted")
            case .denied:
                print("Deinied")  // 🍓 설정으로 유도
            case .authorizedWhenInUse:
                print("Authorized When in Use")  // 🍓 항상 허용 요청
                locationManager.startUpdatingLocation()
//            case .authorizedAlways:
//            case .authorized:
            default: print("Default")
        }
    }
}


extension WeatherViewController: CLLocationManagerDelegate {
    // iOS 14 이상: 사용자의 권한 부여 상태가 변경될 때, 위치 관리자(locationManager)가 생성될 때 호출됨
    func locationManagerDidChangeAuthorization(_ manager: CLLocationManager) {
        print(#function)
        checkUserDeviceLocationService()
    }
    
    // iOS 14 미만
    func locationManager(_ manager: CLLocationManager, didChangeAuthorization status: CLAuthorizationStatus) {
        
    }
    
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        print(#function, locations)
        
        if let coordinate = locations.last?.coordinate {
            print("lat: \(coordinate.latitude)")
            print("lat type: \(type(of: coordinate.latitude))")
            print("lon: \(coordinate.longitude)")
            print("lon type: \(type(of: coordinate.longitude))")
            
            // 🍓 API 통신
            requestWeather(lat: coordinate.latitude, lon: coordinate.longitude)
        }
        

        locationManager.stopUpdatingLocation()
    }
    
    func locationManager(_ manager: CLLocationManager, didFailWithError error: Error) {
        print(#function)  // 🍓 얼럿 띄우기
    }
}
