//
//  WeatherDataModel.swift
//  Rain Check
//
//  Created by Besher on 2018-01-27.
//  Copyright © 2018 Besher Al Maleh. All rights reserved.
//

import Foundation

struct WeatherDataModel {
    
    let WEATHER_URL = "http://api.openweathermap.org/data/2.5/weather"
    let WEATHERFC_URL = "http://api.openweathermap.org/data/2.5/forecast"
    var temperature = 0
    var maxTemp = 0
    var minTemp = 0
    var condition = 0
    var city = ""
    var weatherIconName = "" {
        didSet {
            switch weatherIconName {
            case "cloudy2": backgroundName = "bg\(arc4random_uniform(3) + 1)\(weatherIconName)"
            case "snow", "fog", "sunny" : backgroundName = "bg\(arc4random_uniform(2) + 1)\(weatherIconName)"
            case "tstorm1", "tstorm2": backgroundName = "bgtstorm"
            case "light_rain", "shower3": backgroundName = "bglight_rain"
            default: backgroundName = "bg\(weatherIconName)"
            }
        }
    } 
    var backgroundName = ""
    var forecast = [ForecastObject]()
    var currentDay = 0
    var today = [ForecastObject]()
    var tomorrow = [ForecastObject]()
    var twoDays = [ForecastObject]()
    var threeDays = [ForecastObject]()
    var fourDays = [ForecastObject]()
    var fiveDays = [ForecastObject]()
    
    var tomorrowObject: ForecastObject?
    var twoDaysObject: ForecastObject?
    var threeDaysObject: ForecastObject?
    var fourDaysObject: ForecastObject?
    var fiveDaysObject: ForecastObject?
    
    func updateWeatherIcon(condition: Int) -> String {
        
        switch condition {
        case 0...300 :
            return "tstorm1"
            
        case 301...500 :
            return "light_rain"
            
        case 501...599 :
            return "shower3"
            
        case 600...700 :
            return "snow"
            
        case 701...771 :
            return "fog"
            
        case 772...799 :
            return "tstorm3"
            
        case 800 :
            return "sunny"
            
        case 801...804 :
            return "cloudy2"
            
        case 900...902, 905, 957...1000 :
            return "tstorm3"
            
        case 903 :
            return "snow"
            
        case 904 :
            return "sunny"
            
        default :
            return "sunny"
        }
    }
    
    mutating func filterDays() {
        currentDay = forecast.first?.currentDay ?? 0
        
        for day in forecast {
            if day.dayOfWeek == currentDay {
                today.append(day)
            } else if day.dayOfWeek == currentDay + 1 || day.dayOfWeek == currentDay - 6 {
                tomorrow.append(day)
            } else if day.dayOfWeek == currentDay + 2 || day.dayOfWeek == currentDay - 5 {
                twoDays.append(day)
            } else if day.dayOfWeek == currentDay + 3 || day.dayOfWeek == currentDay - 4 {
                threeDays.append(day)
            } else if day.dayOfWeek == currentDay + 4 || day.dayOfWeek == currentDay - 3 {
                fourDays.append(day)
            } else if day.dayOfWeek == currentDay + 5 || day.dayOfWeek == currentDay - 2 {
                fiveDays.append(day)
            }
        }
        tomorrowObject = getDailyForecastFor(tomorrow)
        twoDaysObject = getDailyForecastFor(twoDays)
        threeDaysObject = getDailyForecastFor(threeDays)
        fourDaysObject = getDailyForecastFor(fourDays)
        fiveDaysObject = getDailyForecastFor(fiveDays)
        
    }
    
    func getDailyForecastFor(_ day: [ForecastObject]) -> ForecastObject {
        
        var minTemp = day.first?.minTemp ?? 99
        var maxTemp = day.first?.maxTemp ?? 99
        for object in day {
            minTemp = min(minTemp, object.minTemp)
            maxTemp = max(maxTemp, object.maxTemp)
        }
        let set = NSCountedSet()
        day.forEach { set.add($0.condition) }
        var common: (condition: Int, frequency: Int) = (0, 0)
        for case let value as Int in set {
            if set.count(for: value) > common.frequency {
                common = (value, set.count(for: value))
            }
        }
        let condition = common.condition
        let date = day.first?.date ?? ""
        return ForecastObject(date: date, condition: condition, maxTemp: maxTemp, minTemp: minTemp)
    }
    
}
