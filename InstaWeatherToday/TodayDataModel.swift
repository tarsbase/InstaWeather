//
//  TodayDataModel.swift
//  InstaWeatherToday
//
//  Created by Besher on 2018-05-22.
//  Copyright © 2018 Besher Al Maleh. All rights reserved.
//

import Foundation
import SwiftyJSON

struct TodayDataModel {
    let defaults = UserDefaults(suiteName: "group.com.besher.InstaWeather")
    private var currentTemp = 0, maxTemp = 0, minTemp = 0, summary = "", city = "", icon = "", percipProbability = 0.0, dailySummary = ""
    
    struct DailyForecastItem {
        var time = 0, icon = "", precip = 0.0, temp = 0
    }
    
    private var dailyForecastItems: [DailyForecastItem] = [DailyForecastItem]()
    
    mutating func updateWith(_ json: JSON, saveData: Bool = true) {
        currentTemp = json["currently"]["temperature"].intValue
        maxTemp = json["daily"]["data"][0]["apparentTemperatureHigh"].intValue
        minTemp = json["daily"]["data"][0]["apparentTemperatureLow"].intValue
        summary = json["minutely"]["summary"].stringValue
        icon = convertIcon(from: json["minutely"]["icon"].stringValue)
        percipProbability = json["daily"]["data"][0]["precipProbability"].doubleValue
        dailySummary = json["daily"]["data"][0]["summary"].stringValue
        
        dailyForecastItems.removeAll()
        for i in stride(from: 2, through: 10, by: 2) {
            let time = json["hourly"]["data"][i]["time"].intValue
            let icon = convertIcon(from: json["hourly"]["data"][i]["icon"].stringValue)
            let precip = json["hourly"]["data"][i]["precipProbability"].doubleValue
            let temp = json["hourly"]["data"][i]["apparentTemperature"].intValue
            let forecastItem = DailyForecastItem(time: time, icon: icon, precip: precip, temp: temp)
            dailyForecastItems.append(forecastItem)
        }
        if saveData {
            if let jsonString = json.rawString() {
                defaults?.set(jsonString, forKey: "JASON")
            }
        }
    }
    
    mutating func updateCity(to city: String) {
        self.city = city
        defaults?.setValue(city, forKey: "todayCity")
    }
    func getCurrentTemp() -> Int {
        return currentTemp
    }
    func getMaxTemp() -> Int {
        return maxTemp
    }
    func getMinTemp() -> Int {
        return minTemp
    }
    func getCity() -> String {
        return city
    }
    func getSummary() -> String {
        return summary
    }
    func getPercipProbability() -> Double {
        return percipProbability
    }
    func getDailySummary() -> String {
        return dailySummary
    }
    func getIcon() -> String {
        return icon
    }
    func getForecastItems() -> [DailyForecastItem] {
        return dailyForecastItems
    }
    mutating func loadSavedData() {
        guard let stringJSON = defaults?.string(forKey: "JASON") else { return }
        updateWith(JSON.init(parseJSON: stringJSON), saveData: false)
    }
    func convertIcon(from icon: String) -> String {
        switch icon {
        case "clear-day": return "clear"
        case "clear-night": return "clearnight"
        case "rain": return "shower3"
        case "snow": return "snow"
        case "sleet": return "sleet"
        case "wind": return "wind"
        case "fog": return "fog"
        case "cloudy": return "overcast"
        case "partly-cloudy-day": return "cloudy2"
        case "partly-cloudy-night": return "cloudy2night"
        default: return "clear"
        }
    }
}
