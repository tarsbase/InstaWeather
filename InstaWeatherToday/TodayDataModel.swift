//
//  TodayDataModel.swift
//  InstaWeatherToday
//
//  Created by Besher on 2018-05-22.
//  Copyright © 2018 Besher Al Maleh. All rights reserved.
//

import Foundation

struct TodayDataModel {
    let defaults = UserDefaults(suiteName: "group.com.besher.InstaWeather")
    private var currentTemp = 0, maxTemp = 0, minTemp = 0, summary = "", city = "", icon = ""
    mutating func updateTemperature(currentTemp: Int, maxTemp: Int, minTemp: Int, summary: String, icon: String) {
        self.currentTemp = currentTemp
        self.maxTemp = maxTemp
        self.minTemp = minTemp
        self.summary = summary
        self.icon = icon
        defaults?.setValue(currentTemp, forKey: "todayCurrentTemp")
        defaults?.setValue(maxTemp, forKey: "todayMaxTemp")
        defaults?.setValue(minTemp, forKey: "todayMinTemp")
        defaults?.setValue(summary, forKey: "todaySummary")
        defaults?.setValue(icon, forKey: "todayIcon")
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
    func getIcon() -> String {
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
    mutating func loadSavedData() {
        guard let savedCurrentTemp = defaults?.integer(forKey: "todayCurrentTemp"),
              let savedMaxTemp = defaults?.integer(forKey: "todayMaxTemp"),
              let savedMinTemp = defaults?.integer(forKey: "todayMinTemp"),
              let savedSummary = defaults?.string(forKey: "todaySummary"),
              let savedCity = defaults?.string(forKey: "todayCity"),
              let savedIcon = defaults?.string(forKey: "todayIcon")
              else { return }
        currentTemp = savedCurrentTemp
        maxTemp = savedMaxTemp
        minTemp = savedMinTemp
        summary = savedSummary
        city = savedCity
        icon = savedIcon
    }
}
