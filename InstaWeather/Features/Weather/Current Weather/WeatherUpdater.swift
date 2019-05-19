//
//  WeatherUpdater.swift
//  InstaWeather
//
//  Created by Besher on 2019-05-19.
//  Copyright © 2019 Besher Al Maleh. All rights reserved.
//

import UIKit

class WeatherUpdater {
    
    private var loadAllWeatherPages: (() -> Void)?
    private var pagesAreLoaded = false
    
    var reconnectTimer: Timer?
    
    init() {
        if let delegate = UIApplication.shared.delegate as? AppDelegate {
            delegate.weatherUpdater = self
        }
    }
    
    func setup(loadPages: (() -> Void)?) {
        self.loadAllWeatherPages = loadPages
    }
    
    func loadAllPages() {
        if pagesAreLoaded == false {
            pagesAreLoaded = true
            loadAllWeatherPages?()
        }
    }
    
    func deactivateTimer() {
        reconnectTimer?.invalidate()
        reconnectTimer = nil
        print("Sunsetting the timer")
    }
    
}
