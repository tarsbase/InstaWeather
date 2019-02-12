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

struct Background {
    
    var customBackground: Bool = false
    var brightnessSetting: Float = 0.8
    var blurSetting: Float = 0
    var enableShadows: Bool = true
    var textColor: UIColor = .white
    var textBrightness: Float = 1
}

extension Background: Codable {
    
    enum CodingKeys: String, CodingKey {
        case background
        case brightness
        case blur
        case shadows
        case color
        case textBrightness
    }
    
    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        
        customBackground = try container.decode(Bool.self, forKey: .background)
        brightnessSetting = try container.decode(Float.self, forKey: .brightness)
        blurSetting = try container.decode(Float.self, forKey: .blur)
        enableShadows = try container.decode(Bool.self, forKey: .shadows)
        textBrightness = try container.decode(Float.self, forKey: .textBrightness)
        
        let colorData = try container.decode(Data.self, forKey: .color)
        textColor = try NSKeyedUnarchiver.unarchiveTopLevelObjectWithData(colorData) as? UIColor ?? UIColor.white
//        NSLog("Decoding \(textBrightness)")
    }
    
    func encode(to encoder: Encoder) throws {
        
        var container = encoder.container(keyedBy: CodingKeys.self)
        try container.encode(customBackground, forKey: .background)
        try container.encode(brightnessSetting, forKey: .brightness)
        try container.encode(blurSetting, forKey: .blur)
        try container.encode(enableShadows, forKey: .shadows)
        try container.encode(textBrightness, forKey: .textBrightness)
        
        if #available(iOSApplicationExtension 11.0, *) {
            let colorData = try NSKeyedArchiver.archivedData(withRootObject: textColor, requiringSecureCoding: false)
//            NSLog("Encoding \(textBrightness)")
            try container.encode(colorData, forKey: .color)
        }
    }
}
