//
//  ImageLoader.swift
//  InstaWeather
//
//  Created by Besher on 2019-01-29.
//  Copyright © 2019 Besher Al Maleh. All rights reserved.
//

import UIKit

struct BackgroundImageLoader {
    static let shared = BackgroundImageLoader()
    private init() {}
    
    
}



enum PickerHostType {
    case mainScreen(ImageWeatherType), detailedForecast(ImageWeatherType), weeklyForecast(ImageWeatherType), changeCity(ImageWeatherType)
    
    var description: String {
        switch self {
        case .mainScreen(let weather): return "Mainscreen,\(weather.rawValue)"
        case .detailedForecast(let weather): return "Detailed,\(weather.rawValue)"
        case .weeklyForecast(let weather): return "Weekly,\(weather.rawValue)"
        case .changeCity(let weather): return "ChangeCity,\(weather.rawValue)"
        }
    }
    
    // migration code
    static func setupFrom(host: PickerHostType) -> PickerHostType {
        switch host {
        case .mainScreen: return PickerHostType.mainScreen(.clear)
        case .detailedForecast: return PickerHostType.detailedForecast(.clear)
        case .weeklyForecast: return PickerHostType.weeklyForecast(.clear)
        case .changeCity: return PickerHostType.changeCity(.clear)
        }
    }
    
    var preMigrationName: String {
        switch self {
        case .mainScreen: return "mainScreen"
        case .detailedForecast: return "detailedForecast"
        case .weeklyForecast: return "weeklyForecast"
        case .changeCity: return "changeCity"
        }
    }
}

enum ImageWeatherType: String {
    case clear, cloudy, rainy, stormy, snowy
}
