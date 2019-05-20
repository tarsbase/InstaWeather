//
//  ForecastObject.swift
//  InstaWeather
//
//  Created by Besher on 2018-01-30.
//  Copyright © 2018 Besher Al Maleh. All rights reserved.
//

import Foundation
struct ForecastObject {
    
    var temperatureCelsius = 0
    var minTempCelsius = 0
    var maxTempCelsius = 0

    let date: String
    let condition: Int
    var sunrise = 5
    var sunset = 19
    var formatter: DateFormatter {
        return OptimizedDateFormatter.getFormatter(.short)
    }
    
    var currentDay: Int {
        let currentDate = formatter.string(from: Date())
        return getDayOfWeek(day: (currentDate)) ?? 0
    }
    
    var dayOfWeek: Int {
        guard date != "" else { return 0 }
        let start = date.startIndex
        let end = date.index(start, offsetBy: 9)
        let range = date[start...end]
        return getDayOfWeek(day: String(range)) ?? 0
    }
    
    var time: String {
        return formatAmPm(date: date)
    }
    
    init(date: String, condition: Int, maxTemp: Int, minTemp: Int) {
        self.date = date
        self.condition = condition
        self.maxTempCelsius = maxTemp
        self.minTempCelsius = minTemp
    }
    
    func formatAmPm(date: String) -> String {
        var formattedDate = ""
        var start = date.startIndex
        start = date.index(start, offsetBy: 11)
        let end = date.index(start, offsetBy: 1)
        if date[start] == "0" {
            formattedDate = String(date[end])
        } else {
            formattedDate = String(date[start...end])
        }
        var AMPM = "PM"
        if let int = Int(formattedDate) {
            if int < 12 { AMPM = "AM" }
        }
        if date[end] == "0" {
            formattedDate = "12"
        }
        switch formattedDate {
        case "0": formattedDate = "12"
        case "15", "18", "21": formattedDate = String(Int(formattedDate)! - 12)
        default: break
        }
        return "\(formattedDate) \(AMPM)"
    }
    
    
    var timeDigits: Int {
        let digits = Int(time.filter { Int(String($0)) != nil }) ?? 0
        if time.suffix(2) == "PM" && digits != 12 {
            return digits + 12
        } else if time.suffix(2) == "AM" && digits == 12 {
            return 0
        }
        return digits
    }
    
    func getDayOfWeek(day: String) -> Int? {
        guard let todayDate = formatter.date(from: day) else { return nil }
        let myCalendar = Calendar(identifier: .gregorian)
        let weekDay = myCalendar.component(.weekday, from: todayDate)
        return weekDay
    }
}
