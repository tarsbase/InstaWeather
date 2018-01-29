//
//  WeatherDataModel.swift
//  Rain Check
//
//  Created by Besher on 2018-01-27.
//  Copyright © 2018 Besher Al Maleh. All rights reserved.
//

import Foundation

struct WeatherDataModel {
    
    var temperature = 0
    var maxTemp = 0
    var minTemp = 0
    var condition = 0
    var city = ""
    var weatherIconName = "" {
        didSet {
            switch weatherIconName {
            case "snow", "fog", "cloudy2": backgroundName = "bg\(arc4random_uniform(2) + 1)\(weatherIconName)"
            case "tstorm1", "tstorm2": backgroundName = "bgtstorm"
            case "light_rain", "shower3": backgroundName = "bglight_rain"
            default: backgroundName = "bg\(weatherIconName)"
            }
        }
    } 
    var backgroundName = ""
    
    
    func updateWeatherIcon(condition: Int) -> String {
        
        switch condition {
        case 0...300 :
            return "tstorm1"
            
        case 301...500 :
            return "light_rain"
            
        case 501...600 :
            return "shower3"
            
        case 601...700 :
            return "snow"
            
        case 701...771 :
            return "fog"
            
        case 772...799 :
            return "tstorm3"
            
        case 800 :
            return "sunny"
            
        case 801...804 :
            return "cloudy2"
            
        case 900...903, 905...1000  :
            return "tstorm3"
            
        case 903 :
            return "snow"
            
        case 904 :
            return "sunny"
            
        default :
            return "sunny"
            
        }
    }
    
    
}
