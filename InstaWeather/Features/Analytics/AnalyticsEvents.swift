//
//  Analytics.swift
//  InstaWeather
//
//  Created by Besher on 2019-02-18.
//  Copyright © 2019 Besher Al Maleh. All rights reserved.
//

import Foundation
import Firebase

struct AnalyticsEvents {
    
    private init() {}
    
    static func logEvent(_ event: Event, parameters: [String: Any]? = nil) {
//        guard !LiveInstance.simulatorEnvironment else { return }
        Analytics.logEvent(event.rawValue, parameters: parameters)
    }
    
    static func LogEvent(_ event: Event, controllerString: String) {
        let controllerName = getControllerFromString(controllerString)
        logEvent(event, parameters: ["controller": controllerName])
    }
    
    private static func getControllerFromString(_ string: String) -> String {
        if string.contains("Detailed") {
            return "DetailedWeatherViewController"
        } else if string.contains("Forecast") {
            return "WeeklyWeatherViewController"
        } else if string.contains("Change") {
            return "ChangeCityViewController"
        } else if string.contains("Weather") {
            return "MainViewController"
        }
        return string
    }
    
    static func setUserPropertyForDevice() {
        let deviceType = Display.pad ? "iPad" : "iPhone"
        Analytics.setUserProperty(deviceType, forName: "device_type")
    }
}
