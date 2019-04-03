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
        
        case mainscreenCustomImage // keep for migration
        case mainscreenBackgrounds
        
        case changecityBackgrounds
        case changecityCustomImage
        
        case weeklyForecastBackgrounds
        case weeklyForecastCustomImage
        
        case detailedForecastBackgrounds
        case detailedForecastCustomImage
        
        case hideCameras
    }
    
    private static var alreadySubmittedReviewKey: String {
        return "alreadySubmittedReview\(LiveInstance.currentVersion)"
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
    
    static var alreadySubmittedReview: Bool! {
        get {
            if let object = UserDefaults.standard.object(forKey:
                alreadySubmittedReviewKey) as? Bool {
                return object
            } else {
                return false
            }
        }
        set {
            let defaults = UserDefaults.standard
            let key = alreadySubmittedReviewKey
            
            if let alreadySubmittedReview = newValue {
                defaults.set(alreadySubmittedReview, forKey: key)
            }
        }
    }
    
    static var DateForMyOtherApp: Date? {
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
    
    static var mainscreenBackgrounds: SavedBackgrounds! {
        get {
            let defaults = UserDefaults.standard
            let oldKey = SettingKey.mainscreenCustomImage.rawValue
            let newKey = SettingKey.mainscreenBackgrounds.rawValue
            
            // perform migration
            if let oldData = migrationCheckForKey(oldKey, newKey: newKey) {
                return oldData
                
                // otherwise proceed as normal
            } else if let data = defaults.object(forKey: newKey) as? Data {
                do {
                    let backgrounds = try JSONDecoder().decode(SavedBackgrounds.self, from: data)
                    return backgrounds
                } catch {
                    print(error.localizedDescription)
                }
            }
            return SavedBackgrounds()
        }
        set {
            let defaults = UserDefaults.standard
            let key = SettingKey.mainscreenBackgrounds.rawValue
            if let backgrounds = newValue, let data = try? JSONEncoder().encode(backgrounds) {
                defaults.set(data, forKey: key)
            }
        }
    }
    
    static var changecityBackgrounds: SavedBackgrounds! {
        get {
            let defaults = UserDefaults.standard
            let oldKey = SettingKey.changecityCustomImage.rawValue
            let newKey = SettingKey.changecityBackgrounds.rawValue
            
            // perform migration
            if let oldData = migrationCheckForKey(oldKey, newKey: newKey) {
                return oldData
                
                // otherwise proceed as normal
            } else if let data = defaults.object(forKey: newKey) as? Data {
                if let backgrounds = try? JSONDecoder().decode(SavedBackgrounds.self, from: data) {
                    return backgrounds
                }
            }
            return SavedBackgrounds()
        }
        set {
            let defaults = UserDefaults.standard
            let key = SettingKey.changecityBackgrounds.rawValue
            if let backgrounds = newValue, let data = try? JSONEncoder().encode(backgrounds) {
                defaults.set(data, forKey: key)
            }
        }
    }
    
    static var detailedForecastBackgrounds: SavedBackgrounds! {
        get {
            let defaults = UserDefaults.standard
            let oldKey = SettingKey.detailedForecastCustomImage.rawValue
            let newKey = SettingKey.detailedForecastBackgrounds.rawValue
            
            // perform migration
            if let oldData = migrationCheckForKey(oldKey, newKey: newKey) {
                return oldData
                
                // otherwise proceed as normal
            } else if let data = defaults.object(forKey: newKey) as? Data {
                if let backgrounds = try? JSONDecoder().decode(SavedBackgrounds.self, from: data) {
                    return backgrounds
                }
            }
            return SavedBackgrounds()
        }
        set {
            let defaults = UserDefaults.standard
            let key = SettingKey.detailedForecastBackgrounds.rawValue
            if let backgrounds = newValue, let data = try? JSONEncoder().encode(backgrounds) {
                defaults.set(data, forKey: key)
            }
        }
    }
    
    static var weeklyForecastBackgrounds: SavedBackgrounds! {
        get {
            let defaults = UserDefaults.standard
            let oldKey = SettingKey.weeklyForecastCustomImage.rawValue
            let newKey = SettingKey.weeklyForecastBackgrounds.rawValue
            
            // perform migration
            if let oldData = migrationCheckForKey(oldKey, newKey: newKey) {
                return oldData
                
                // otherwise proceed as normal
            } else if let data = defaults.object(forKey: newKey) as? Data {
                if let backgrounds = try? JSONDecoder().decode(SavedBackgrounds.self, from: data) {
                    return backgrounds
                }
            }
            return SavedBackgrounds()
        }
        set {
            let defaults = UserDefaults.standard
            let key = SettingKey.weeklyForecastBackgrounds.rawValue
            if let backgrounds = newValue, let data = try? JSONEncoder().encode(backgrounds) {
                defaults.set(data, forKey: key)
            }
        }
    }
    
    static func migrationCheckForKey(_ key: String, newKey: String) -> SavedBackgrounds? {
        let defaults = UserDefaults.standard
        if let _ = defaults.object(forKey: key) as? Bool {
            // perform migration
            var newBackgrounds = SavedBackgrounds()
            newBackgrounds.allWeather.customBackground = true
            defaults.removeObject(forKey: key)
            
            if let data = try? JSONEncoder().encode(newBackgrounds) {
                defaults.set(data, forKey: newKey)
            }
            
            return newBackgrounds
        } else {
            return nil
        }
    }
    
    static var hideCameras: Bool {
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
