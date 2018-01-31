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
        return getDayOfWeek(today: (currentDate)) ?? 0
    }
    var dayOfWeek: Int {
        let start = date.startIndex
        let end = date.index(start, offsetBy: 9)
        let range = date[start...end]
        return getDayOfWeek(today: String(range)) ?? 0
    }
    
    var description : String {
        return "Date: \(date)\n Condition: \(condition)\n maxTemp: \(maxTemp)\n minTemp: \(minTemp)"
    }
    
    func getDayOfWeek(today: String) -> Int? {
        let formatter  = DateFormatter()
        formatter.dateFormat = "yyyy-MM-dd"
        guard let todayDate = formatter.date(from: today) else { return nil }
        let myCalendar = Calendar(identifier: .gregorian)
        let weekDay = myCalendar.component(.weekday, from: todayDate)
        return weekDay
    }
}
