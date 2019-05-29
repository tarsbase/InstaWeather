//
//  WeatherDataModel.swift
//  Rain Check
//
//  Created by Besher on 2018-01-27.
//  Copyright © 2018 Besher Al Maleh. All rights reserved.
//

import UIKit
import SwiftyJSON

struct WeatherDataModel: ConvertibleToFahrenheit {
    
    struct ForecastSection {
        var forecastDay: String
        var forecastChunks: [ForecastObject]
    }
    
    enum Scale: Int {
        case celsius = 0, fahrenheit
    }

    // Private Properties
    
    private var condition = 0
    private var currentTime = 0
    private var sunriseTime = 0
    private var sunsetTime = 0
    private var latitude = 0.0
    private var longitude = 0.0
    private var _windDirection = 0.0
    private var _forecast = [ForecastObject]()
    
    private var currentDay = 0
    private var todayBucket = [ForecastObject]()
    private var tomorrowBucket = [ForecastObject]()
    private var twoDaysBucket = [ForecastObject]()
    private var threeDaysBucket = [ForecastObject]()
    private var fourDaysBucket = [ForecastObject]()
    private var fiveDaysBucket = [ForecastObject]()
    private var weeklyForecast = [(tag: Int, day: String, icon: Int, temperature: String)]()
    
    private var longFormatter: DateFormatter {
        return OptimizedDateFormatter.getFormatter(.long)
    }
    
    private var mediumFormatter: DateFormatter {
        return OptimizedDateFormatter.getFormatter(.medium)
    }
    
    private var shortFormatter: DateFormatter {
        return OptimizedDateFormatter.getFormatter(.short)
    }
    
    private var forecast: [ForecastObject] {
        get {
            return _forecast
        }
        set {
            _forecast = newValue
        }
    }
    
    // Public Properties
    
    var city = ""
    var weatherIconName = ""
    var defaultBackgroundName = ""
    var weekdayObjects = [ForecastObject]()
    var humidity = 0
    var lastUpdated: Date?
    var forecastDayTitles = [String]()
    var forecastSections = [ForecastSection]()
    var weatherType: ImageWeatherType = .clear
    
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
    
    // Protocol Properties (Convertible to Fahrenheit)
    private(set) var temperatureScale = Scale.celsius
    var temperatureCelsius = 0
    var maxTempCelsius = 0
    var minTempCelsius = 0
    var windSpeedKph = 0
    
    
    init(scale: Int = 0) {
        toggleScale(to: scale)
    }
    
    init(city: String, scale: Int, currentWeather: JSON, forecastWeather: JSON) {
        processCurrentWeatherData(city: city, scale: scale, json: currentWeather)
        processForecastWeatherData(json: forecastWeather)
        saveToDisk()
    }
    
    private mutating func processCurrentWeatherData(city: String, scale: Int, json: JSON) {
        self.lastUpdated = Date()
        self.toggleScale(to: scale)
        self.temperature = kelvinToCelsius(json["main"]["temp"].doubleValue)
        self.city = city
        self.condition = json["weather"][0]["id"].intValue
        self.currentTime = json["dt"].intValue
        self.sunriseTime = json["sys"]["sunrise"].intValue
        self.sunsetTime = json["sys"]["sunset"].intValue
        let humidity = json["main"]["humidity"].intValue
        self.humidity = humidity
        let meterPerSecond = json["wind"]["speed"].doubleValue
        let kphSpeed = Int(meterPerSecond * 3.6)
        self.windSpeedKph = kphSpeed
        let windDirection = json["wind"]["deg"].doubleValue
        self.windDirectionInDegrees = windDirection
        self.weatherIconName = updateOpenWeatherIcon(condition: condition,
                                                     objectTime: currentTime,
                                                     objectSunrise: sunriseTime,
                                                     objectSunset: sunsetTime)
        self.updateImageWeatherTypeWith(weatherIconName)
        self.updateBackgroundWith(weatherIconName)
    }
    
    private mutating func processForecastWeatherData(json: JSON) {
        
        var minTemp = celsiusToKelvin(temperatureCelsius)
        var maxTemp = celsiusToKelvin(temperatureCelsius)
        for i in 0...7 {
            minTemp = min(minTemp, json["list"][i]["main"]["temp"].double ?? 0)
            maxTemp = max(maxTemp, json["list"][i]["main"]["temp"].double ?? 0)
        }
        self.minTemp = kelvinToCelsius(minTemp)
        self.maxTemp = kelvinToCelsius(maxTemp)
        
        for (_, value) in json["list"] {
            let date = value["dt_txt"].stringValue
            let condition = value["weather"][0]["id"].intValue
            let max = kelvinToCelsius(value["main"]["temp_max"].double ?? 0)
            let min = kelvinToCelsius(value["main"]["temp_min"].double ?? 0)
            let forecastObject = ForecastObject(date: date, condition: condition, maxTemp: max, minTemp: min)
            self.forecast.append(forecastObject)
        }
        self.filterDays()
        
        self.forecastDayTitles = createForecastDayTitles()
        self.forecastSections = createForecastSections()
        self.weeklyForecast = WeatherParser.parseWeeklyData(model: self)
    }
    
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
    
    private mutating func filterDays() {
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
    
    private mutating func getDailyForecastFor(_ day: [ForecastObject]) -> ForecastObject {
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
        return ForecastObject(date: date, condition: condition, maxTemp: maxTemp, minTemp: minTemp)
    }
    
    private mutating func createForecastDayTitles() -> [String] {
        var forecastDays = [String]()
        for day in forecast {
            if let date = longFormatter.date(from: day.date) {
                let newDay = String(mediumFormatter.string(from: date))
                if !forecastDays.contains(newDay) {
                    forecastDays.append(newDay)
                }
            }
        }
        return forecastDays
    }
    
    private mutating func createForecastSections() -> [ForecastSection] {
        var forecastSections = [ForecastSection]()
        var forecastObjects = forecast
        for sectionDay in forecastDayTitles {
            var dailyChunks = [ForecastObject]()
            var indicesToRemove = [Int]()
            for (index, chunk) in forecastObjects.enumerated() {
                if let date = longFormatter.date(from: chunk.date) {
                    let chunkDay = String(mediumFormatter.string(from: date))
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
    }

    mutating func toggleScale(to scale: Int) {
        if let scale = WeatherDataModel.Scale(rawValue: scale) {
            self.temperatureScale = scale
        }
    }
    
    mutating func minTempForSection(_ section: Int, row: Int) -> Int {
        return convertTempToCurrentScale(forecastSections[section].forecastChunks[row].minTempCelsius)
    }
    
    mutating func maxTempForSection(_ section: Int, row: Int) -> Int {
        return convertTempToCurrentScale(forecastSections[section].forecastChunks[row].maxTempCelsius)
    }
    
    func minTempForObject(_ object: Int) -> Int {
        return convertTempToCurrentScale(weekdayObjects[object].minTempCelsius)
    }
    
    func maxTempForObject(_ object: Int) -> Int {
        return convertTempToCurrentScale(weekdayObjects[object].maxTempCelsius)
    }
    
    func getWeeklyForecast() -> [(tag: Int, day: String, icon: Int, temperature: String)] {
        return weeklyForecast
    }
    
    private func windDirectionFromDegrees(degrees : Double) -> String {
        let directions = ["N", "NNE", "NE", "ENE", "E", "ESE", "SE", "SSE", "S", "SSW", "SW", "WSW", "W", "WNW", "NW", "NNW"]
        let i: Int = Int((degrees + 11.25)/22.5)
        return directions[i % 16]
    }
    
    func getHostType() -> PickerHostType {
        return PickerHostType.setup(weatherType: weatherType, from: .mainScreen(.all))
    }
    
    private mutating func updateBackgroundWith(_ weatherIconName: String) {
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
    
    private mutating func updateImageWeatherTypeWith(_ weatherIconName: String) {
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
    func getBackground() -> UIImage? {
        
        // first check if image is used for all conditions
        let host = getHostType()
        
        if ImageManager.singleBackgroundFor(host: host) {
            
            if AppSettings.mainscreenBackgrounds.allWeather.customBackground {
                return ImageManager.getBackgroundImage(for: .mainScreen(.all))
            } else {
                return ImageManager.loadImage(named: ImageWeatherType.all.defaultBackground)
            }

            // then check if custom user images
        } else if ImageManager.customBackgroundFor(host: host) {
            return ImageManager.getBackgroundImage(for: host)
            
            // some images are custom, this one isn't
        } else if ImageManager.backgroundAdjustedFor(host: host) {
            return ImageManager.loadImage(named: weatherType.defaultBackground)
            
            // all images are default
        } else {
            return ImageManager.loadImage(named: defaultBackgroundName)
        }
    }
    
    func saveToDisk() {
        DataModelPersistor.saveDataModel(model: self)
    }
    
}
