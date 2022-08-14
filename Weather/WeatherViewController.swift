//
//  WeatherViewController.swift
//  Weather
//
//  Created by SC on 2022/08/14.
//

import MapKit
import UIKit

class WeatherViewController: UIViewController {
    
    let locationManager = CLLocationManager()
    

    override func viewDidLoad() {
        super.viewDidLoad()

        locationManager.delegate = self
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
            APIManager.shared.fetchCurrentWeather(lat: coordinate.latitude, lon: coordinate.longitude)
        }
        

        locationManager.stopUpdatingLocation()
    }
    
    func locationManager(_ manager: CLLocationManager, didFailWithError error: Error) {
        print(#function)  // 🍓 얼럿 띄우기
    }
}
