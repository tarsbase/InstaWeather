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
        case .mainScreen(let weather): return "Mainscreen_\(weather.rawValue)"
        case .detailedForecast(let weather): return "Detailed_\(weather.rawValue)"
        case .weeklyForecast(let weather): return "Weekly_\(weather.rawValue)"
        case .changeCity(let weather): return "ChangeCity_\(weather.rawValue)"
        }
    }
    
    static func setup(weatherType: ImageWeatherType, from host: PickerHostType) -> PickerHostType {
        switch host {
        case .mainScreen: return PickerHostType.mainScreen(weatherType)
        case .detailedForecast: return PickerHostType.detailedForecast(weatherType)
        case .weeklyForecast: return PickerHostType.weeklyForecast(weatherType)
        case .changeCity: return PickerHostType.changeCity(weatherType)
        }
    }
    
    // migration code
    static func setupClearFrom(host: PickerHostType) -> PickerHostType {
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
    case all, clear, cloudy, rainy, stormy, snowy
}
