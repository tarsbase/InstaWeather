//
//  Helper Functions.swift
//  InstaWeather
//
//  Created by Besher on 2018-10-07.
//  Copyright © 2018 Besher Al Maleh. All rights reserved.
//

import UIKit

struct ImageFileManager {
    
    // TODO add migration and conversion from raw value to description

    static func getBackgroundImage(for host: PickerHostType) -> UIImage? {
        // first perform migration
        if let image = getOldBackgroundWithMigration(for: host) { return image }
        let imageFileName = getDocumentsDirectory().appendingPathComponent("\(host.description).png")
        do {
            let data = try Data(contentsOf: imageFileName)
            return UIImage(data: data)
        } catch {
            print(error.localizedDescription)
        }
        return nil
    }
    
    static func setBackground(image: UIImage, for host: PickerHostType) {
        let imageFileName = getDocumentsDirectory().appendingPathComponent("\(host.description).png")
        if let data = (image).pngData() {
            do {
                try data.write(to: imageFileName)
                print("Wrote new file: \(imageFileName.absoluteString)")
            } catch {
                print(error.localizedDescription)
            }
        }
    }
    
    private static func getOldBackgroundWithMigration(for host: PickerHostType) -> UIImage? {
        let url = getDocumentsDirectory().appendingPathComponent("\(host.preMigrationName).png")
        let imageFileName = url
        defer {
            do { try FileManager.default.removeItem(at: url) } catch {
                print(error.localizedDescription )}
        }
        do {
            let data = try Data(contentsOf: imageFileName)
            let image = UIImage(data: data)
            setBackground(image: image ?? UIImage(), for: PickerHostType.setupFrom(host: host))
            return image
        } catch {
            print(error.localizedDescription)
        }
        return nil
    }
    
    private static func getDocumentsDirectory() -> URL {
        let paths = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)
        return paths[0]
    }
}

