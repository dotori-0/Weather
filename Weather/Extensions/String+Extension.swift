//
//  String+Extension.swift
//  Weather
//
//  Created by SC on 2022/08/14.
//

import Foundation


extension String {
    mutating func translate() {
        switch self {
            case "Thunderstorm": self = "뇌우"
            case "Drizzle": self = "이슬비"
            case "Rain": self = "비"
            case "Snow": self = "눈"
            case "Mist": self = "옅은 안개"
            case "Smoke": self = "연기"
            case "Haze": self = "아지랑이"
            case "Dust": self = "먼지"
            case "Fog": self = "안개"
            case "Sand": self = "모래"
            case "Ash": self = "재"
            case "Squall": self = "돌풍"
            case "Tornado": self = "토네이도"
            case "Clear": self = "맑음"
            case "Clouds": self = "구름"
            default: self = "번역 오류"
        }
    }
}
