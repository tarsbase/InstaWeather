//
//  SavedBackground.swift
//  InstaWeather
//
//  Created by Besher on 2019-02-08.
//  Copyright © 2019 Besher Al Maleh. All rights reserved.
//

import UIKit

struct SavedBackgrounds: Codable {
    
    private var allWeather = Background(), clearWeather = Background(), cloudyWeather = Background()
    private var rainyWeather = Background(), stormyWeather = Background(), snowyWeather = Background()
    
    var backgrounds: [Background] {
        return [allWeather, clearWeather, cloudyWeather, rainyWeather, stormyWeather, snowyWeather]
    }
    
    var adjusted: Bool {
        return backgrounds.contains(where: { (background) -> Bool in
            background.customBackground == true
        })
    }
    
    func background(for weather: ImageWeatherType) -> Background {
        switch weather {
        case .all: return allWeather
        case .clear: return clearWeather
        case .cloudy: return cloudyWeather
        case .rainy: return rainyWeather
        case .stormy: return stormyWeather
        case .snowy: return snowyWeather
        }
    }
    
    mutating func setSettings(_ newSettings: (image: Bool, blur: Float, brightness: Float), for weather: ImageWeatherType) {
        switch weather {
        case .all: allWeather.allSettings = newSettings
        case .clear: clearWeather.allSettings = newSettings
        case .cloudy: cloudyWeather.allSettings = newSettings
        case .rainy: rainyWeather.allSettings = newSettings
        case .stormy: stormyWeather.allSettings = newSettings
        case .snowy: snowyWeather.allSettings = newSettings
        }
    }
}

struct Background: Codable {
    var customBackground: Bool = false
    var brightnessSetting: Float = 0.8
    var blurSetting: Float = 0
    var allSettings: (image: Bool, blur: Float, brightness: Float) {
        get { return (customBackground, brightnessSetting, blurSetting) }
        set { (customBackground, brightnessSetting, blurSetting) = newValue }
    }
}
