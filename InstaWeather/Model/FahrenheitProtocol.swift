//
//  FahrenheitProtocol.swift
//  InstaWeather
//
//  Created by Besher on 2018-02-04.
//  Copyright © 2018 Besher Al Maleh. All rights reserved.
//

import Foundation

protocol ConvertibleToFahrenheit {
    var scaleIsCelsius: Bool { mutating get }
    var temperatureFahrenheit: Int { get set }
    var minTempFahrenheit: Int { get set }
    var maxTempFahrenheit: Int { get set }
    var feelsLikeFahrenheit: Int { get set }
    var windSpeedKph: Int { get set }
}

extension ConvertibleToFahrenheit {
  
    var temperature: Int {
        mutating get {
            if scaleIsCelsius {
                return temperatureCelsius
            } else {
                return temperatureFahrenheit
            }
        }
        set {
            temperatureFahrenheit = newValue
        }
    }
    var maxTemp: Int {
        mutating get {
            if scaleIsCelsius {
                return maxTempCelsius
            } else {
                return maxTempFahrenheit
            }
        }
        set {
            maxTempFahrenheit = newValue
        }
    }
    var minTemp: Int {
        mutating get {
            if scaleIsCelsius {
                return minTempCelsius
            } else {
                return minTempFahrenheit
            }
        }
        set {
            minTempFahrenheit = newValue
        }
    }
    var feelsLike: Int {
        mutating get {
            if scaleIsCelsius {
                return feelsLikeCelsius
            } else {
                return feelsLikeFahrenheit
            }
        }
        set {
            feelsLikeFahrenheit = newValue
        }
    }
    var windSpeed: Int {
        mutating get {
            if scaleIsCelsius {
                return windSpeedKph
            } else {
                return windSpeedMph
            }
        }
        set {
            windSpeedKph = newValue
        }
    }
    
    var temperatureCelsius: Int {
        return fahrenheitToCelsius(temperatureFahrenheit)
    }
    var maxTempCelsius: Int {
        return fahrenheitToCelsius(maxTempFahrenheit)
    }
    var minTempCelsius: Int {
        return fahrenheitToCelsius(minTempFahrenheit)
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
    
    mutating func convertTempToCurrentScale(_ temp: Int) -> Int {
        if scaleIsCelsius {
            return temp
        } else {
            return celsiusToFahrenheit(temp)
        }
    }
    
    func kphToMph(_ wind: Int) -> Int {
        return Int(Double(wind) * 0.6214)
    }
    
}
