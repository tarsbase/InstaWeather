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
    
    mutating func setSettings(_ newSettings: Background, for weather: ImageWeatherType) {
        switch weather {
        case .all: allWeather = newSettings
        case .clear: clearWeather = newSettings
        case .cloudy: cloudyWeather = newSettings
        case .rainy: rainyWeather = newSettings
        case .stormy: stormyWeather = newSettings
        case .snowy: snowyWeather = newSettings
        }
    }
}

struct Background: Codable {
    var customBackground: Bool = false
    var brightnessSetting: Float = 0.8
    var blurSetting: Float = 0
    var enableShadows: Bool = true
//    var textColor: UIColor = .white
}
