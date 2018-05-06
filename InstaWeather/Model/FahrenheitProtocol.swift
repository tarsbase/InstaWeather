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
    var temperatureCelsius: Int { get set }
    var minTempCelsius: Int { get set }
    var maxTempCelsius: Int { get set }
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
            temperatureCelsius = newValue
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
            maxTempCelsius = newValue
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
            minTempCelsius = newValue
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
    
    func celsiusToFahrenheit(_ temp: Int) -> Int {
        return Int((Double(temp) * 1.8) + 32)
    }
    
    mutating func convertTempToCurrentScale(_ temp: Int) -> Int {
        if scaleIsCelsius {
            return temp
        } else {
            return celsiusToFahrenheit(temp)
        }
    }
    
}
