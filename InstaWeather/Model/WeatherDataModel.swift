//
//  WeatherDataModel.swift
//  Rain Check
//
//  Created by Besher on 2018-01-27.
//  Copyright © 2018 Besher Al Maleh. All rights reserved.
//

import Foundation

struct WeatherDataModel: ConvertibleToFahrenheit {
    
    let WEATHER_URL = "http://api.openweathermap.org/data/2.5/weather"
    let WEATHERFC_URL = "http://api.openweathermap.org/data/2.5/forecast"

    var condition = 0
    var city = ""
    var currentTime = 0
    var sunriseTime = 0
    var sunsetTime = 0
    
    var weatherIconName = "" {
        didSet {
            switch weatherIconName {
            case "snow", "fog", "clear", "clearnight", "cloudy2", "cloudy2night" : backgroundName = "bg\(arc4random_uniform(2) + 1)\(weatherIconName)"
            case "tstorm1", "tstorm2": backgroundName = "bgtstorm"
            case "light_rain", "shower3": backgroundName = "bglight_rain"
            default: backgroundName = "bg\(weatherIconName)"
            }
        }
    } 
    var backgroundName = ""

    var forecast = [ForecastObject]()
    var currentDay = 0
    var todayBucket = [ForecastObject]()
    var tomorrowBucket = [ForecastObject]()
    var twoDaysBucket = [ForecastObject]()
    var threeDaysBucket = [ForecastObject]()
    var fourDaysBucket = [ForecastObject]()
    var fiveDaysBucket = [ForecastObject]()
    
    var tomorrowObject: ForecastObject?
    var twoDaysObject: ForecastObject?
    var threeDaysObject: ForecastObject?
    var fourDaysObject: ForecastObject?
    var fiveDaysObject: ForecastObject?
    var weekdayObjects = [ForecastObject]()
    
    var scaleIsCelsius = true
    var temperatureCelsius = 0
    var maxTempCelsius = 0
    var minTempCelsius = 0
    
    struct ForecastSection {
        var forecastDay: String
        var forecastChunks: [ForecastObject]
    }
    
    lazy var forecastDayTitles: [String] = {
        var forecastDays = [String]()
        let formatter  = DateFormatter()
        formatter.dateFormat = "yyyy-MM-dd HH:mm:ss"
        for day in forecast {
            if let date = formatter.date(from: day.date) {
                let newFormatter = DateFormatter()
                newFormatter.dateFormat = "E MMM dd, yyyy"
                let newDay = String(newFormatter.string(from: date))
                if !forecastDays.contains(newDay) {
                    forecastDays.append(newDay)
                }
            } else {
                print(day.date)
            }
        }
        return forecastDays
    }()
    
    lazy var forecastSections: [ForecastSection] = {
        var forecastSections = [ForecastSection]()
        for sectionDay in forecastDayTitles {
            var dailyChunks = [ForecastObject]()
            let firstFormatter = DateFormatter()
            firstFormatter.dateFormat = "yyyy-MM-dd HH:mm:ss"
            for chunk in forecast {
                if let date = firstFormatter.date(from: chunk.date) {
                    let secondFormatter = DateFormatter()
                    secondFormatter.dateFormat = "E MMM dd, yyyy"
                    let thirdFormatter = DateFormatter()
                    thirdFormatter.dateFormat = "yyyy-MM-dd HH:mm:ss"
                    let chunkDay = String(secondFormatter.string(from: date))
                    if chunkDay.prefix(3) == sectionDay.prefix(3) {
                        dailyChunks.append(chunk)
                    }
                }
            }
            forecastSections.append(ForecastSection(forecastDay: sectionDay, forecastChunks: dailyChunks))
        }
        return forecastSections
    }()
    
    
    func updateWeatherIcon(condition: Int, objectTime: Int, objectSunrise: Int = 0, objectSunset: Int = 0) -> String {
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
                
            case 800, 904 :
                if (objectTime > objectSunrise && objectTime < objectSunset) || objectSunrise == 0 {
                    return "clear"
                } else {
                    return "clearnight"
                }
            case 801...804 :
                if (objectTime > objectSunrise && objectTime < objectSunset) || objectSunrise == 0 {
                    return "cloudy2"
                } else {
                    return "cloudy2night"
                }
            case 900...902, 905, 957...1000 :
                return "tstorm3"
                
            case 903 :
                return "snow"
            default :
                if (objectTime > objectSunrise && objectTime < objectSunset) || objectSunrise == 0 {
                    return "clear"
                } else {
                    return "clearnight"
                }
            }
    }
    
    
    mutating func filterDays() {
        currentDay = forecast.first?.currentDay ?? 0
        
        for day in forecast {
            if day.dayOfWeek == currentDay {
                todayBucket.append(day)
            } else if day.dayOfWeek == currentDay + 1 || day.dayOfWeek == currentDay - 6 {
                tomorrowBucket.append(day)
            } else if day.dayOfWeek == currentDay + 2 || day.dayOfWeek == currentDay - 5 {
                twoDaysBucket.append(day)
            } else if day.dayOfWeek == currentDay + 3 || day.dayOfWeek == currentDay - 4 {
                threeDaysBucket.append(day)
            } else if day.dayOfWeek == currentDay + 4 || day.dayOfWeek == currentDay - 3 {
                fourDaysBucket.append(day)
            } else if day.dayOfWeek == currentDay + 5 || day.dayOfWeek == currentDay - 2 {
                fiveDaysBucket.append(day)
            }
        }
                
        weekdayObjects.append(getDailyForecastFor(tomorrowBucket))
        weekdayObjects.append(getDailyForecastFor(twoDaysBucket))
        weekdayObjects.append(getDailyForecastFor(threeDaysBucket))
        weekdayObjects.append(getDailyForecastFor(fourDaysBucket))
        weekdayObjects.append(getDailyForecastFor(fiveDaysBucket))
    }
    
    func getDailyForecastFor(_ day: [ForecastObject]) -> ForecastObject {
        let first = day.first
        var minTemp = first?.minTempCelsius ?? 99
        var maxTemp = first?.maxTempCelsius ?? 99
        for object in day {
            minTemp = min(minTemp, object.minTempCelsius)
            maxTemp = max(maxTemp, object.maxTempCelsius)
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
        return ForecastObject(date: date, condition: condition, maxTemp: maxTemp, minTemp: minTemp, scaleIsCelsius: scaleIsCelsius)
    }
    
    mutating func toggleScale(to: Int) {
        if to == 1 {
            scaleIsCelsius = false
            for (index, _) in forecast.enumerated() {
                forecast[index].scaleIsCelsius = false
            }
            for (index, _) in weekdayObjects.enumerated() {
                weekdayObjects[index].scaleIsCelsius = false
            }
        } else {
            scaleIsCelsius = true
            for (index, _) in forecast.enumerated() {
                forecast[index].scaleIsCelsius = true
            }
            for (index, _) in weekdayObjects.enumerated() {
                weekdayObjects[index].scaleIsCelsius = true
            }
        }
    }

    
}
