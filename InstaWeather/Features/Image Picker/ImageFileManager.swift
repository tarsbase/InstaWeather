//
//  Helper Functions.swift
//  InstaWeather
//
//  Created by Besher on 2018-10-07.
//  Copyright © 2018 Besher Al Maleh. All rights reserved.
//

import UIKit

struct ImageFileManager {
    
    private init() {}
    
    static var documentsDirectory: URL = {
        let paths = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)
        return paths[0]
    }()

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
            do { try FileManager.default.removeItem(at: url) } catch {
                print(error.localizedDescription )}
        }
        do {
            let data = try Data(contentsOf: imageFileName)
            let image = UIImage(data: data)
            setBackground(image: image ?? UIImage(), for: PickerHostType.setupClearFrom(host: host))
            ImageLazyLoader.addImage(image, for: host)
            return image
        } catch {
            print(error.localizedDescription)
        }
        return nil
    }
}

