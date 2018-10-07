//
//  Helper Functions.swift
//  InstaWeather
//
//  Created by Besher on 2018-10-07.
//  Copyright © 2018 Besher Al Maleh. All rights reserved.
//

import UIKit

struct ImageManager {

    static func getBackgroundImage(for host: PickerHostType) -> UIImage? {
        let imageFileName = getDocumentsDirectory().appendingPathComponent("\(host.rawValue).png")
        do {
            let data = try Data(contentsOf: imageFileName)
            return UIImage(data: data)
        } catch {
            print(error.localizedDescription)
        }
        return nil
    }
    
    static func setBackground(image: UIImage, for host: PickerHostType) {
        let imageFileName = getDocumentsDirectory().appendingPathComponent("\(host.rawValue).png")
        if let data = (image).pngData() {
            do {
                try data.write(to: imageFileName)
                print("Wrote new file: \(imageFileName.absoluteString)")
                AppSettings.customImageMain = true
            } catch {
                print(error.localizedDescription)
            }
        }
    }
    
    private static func getDocumentsDirectory() -> URL {
        let paths = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)
        return paths[0]
    }
}

