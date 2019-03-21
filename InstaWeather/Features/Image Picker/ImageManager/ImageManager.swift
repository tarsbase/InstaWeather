//
//  Helper Functions.swift
//  InstaWeather
//
//  Created by Besher on 2018-10-07.
//  Copyright © 2018 Besher Al Maleh. All rights reserved.
//

import UIKit

var counter = 0

struct ImageManager {
    
    private init() {}
    
    static var documentsDirectory: URL = {
        let paths = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)
        return paths[0]
    }()
    
    static func oneBackgroundFor(host: PickerHostType) -> Bool {
        switch host {
        case .mainScreen:
            return AppSettings.mainscreenBackgrounds.oneBackgroundForAllConditions
            // TODO
            //        case .changeCity:
            //            return AppSettings.changeCityBackgrounds.adjusted
            //        case .weeklyForecast:
            //            return AppSettings.weeklyForecastBackgrounds.adjusted
            //        case .detailedForecast:
        //            return AppSettings.detailedForecastBackgrounds.adjusted
        default: return false
        }
    }
    
    static func customBackgroundFor(host: PickerHostType) -> Bool {
        switch host {
        case .mainScreen(let weather):
            return AppSettings.mainscreenBackgrounds.background(for: weather).customBackground
        case .changeCity:
            return AppSettings.changecityBackgrounds.adjusted
        case .weeklyForecast:
            return AppSettings.weeklyForecastBackgrounds.adjusted
        case .detailedForecast:
            return AppSettings.detailedForecastBackgrounds.adjusted
        }
    }
    
    static func backgroundAdjustedFor(host: PickerHostType) -> Bool {
        switch host {
        case .mainScreen:
            return AppSettings.mainscreenBackgrounds.adjusted
            // TODO
            //        case .changeCity:
            //            return AppSettings.changeCityBackgrounds.adjusted
            //        case .weeklyForecast:
            //            return AppSettings.weeklyForecastBackgrounds.adjusted
            //        case .detailedForecast:
        //            return AppSettings.detailedForecastBackgrounds.adjusted
        default: return false
        }
    }
    
    static func loadImage(named name: String) -> UIImage {
        if ImageLazyLoader.contains(name) {
            return ImageLazyLoader.getImage(for: name)
        } else {
            let image = UIImage(named: name)
            ImageLazyLoader.addImage(image, for: name)
            return image ?? UIImage()
        }
    }
    
    static func getBackgroundImage(for host: PickerHostType) -> UIImage? {
        
        // first check if image is already loaded in memory
        if ImageLazyLoader.contains(host) {
            return ImageLazyLoader.getImage(for: host)
        }
        // perform migration if needed
        if let image = getOldBackgroundWithMigration(for: host) { return image }
        let imageFileName = documentsDirectory.appendingPathComponent("\(host.description).png")
        do {
            let data = try Data(contentsOf: imageFileName)
            let image = UIImage(data: data)
            ImageLazyLoader.addImage(image, for: host)
            return image
        } catch {
            print(error.localizedDescription)
        }
        return nil
    }
    
    // MARK: - Dashboard (small size)
    
    static func getDashboardIconImage(for host: PickerHostType, size: CGSize) -> UIImage? {
        
        // first check if image is already loaded in memory
        if ImageLazyLoader.contains(host) {
            return ImageLazyLoader.getImage(for: host, scaledDown: true)
        }
        // perform migration if needed
        if let image = getOldBackgroundWithMigration(for: host) { return image.scaledToSafeThumbnailSize }
        let imageFileName = documentsDirectory.appendingPathComponent("\(host.description).png")
        do {
            let data = try Data(contentsOf: imageFileName)
            let image = UIImage(data: data)
            ImageLazyLoader.addImage(image, for: host)
            return image
        } catch {
            print(error.localizedDescription)
        }
        return nil
    }
    
    static func loadDashboardDefaultImage(weather: ImageWeatherType) -> UIImage {
        if ImageLazyLoader.contains(weather.defaultBackground) {
            return ImageLazyLoader.getImage(for: weather.defaultBackground, scaledDown: true)
        } else {
            let image = UIImage(named: weather.defaultBackground)
            ImageLazyLoader.addImage(image, for: weather.defaultBackground)
            return image ?? UIImage()
        }
    }
    
    // MARK: - Disk IO & Migration
    
    static func saveBackground(image: UIImage, for host: PickerHostType) {
        let imageFileName = documentsDirectory.appendingPathComponent("\(host.description).png")
        if let data = (image).pngData() {
            do {
                try data.write(to: imageFileName)
                ImageLazyLoader.addImage(image, for: host)
                print("Wrote new file: \(imageFileName.absoluteString)")
            } catch {
                print(error.localizedDescription)
            }
        }
    }
    
    private static func getOldBackgroundWithMigration(for host: PickerHostType) -> UIImage? {
        let url = documentsDirectory.appendingPathComponent("\(host.preMigrationName).png")
        let imageFileName = url
        defer {
            try? FileManager.default.removeItem(at: url)
        }
        do {
            let data = try Data(contentsOf: imageFileName)
            let image = UIImage(data: data)
            saveBackground(image: image ?? UIImage(), for: PickerHostType.setupAllFrom(host: host))
            ImageLazyLoader.addImage(image, for: host)
            return image
        } catch {
//            print(error.localizedDescription)
        }
        return nil
    }
    
    // MARK: - Performance improvement
    
    static func preloadAllImages() {
        
        for host in PickerHostType.allCases {
            _ = getBackgroundImage(for: host)
        }
        _ = ImageManager.getBackgroundImage(for: .mainScreen(.clear))
        _ = ImageManager.getBackgroundImage(for: .mainScreen(.all))
        _ = ImageManager.getBackgroundImage(for: .mainScreen(.cloudy))
        _ = ImageManager.getBackgroundImage(for: .mainScreen(.snowy))
        _ = ImageManager.getBackgroundImage(for: .mainScreen(.stormy))
        _ = ImageManager.getBackgroundImage(for: .mainScreen(.rainy))
        
        _ = ImageManager.getBackgroundImage(for: .weeklyForecast(.clear))
        _ = ImageManager.getBackgroundImage(for: .weeklyForecast(.all))
        _ = ImageManager.getBackgroundImage(for: .weeklyForecast(.cloudy))
        _ = ImageManager.getBackgroundImage(for: .weeklyForecast(.snowy))
        _ = ImageManager.getBackgroundImage(for: .weeklyForecast(.stormy))
        _ = ImageManager.getBackgroundImage(for: .weeklyForecast(.rainy))
        
        _ = ImageManager.getBackgroundImage(for: .detailedForecast(.clear))
        _ = ImageManager.getBackgroundImage(for: .detailedForecast(.all))
        _ = ImageManager.getBackgroundImage(for: .detailedForecast(.cloudy))
        _ = ImageManager.getBackgroundImage(for: .detailedForecast(.snowy))
        _ = ImageManager.getBackgroundImage(for: .detailedForecast(.stormy))
        _ = ImageManager.getBackgroundImage(for: .detailedForecast(.rainy))
        
        _ = ImageManager.getBackgroundImage(for: .changeCity(.clear))
        _ = ImageManager.getBackgroundImage(for: .changeCity(.all))
        _ = ImageManager.getBackgroundImage(for: .changeCity(.cloudy))
        _ = ImageManager.getBackgroundImage(for: .changeCity(.snowy))
        _ = ImageManager.getBackgroundImage(for: .changeCity(.stormy))
        _ = ImageManager.getBackgroundImage(for: .changeCity(.rainy))
    }
    
    static var potentialBackgrounds: [UIImage] {
        var backgrounds = [UIImage]()
        
        let names = [
            "bg1clear", "bg1clearnight", "bg1cloudy2night", "bg1fog", "bg1snow", "bg2clear", "bg2clearnight", "bg2cloudy", "bg2cloudy2night", "bg2fog", "bg2snow", "bg3clear", "bglight_rain", "bgstorm"
        ]
        
        for _ in 0...0 {
            for name in names.shuffled() {
                if let image = UIImage(named: name) {
                    backgrounds.append(image)
                }
            }
        }
        
        return backgrounds
    }
    
    
}

