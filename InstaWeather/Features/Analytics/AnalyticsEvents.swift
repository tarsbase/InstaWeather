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
        guard !LiveInstance.simulatorEnvironment && !LiveInstance.debugMode else { return }
        Analytics.logEvent(event.rawValue, parameters: parameters)
    }
    
    static func setUserPropertyForDevice() {
        let deviceType = Display.pad ? "iPad" : "iPhone"
        Analytics.setUserProperty(deviceType, forName: "device_type")
    }
}
