//
//  FahrenheitProtocol.swift
//  InstaWeather
//
//  Created by Besher on 2018-02-04.
//  Copyright © 2018 Besher Al Maleh. All rights reserved.
//

import Foundation

protocol ConvertibleToFahrenheit {
    var temperatureScale: WeatherDataModel.Scale { get }
    var temperatureCelsius: Int { get set }
    var minTempCelsius: Int { get set }
    var maxTempCelsius: Int { get set }
    var windSpeedKph: Int { get set }
}

extension ConvertibleToFahrenheit {
  
    var temperature: Int {
        get {
            return temperatureScale == .celsius ? temperatureCelsius : temperatureFahrenheit
        }
        set {
            temperatureCelsius = newValue
        }
    }
    var maxTemp: Int {
        get {
            return temperatureScale == .celsius ? maxTempCelsius : maxTempFahrenheit
        }
        set {
            maxTempCelsius = newValue
        }
    }
    var minTemp: Int {
        get {
            return temperatureScale == .celsius ? minTempCelsius : minTempFahrenheit
        }
        set {
            minTempCelsius = newValue
        }
    }
    var windSpeed: Int {
        get {
            return temperatureScale == .celsius ? windSpeedKph : windSpeedMph
        }
        set {
            windSpeedKph = newValue
        }
    }
    
    private var temperatureFahrenheit: Int {
        return celsiusToFahrenheit(temperatureCelsius)
    }
    private var maxTempFahrenheit: Int {
        return celsiusToFahrenheit(maxTempCelsius)
    }
    private var minTempFahrenheit: Int {
        return celsiusToFahrenheit(minTempCelsius)
    }
    private var windSpeedMph: Int {
        return kphToMph(windSpeedKph)
    }
    
    private func celsiusToFahrenheit(_ temp: Int) -> Int {
        return Int((Double(temp) * 1.8) + 32)
    }
    
    private func fahrenheitToCelsius(_ temp: Int) -> Int {
        return Int((Double(temp) - 32) * 0.5556)
    }
    
    func convertTempToCurrentScale(_ temp: Int) -> Int {
        if temperatureScale == .celsius {
            return temp
        } else {
            return celsiusToFahrenheit(temp)
        }
    }
    
    private func kphToMph(_ wind: Int) -> Int {
        return Int(Double(wind) * 0.6214)
    }
    
    func celsiusToKelvin(_ temp: Int) -> Double {
        return Double(temp) + 273.15
    }
    
    func kelvinToCelsius(_ temp: Double) -> Int {
        return Int(temp - 273.15)
    }
}
