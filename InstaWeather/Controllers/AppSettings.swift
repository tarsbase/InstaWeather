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
        case mainscreenCustomImage
        case mainscreenBlurSetting
        case mainscreenBrightnessSetting
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
    
    static var customImageMain: Bool! {
        get {
            return UserDefaults.standard.bool(forKey: SettingKey.mainscreenCustomImage.rawValue)
        }
        set {
            let defaults = UserDefaults.standard
            let key = SettingKey.mainscreenCustomImage.rawValue
            if let custom = newValue {
                defaults.set(custom, forKey: key)
            } else {
                defaults.removeObject(forKey: key)
            }
        }
    }
    
    static var mainscreenBlurSetting: Float! {
        get {
            return UserDefaults.standard.float(forKey:
                SettingKey.mainscreenBlurSetting.rawValue)
        }
        set {
            let defaults = UserDefaults.standard
            let key = SettingKey.mainscreenBlurSetting.rawValue
            
            if let blur = newValue {
                defaults.set(blur, forKey: key)
            } else {
                defaults.removeObject(forKey: key)
            }
        }
    }
    
    static var mainscreenBrightnessSetting: Float! {
        get {
            if let brightness = UserDefaults.standard.object(forKey:
                SettingKey.mainscreenBrightnessSetting.rawValue) as? Float {
                return brightness
            } else {
                return 0.8
            }
        }
        set {
            let defaults = UserDefaults.standard
            let key = SettingKey.mainscreenBrightnessSetting.rawValue
            
            if let brightness = newValue {
                defaults.set(brightness, forKey: key)
            } else {
                defaults.removeObject(forKey: key)
            }
        }
    }
    
}
