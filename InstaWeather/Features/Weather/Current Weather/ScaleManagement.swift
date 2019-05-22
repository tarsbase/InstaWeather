//
//  ScaleManager.swift
//  InstaWeather
//
//  Created by Besher on 2019-05-21.
//  Copyright © 2019 Besher Al Maleh. All rights reserved.
//

import UIKit

enum ScaleManagement {
    
    static func saveScale(index: Int) {
        if let defaults = UserDefaults(suiteName: "group.com.besher.InstaWeather") {
            defaults.set(index, forKey: "tempScale")
        }
    }
    
    static func loadScale(control: UISegmentedControl, evaluateSegment: () -> Void) { // takes migration into account
        if let defaults = UserDefaults(suiteName: "group.com.besher.InstaWeather") {
            var scale: Int = 0
            if let loadOBject = UserDefaults.standard.object(forKey: "tempScale") as? Int {
                scale = loadOBject
                control.selectedSegmentIndex = scale
                evaluateSegment()
                UserDefaults.standard.removeObject(forKey: "tempScale")
            }
            if let loadObject = defaults.object(forKey: "tempScale") as? Int {
                scale = loadObject
            }
            control.selectedSegmentIndex = scale
            evaluateSegment()
        }
    }
}
