//
//  AppSettings.swift
//  InstaWeather
//
//  Created by Besher on 2018-09-27.
//  Copyright © 2018 Besher Al Maleh. All rights reserved.
//

import Foundation

struct AppSettings {
    
    private enum SettingKey: String {
        case ShowedFindMyLatteAd
        case DateForFindMylatteAd
    }
    
    static var DateForFindMylatteAd: Date? {
        get {
            if let object = UserDefaults.standard.object(forKey:
                SettingKey.DateForFindMylatteAd.rawValue) as? Date {
                return object
            } else {
                return nil
            }
        }
        set {
            let defaults = UserDefaults.standard
            let key = SettingKey.DateForFindMylatteAd.rawValue
            
            if let date = newValue {
                defaults.set(date, forKey: key)
            }
        }
    }
    
}
