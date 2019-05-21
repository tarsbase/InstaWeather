//
//  FahrenheitProtocol.swift
//  InstaWeather
//
//  Created by Besher on 2018-02-04.
//  Copyright © 2018 Besher Al Maleh. All rights reserved.
//

import Foundation

protocol ConvertibleToFahrenheit {
    var tempScale: WeatherDataModel.Scale { get }
    var temperatureCelsius: Int { get set }
    var minTempCelsius: Int { get set }
    var maxTempCelsius: Int { get set }
    var feelsLikeFahrenheit: Int { get set }
    var windSpeedKph: Int { get set }
}

extension ConvertibleToFahrenheit {
  
    var temperature: Int {
        get {
            return tempScale == .celsius ? temperatureCelsius : temperatureFahrenheit
        }
        set {
            temperatureCelsius = newValue
        }
    }
    var maxTemp: Int {
        get {
            return tempScale == .celsius ? maxTempCelsius : maxTempFahrenheit
        }
        set {
            maxTempCelsius = newValue
        }
    }
    var minTemp: Int {
        get {
            return tempScale == .celsius ? minTempCelsius : minTempFahrenheit
        }
        set {
            minTempCelsius = newValue
        }
    }
    var feelsLike: Int {
        get {
            return tempScale == .celsius ? feelsLikeCelsius : feelsLikeFahrenheit
        }
        set {
            feelsLikeFahrenheit = newValue
        }
    }
    var windSpeed: Int {
        get {
            return tempScale == .celsius ? windSpeedKph : windSpeedMph
        }
        set {
            windSpeedKph = newValue
        }
    }
    
    var temperatureFahrenheit: Int {
        return celsiusToFahrenheit(temperatureCelsius)
    }
    var maxTempFahrenheit: Int {
        return celsiusToFahrenheit(maxTempCelsius)
    }
    var minTempFahrenheit: Int {
        return celsiusToFahrenheit(minTempCelsius)
    }
    var feelsLikeCelsius: Int {
        return fahrenheitToCelsius(feelsLikeFahrenheit)
    }
    var windSpeedMph: Int {
        return kphToMph(windSpeedKph)
    }
    
    func celsiusToFahrenheit(_ temp: Int) -> Int {
        return Int((Double(temp) * 1.8) + 32)
    }
    
    func fahrenheitToCelsius(_ temp: Int) -> Int {
        return Int((Double(temp) - 32) * 0.5556)
    }
    
    func convertTempToCurrentScale(_ temp: Int) -> Int {
        if tempScale == .celsius {
            return temp
        } else {
            return celsiusToFahrenheit(temp)
        }
    }
    
    func kphToMph(_ wind: Int) -> Int {
        return Int(Double(wind) * 0.6214)
    }
    
    func celsiusToKelvin(_ temp: Int) -> Double {
        return Double(temp) + 273.15
    }
    
    func kelvinToCelsius(_ temp: Double) -> Int {
        return Int(temp - 273.15)
    }
}
