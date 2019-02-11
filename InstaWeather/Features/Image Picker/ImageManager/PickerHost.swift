//
//  ImageLoader.swift
//  InstaWeather
//
//  Created by Besher on 2019-01-29.
//  Copyright © 2019 Besher Al Maleh. All rights reserved.
//

import UIKit

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
    static func setupAllFrom(host: PickerHostType) -> PickerHostType {
        switch host {
        case .mainScreen: return PickerHostType.mainScreen(.all)
        case .detailedForecast: return PickerHostType.detailedForecast(.all)
        case .weeklyForecast: return PickerHostType.weeklyForecast(.all)
        case .changeCity: return PickerHostType.changeCity(.all)
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
    
    static var allCases: [PickerHostType] {
        var allCases = [PickerHostType]()
        for weatherCase in ImageWeatherType.allCases {
            allCases.append(PickerHostType.mainScreen(weatherCase))
            allCases.append(PickerHostType.detailedForecast(weatherCase))
            allCases.append(PickerHostType.weeklyForecast(weatherCase))
            allCases.append(PickerHostType.changeCity(weatherCase))
        }
        
        return allCases
    }
    
    var weather: ImageWeatherType {
        switch self {
        case .changeCity(let x), .detailedForecast(let x), .mainScreen(let x), .weeklyForecast(let x):
            return x
        }
    }
}

enum ImageWeatherType: String, CaseIterable {
    case all, clear, cloudy, rainy, stormy, snowy
    
    var title: String {
        switch self {
        case .all: return "Background for all conditions"
        case .clear: return "Clear weather background"
        case .cloudy: return "Cloudy weather background"
        case .rainy: return "Rainy weather background"
        case .stormy: return "Stormy weather background"
        case .snowy: return "Snowy weather background"
        }
    }
    
    var defaultBackground: String {
        switch self {
        case .all:
            return "bg3clear"
        case .clear:
            return "bg2clear"
        case .cloudy:
            return "bg2cloudy"
        case .rainy:
            return "bglight_rain"
        case .stormy:
            return "bgtstorm"
        case .snowy:
            return "bg2snow"
        }
    }
}
