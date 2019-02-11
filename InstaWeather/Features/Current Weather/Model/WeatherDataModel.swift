//
//  WeatherDataModel.swift
//  Rain Check
//
//  Created by Besher on 2018-01-27.
//  Copyright © 2018 Besher Al Maleh. All rights reserved.
//

import Foundation
import UIKit

public struct WeatherDataModel: ConvertibleToFahrenheit {
    
    let weatherURL = "http://api.openweathermap.org/data/2.5/weather"
    let forecastURL = "http://api.openweathermap.org/data/2.5/forecast"

    var condition = 0
    var city = ""
    var currentTime = 0
    var sunriseTime = 0
    var sunsetTime = 0
    
    var weatherIconName = "" {
        didSet {
            updateImageWeatherTypeWith(weatherIconName)
            updateBackgroundWith(weatherIconName)
        }
    }
    
    var defaultBackgroundName = ""
    var weatherType: ImageWeatherType = .clear

    private var _forecast = [ForecastObject]()
    var forecast: [ForecastObject] {
        get {
            return _forecast
        }
        set {
            _forecast = newValue
        }
    }
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
    
    private(set) var scaleIsCelsius = true
    private var _windDirection = 0.0
//    var temperatureFahrenheit = 0
//    var maxTempFahrenheit = 0
//    var minTempFahrenheit = 0
    var temperatureCelsius = 0
    var maxTempCelsius = 0
    var minTempCelsius = 0
    var feelsLikeFahrenheit = 0
    var windSpeedKph = 0
    var humidity = 0
    var latitude = 0.0
    var longitude = 0.0
    var lastUpdated: Date?
    
    var windDirection: String {
        get {
            return windDirectionFromDegrees(degrees: _windDirection)
        }
        set {
            _windDirection = Double(newValue) ?? 0.0
        }
    }
    
    var windDirectionInDegrees: Double {
        set {
            _windDirection = newValue
        }
        get {
            return _windDirection
        }
    }

    struct ForecastSection {
        var forecastDay: String
        var forecastChunks: [ForecastObject]
    }
    
    lazy var firstFormatter: DateFormatter = {
        let formatter  = DateFormatter()
        formatter.dateFormat = "yyyy-MM-dd HH:mm:ss"
        return formatter
    }()
    
    
    lazy var secondFormatter: DateFormatter = {
        let formatter = DateFormatter()
        formatter.dateFormat = "E MMM dd, yyyy"
        return formatter
    }()
    
    lazy var objectFormatter: DateFormatter = {
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy-MM-dd"
        return formatter
    }()
    
    lazy var lastUpdatedFormatter: DateFormatter = {
        let formatter  = DateFormatter()
        formatter.dateFormat = "yyyy-MM-dd, h:mm a"
        return formatter
    }()
    
    
    lazy var forecastDayTitles: [String] = {
        var forecastDays = [String]()
        for day in forecast {
            if let date = firstFormatter.date(from: day.date) {
                let newDay = String(secondFormatter.string(from: date))
                if !forecastDays.contains(newDay) {
                    forecastDays.append(newDay)
                }
            } 
        }
        return forecastDays
    }()
    
    lazy var forecastSections: [ForecastSection] = {
        var forecastSections = [ForecastSection]()
        var forecastObjects = forecast
        for sectionDay in forecastDayTitles {
            var dailyChunks = [ForecastObject]()
            var indicesToRemove = [Int]()
            for (index, chunk) in forecastObjects.enumerated() {
                if let date = firstFormatter.date(from: chunk.date) {
                    let chunkDay = String(secondFormatter.string(from: date))
                    if chunkDay.prefix(3) == sectionDay.prefix(3) {
                        dailyChunks.append(chunk)
                        indicesToRemove.append(index)
                    }
                }
            }
            for index in indicesToRemove.sorted().reversed() {
                forecastObjects.remove(at: index)
            }
            forecastSections.append(ForecastSection(forecastDay: sectionDay, forecastChunks: dailyChunks))
        }
        return forecastSections
    }()
    
    func updateOpenWeatherIcon(condition: Int, objectTime: Int, objectSunrise: Int = 0, objectSunset: Int = 0) -> String {
            switch condition {
            case 0...300 : return "tstorm1"
            case 301...500 : return "light_rain"
            case 501...599 : return "shower3"
            case 600...700 : return "snow"
            case 701...771 : return "fog"
            case 772...799 : return "tstorm3"
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
            case 900...902, 905, 957...1000 : return "tstorm3"
            case 903 : return "snow"
            default :
                if (objectTime > objectSunrise && objectTime < objectSunset) || objectSunrise == 0 {
                    return "clear"
                } else {
                    return "clearnight"
                }
            }
    }
    
    func updateYahooWeatherIcon(condition: Int) -> String {
        switch condition {
        case 0...4, 37...39, 45, 47: return "tstorm1"
        case 5...8: return "snow"
        case 9...10, 35: return "light_rain"
        case 11...12, 40: return "shower3"
        case 13...18, 41...43, 46: return "snow"
        case 19...23: return "fog"
        case 24...25: return "wind"
        case 26, 44: return "overcast"
        case 28, 30: return "cloudy2"
        case 27, 29: return "cloudy2night"
        case 31, 33: return "clearnight"
        case 32, 34, 36: return "clear"
        default: return "none"
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
    
    mutating func getDailyForecastFor(_ day: [ForecastObject]) -> ForecastObject {
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
        return ForecastObject(date: date, condition: condition, maxTemp: maxTemp, minTemp: minTemp, scaleIsCelsius: scaleIsCelsius, formatter: objectFormatter)
    }

    mutating func toggleScale(to: Int) {
        if to == 1 {
            scaleIsCelsius = false
        } else {
            scaleIsCelsius = true
        }
    }
    
    mutating func minTempForSection(_ section: Int, row: Int) -> Int {
        return convertTempToCurrentScale(forecastSections[section].forecastChunks[row].minTempCelsius)
    }
    
    mutating func maxTempForSection(_ section: Int, row: Int) -> Int {
        return convertTempToCurrentScale(forecastSections[section].forecastChunks[row].maxTempCelsius)
    }
    
    mutating func minTempForObject(_ object: Int) -> Int {
        return convertTempToCurrentScale(weekdayObjects[object].minTempCelsius)
    }
    
    mutating func maxTempForObject(_ object: Int) -> Int {
        return convertTempToCurrentScale(weekdayObjects[object].maxTempCelsius)
    }
    
    func windDirectionFromDegrees(degrees : Double) -> String {
        let directions = ["N", "NNE", "NE", "ENE", "E", "ESE", "SE", "SSE", "S", "SSW", "SW", "WSW", "W", "WNW", "NW", "NNW"]
        let i: Int = Int((degrees + 11.25)/22.5)
        return directions[i % 16]
    }
    
    mutating func updateBackgroundWith(_ weatherIconName: String) {
        switch weatherIconName {
        case "clear":
            defaultBackgroundName = "bg\(arc4random_uniform(3) + 1)\(weatherIconName)"
            if UIDevice.current.userInterfaceIdiom == .phone && defaultBackgroundName == "bg2clear" {
                defaultBackgroundName += "iPhone\(arc4random_uniform(3) + 1)"
            }
        case "snow", "fog", "clearnight", "cloudy2night":
            defaultBackgroundName = "bg\(arc4random_uniform(2) + 1)\(weatherIconName)"
        case "tstorm1", "tstorm2":
            defaultBackgroundName = "bgtstorm"
        case "cloudy2", "overcast", "wind":
            defaultBackgroundName = UIDevice.current.userInterfaceIdiom == .phone ? "bg2cloudyiPhone" : "bg2cloudy"
        case "light_rain", "shower3":
            defaultBackgroundName = "bglight_rain"
        default:
            defaultBackgroundName = "bg\(weatherIconName)"
        }
    }
    
    mutating func updateImageWeatherTypeWith(_ weatherIconName: String) {
        switch weatherIconName {
        case "clear", "clearnight":
            weatherType = .clear
        case "cloudy2night", "cloudy2", "fog", "overcast":
            weatherType = .cloudy
        case "snow":
            weatherType = .snowy
        case "light_rain", "shower3":
            weatherType = .rainy
        case "tstorm1", "tstorm2", "wind":
            weatherType = .stormy
        default:
            weatherType = .clear
        }
    }
    
    // default value is set to .mainScreen temporarily, can be expanded later
    func getBackground(host: PickerHostType = .mainScreen(.all)) -> UIImage? {
        
        // custom user image
        
        let host = PickerHostType.setup(weatherType: weatherType, from: host)
        
        if ImageManager.customBackgroundFor(host: host) {
            return ImageManager.getBackgroundImage(for: host)
            
            // some images are custom, this one isn't
        } else if ImageManager.backgroundAdjustedFor(host: host) {
            return ImageManager.loadImage(named: weatherType.defaultBackground)
            
            // all images are default
        } else {
            return ImageManager.loadImage(named: defaultBackgroundName)
        }
    }
    
}
