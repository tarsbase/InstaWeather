//
//  SavedBackground.swift
//  InstaWeather
//
//  Created by Besher on 2019-02-08.
//  Copyright © 2019 Besher Al Maleh. All rights reserved.
//

import UIKit

struct SavedBackgrounds: Codable {
    
    var allWeather = Background(), clearWeather = Background(), cloudyWeather = Background()
    var rainyWeather = Background(), stormyWeather = Background(), snowyWeather = Background()
    
}

struct Background: Codable {
    var customBackground: Bool = false
    var brightnessSetting: Float = 0
    var blurSetting: Float = 0
    var allSettings: (image: Bool, blur: Float, brightness: Float) {
        get { return (customBackground, brightnessSetting, blurSetting) }
        set { (customBackground, brightnessSetting, blurSetting) = newValue }
    }
}
