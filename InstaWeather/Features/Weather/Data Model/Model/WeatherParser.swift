//
//  WeatherParser.swift
//  InstaWeather
//
//  Created by Besher on 2019-05-28.
//  Copyright © 2019 Besher Al Maleh. All rights reserved.
//

import Foundation

enum WeatherParser {
    
    static func parseWeeklyData(model: WeatherDataModel) -> [(tag: Int, day: String, icon: Int, temperature: String)] {
        var tag = 0
        var output = [(tag: Int, day: String, icon: Int, temperature: String)]()
        let weekdayObjects = model.weekdayObjects
        for (index, dayObject) in weekdayObjects.enumerated() {
            output.append(parseDailyData(dayObject, tag: tag, model: model, index: index))
            tag += 1
        }
        return output
    }
    
    private static func parseDailyData(_ object: ForecastObject, tag: Int, model: WeatherDataModel, index: Int)
        -> (tag: Int, day: String, icon: Int, temperature: String) {
        let dayObject = object
        var dayOfWeek = ""
        switch dayObject.dayOfWeek {
        case 1: dayOfWeek = "SUN"
        case 2: dayOfWeek = "MON"
        case 3: dayOfWeek = "TUE"
        case 4: dayOfWeek = "WED"
        case 5: dayOfWeek = "THU"
        case 6: dayOfWeek = "FRI"
        default: dayOfWeek = "SAT"
        }
        var temp = ""
        
        let minTemp = model.minTempForObject(index)
        let maxTemp = model.maxTempForObject(index)
        
        if minTemp == 99 {
            temp = "N/A"
        } else {
            temp = "↑ \(maxTemp) ↓ \(minTemp)"
        }
        return (tag: tag, day: dayOfWeek, icon: dayObject.condition, temperature: temp)
    }
}
