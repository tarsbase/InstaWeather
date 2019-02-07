//
//  ImageLazyLoader.swift
//  InstaWeather
//
//  Created by Besher on 2019-02-06.
//  Copyright © 2019 Besher Al Maleh. All rights reserved.
//

import UIKit

struct ImageLazyLoader {
    
//    static var shared: ImageLazyLoader = ImageLazyLoader()
    private init() {}
    
    private static var loadedImages = [String: UIImage]()
    
    static func contains(_ host: PickerHostType) -> Bool {
        return loadedImages.keys.contains(host.description)
    }
    
    static func getImage(for host: PickerHostType) -> UIImage {
        let backupImage = UIImage(named: "bg1clear") ?? UIImage()
        return loadedImages[host.description] ?? backupImage
    }
    
    static func addImage(_ image: UIImage?, for host: PickerHostType) {
        guard let image = image else { return }
        loadedImages[host.description] = image
    }
}
