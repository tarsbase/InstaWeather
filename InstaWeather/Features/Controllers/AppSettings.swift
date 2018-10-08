//
//  AppSettings.swift
//  InstaWeather
//
//  Created by Besher on 2018-09-27.
//  Copyright © 2018 Besher Al Maleh. All rights reserved.
//

import Foundation

class AppSettings: NSObject {
    
    private enum SettingKey: String {
        case appLaunchCount
        case ShowedFindMyLatteAd
        case DateForFindMylatteAd
        
        case mainscreenCustomImage
        case mainscreenBlurSetting
        case mainscreenBrightnessSetting
        
        case changecityCustomImage
        case changecityBlurSetting
        case changecityBrightnessSetting
        
        case weeklyForecastCustomImage
        case weeklyForecastBlurSetting
        case weeklyForecastBrightnessSetting
        
        case detailedForecastCustomImage
        case detailedForecastBlurSetting
        case detailedForecastBrightnessSetting
        
        case hideCameras
    }
    
    static var appLaunchCount: Int! {
        get {
            print(UserDefaults.standard.integer(forKey:
                SettingKey.appLaunchCount.rawValue))
            return UserDefaults.standard.integer(forKey:
                SettingKey.appLaunchCount.rawValue)
        }
        set {
            let defaults = UserDefaults.standard
            let key = SettingKey.appLaunchCount.rawValue
            if let count = newValue {
                defaults.set(count, forKey: key)
            }
        }
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
    
    static var mainscreenCustomImage: Bool! {
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
    
    static var changecityCustomImage: Bool! {
        get {
            return UserDefaults.standard.bool(forKey: SettingKey.changecityCustomImage.rawValue)
        }
        set {
            let defaults = UserDefaults.standard
            let key = SettingKey.changecityCustomImage.rawValue
            if let custom = newValue {
                defaults.set(custom, forKey: key)
            } else {
                defaults.removeObject(forKey: key)
            }
        }
    }
    
    static var changecityBlurSetting: Float! {
        get {
            return UserDefaults.standard.float(forKey:
                SettingKey.changecityBlurSetting.rawValue)
        }
        set {
            let defaults = UserDefaults.standard
            let key = SettingKey.changecityBlurSetting.rawValue
            
            if let blur = newValue {
                defaults.set(blur, forKey: key)
            } else {
                defaults.removeObject(forKey: key)
            }
        }
    }
    
    static var changecityBrightnessSetting: Float! {
        get {
            if let brightness = UserDefaults.standard.object(forKey:
                SettingKey.changecityBrightnessSetting.rawValue) as? Float {
                return brightness
            } else {
                return 0.7
            }
        }
        set {
            let defaults = UserDefaults.standard
            let key = SettingKey.changecityBrightnessSetting.rawValue
            
            if let brightness = newValue {
                defaults.set(brightness, forKey: key)
            } else {
                defaults.removeObject(forKey: key)
            }
        }
    }
    
    static var detailedForecastCustomImage: Bool! {
        get {
            return UserDefaults.standard.bool(forKey: SettingKey.detailedForecastCustomImage.rawValue)
        }
        set {
            let defaults = UserDefaults.standard
            let key = SettingKey.detailedForecastCustomImage.rawValue
            if let custom = newValue {
                defaults.set(custom, forKey: key)
            } else {
                defaults.removeObject(forKey: key)
            }
        }
    }
    
    static var detailedForecastBlurSetting: Float! {
        get {
            return UserDefaults.standard.float(forKey:
                SettingKey.detailedForecastBlurSetting.rawValue)
        }
        set {
            let defaults = UserDefaults.standard
            let key = SettingKey.detailedForecastBlurSetting.rawValue
            
            if let blur = newValue {
                defaults.set(blur, forKey: key)
            } else {
                defaults.removeObject(forKey: key)
            }
        }
    }
    
    static var detailedForecastBrightnessSetting: Float! {
        get {
            if let brightness = UserDefaults.standard.object(forKey:
                SettingKey.detailedForecastBrightnessSetting.rawValue) as? Float {
                return brightness
            } else {
                return 0.8
            }
        }
        set {
            let defaults = UserDefaults.standard
            let key = SettingKey.detailedForecastBrightnessSetting.rawValue
            
            if let brightness = newValue {
                defaults.set(brightness, forKey: key)
            } else {
                defaults.removeObject(forKey: key)
            }
        }
    }
    
    static var weeklyForecastCustomImage: Bool! {
        get {
            return UserDefaults.standard.bool(forKey: SettingKey.weeklyForecastCustomImage.rawValue)
        }
        set {
            let defaults = UserDefaults.standard
            let key = SettingKey.weeklyForecastCustomImage.rawValue
            if let custom = newValue {
                defaults.set(custom, forKey: key)
            } else {
                defaults.removeObject(forKey: key)
            }
        }
    }
    
    static var weeklyForecastBlurSetting: Float! {
        get {
            return UserDefaults.standard.float(forKey:
                SettingKey.weeklyForecastBlurSetting.rawValue)
        }
        set {
            let defaults = UserDefaults.standard
            let key = SettingKey.weeklyForecastBlurSetting.rawValue
            
            if let blur = newValue {
                defaults.set(blur, forKey: key)
            } else {
                defaults.removeObject(forKey: key)
            }
        }
    }
    
    static var weeklyForecastBrightnessSetting: Float! {
        get {
            if let brightness = UserDefaults.standard.object(forKey:
                SettingKey.weeklyForecastBrightnessSetting.rawValue) as? Float {
                return brightness
            } else {
                return 0.8
            }
        }
        set {
            let defaults = UserDefaults.standard
            let key = SettingKey.weeklyForecastBrightnessSetting.rawValue
            
            if let brightness = newValue {
                defaults.set(brightness, forKey: key)
            } else {
                defaults.removeObject(forKey: key)
            }
        }
    }
    
    @objc dynamic static var hideCameras: Bool {
        get {
            return UserDefaults.standard.bool(forKey: SettingKey.hideCameras.rawValue)
        }
        set {
            let defaults = UserDefaults.standard
            let key = SettingKey.hideCameras.rawValue
                defaults.set(newValue, forKey: key)
        }
    }
}
