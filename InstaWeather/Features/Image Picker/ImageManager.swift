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
    
    static func loadDashboardDefaultImage(named name: String) -> UIImage {
        if ImageLazyLoader.contains(name) {
            return ImageLazyLoader.getImage(for: name, scaledDown: true)
        } else {
            let image = UIImage(named: name)
            ImageLazyLoader.addImage(image, for: name)
            return image ?? UIImage()
        }
    }
    
//    static func getBackgroundImageAsync(for host: PickerHostType, completion: @escaping ((UIImage?) -> Void)) {
//        DispatchQueue.global(qos: .userInitiated).async {
//            // first check if image is already loaded in memory
//            if ImageLazyLoader.contains(host) {
//                completion(ImageLazyLoader.getImage(for: host))
//                return
//            }
//            // perform migration if needed
//            if let image = getOldBackgroundWithMigration(for: host) { completion(image); return }
//            let imageFileName = documentsDirectory.appendingPathComponent("\(host.description).png")
//            do {
//                let data = try Data(contentsOf: imageFileName)
//                let image = UIImage(data: data)
//                ImageLazyLoader.addImage(image, for: host)
//                completion(image)
//                return
//            } catch {
//                print(error.localizedDescription)
//            }
//            completion(nil)
//            return
//        }
//    }
    
    static func setBackground(image: UIImage, for host: PickerHostType) {
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
            setBackground(image: image ?? UIImage(), for: PickerHostType.setupClearFrom(host: host))
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
    }
}

