//
//  ImageLazyLoader.swift
//  InstaWeather
//
//  Created by Besher on 2019-02-06.
//  Copyright © 2019 Besher Al Maleh. All rights reserved.
//

import UIKit

struct ImageLazyLoader {
    
    private init() {}
    
    private static var loadedImages = [String: UIImage]() {
        didSet {
            print("The size has grown to: \(loadedImages.count)")
        }
    }
    
    // MARK: - Host type methods
    
    static func contains(_ host: PickerHostType) -> Bool {
        return loadedImages.keys.contains(host.description)
    }
    
    static func getImage(for host: PickerHostType, scaledDown: Bool = false) -> UIImage {
        let backupImage = UIImage(named: "bg1clear") ?? UIImage()
        if scaledDown {
            return loadedImages["\(host.description)_resized"] ?? backupImage
        } else {
            return loadedImages[host.description] ?? backupImage
        }
    }
    
    static func addImage(_ image: UIImage?, for host: PickerHostType) {
        guard let image = image else { return }
        loadedImages[host.description] = image
        loadedImages["\(host.description)_resized"] = image.scaledToSafeThumbnailSize
    }
    
    // MARK: - Bundle methods
    
    static func contains(_ name: String) -> Bool {
        return loadedImages.keys.contains(name)
    }
    
    static func getImage(for name: String, scaledDown: Bool = false) -> UIImage {
        if scaledDown {
            return loadedImages["\(name)_resized"] ?? UIImage()
        } else {
            return loadedImages[name] ?? UIImage()
        }
    }
    
    static func addImage(_ image: UIImage?, for name: String) {
        guard let image = image else { return }
        loadedImages[name] = image
        loadedImages["\(name)_resized"] = image.scaledToSafeThumbnailSize
    }
    // TODO fix scaling so it doesn't warp aspect ratio
}
