//
//  LiveInstance.swift
//  InstaWeather
//
//  Created by Besher on 2019-02-13.
//  Copyright © 2019 Besher Al Maleh. All rights reserved.
//

import Foundation

struct LiveInstance {
    
    static var currentVersion: String {
        return Bundle.main.infoDictionary!["CFBundleShortVersionString"] as? String ?? "1"
    }
    
    static let fullAppStoreURL = "https://itunes.apple.com/us/app/instaweather/id1341392811?ls=1&mt=8"
    static let shortAppStoreURL = "http://bit.ly/instaWeather"
    
    static var simulatorEnvironment: Bool {
        var isSimulator = false
        #if targetEnvironment(simulator)
        isSimulator = true
        #endif
        return isSimulator
    }
}
