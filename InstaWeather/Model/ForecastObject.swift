//
//  ForecastObject.swift
//  InstaWeather
//
//  Created by Besher on 2018-01-30.
//  Copyright © 2018 Besher Al Maleh. All rights reserved.
//

import Foundation
struct ForecastObject: CustomStringConvertible {

    let date: String
    let condition: Int
    let maxTemp: Int
    let minTemp: Int

    var currentDay: Int {
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy-MM-dd"
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
    
    var description : String {
        return "Date: \(date)\n Condition: \(condition)\n maxTemp: \(maxTemp)\n minTemp: \(minTemp)"
    }
    
    func getDayOfWeek(day: String) -> Int? {
        let formatter  = DateFormatter()
        formatter.dateFormat = "yyyy-MM-dd"
        guard let todayDate = formatter.date(from: day) else { return nil }
        let myCalendar = Calendar(identifier: .gregorian)
        let weekDay = myCalendar.component(.weekday, from: todayDate)
        return weekDay
    }
}
