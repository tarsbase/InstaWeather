//
//  ImagePicker.swift
//  InstaWeather
//
//  Created by Besher on 2018-10-06.
//  Copyright © 2018 Besher Al Maleh. All rights reserved.
//

import UIKit
import YPImagePicker

enum PickerHostType: String {
    case mainScreen, detailedForecast, weeklyForecast, changeCity
}

protocol ImagePickerHost: class {
    var delegate: DashboardDelegate? { get set }
    func updateCustomImageSetting()
}

extension ImagePickerHost {
    func updateBackgroundWith(_ image: UIImage) {
        delegate?.backgroundImage?.image = image
    }
}

class ImagePicker: NSObject, UINavigationControllerDelegate, UIImagePickerControllerDelegate {
    
    weak var imageHost: ImagePickerHost?
    lazy var cameraPicker = setupYPImagePicker(camera: true)
    lazy var albumPicker = setupYPImagePicker(camera: false)
    
    func setupYPImagePicker(camera: Bool) -> YPImagePicker {
        var config = YPImagePickerConfiguration()
        config.library.mediaType = .photo
        config.library.onlySquare  = false
        config.onlySquareImagesFromCamera = false
        config.targetImageSize = .original
//        config.usesFrontCamera = true
        config.showsFilters = true
        config.shouldSaveNewPicturesToAlbum = true
        config.albumName = "MyGreatAppName"
        config.screens = [.library, .photo]
        config.startOnScreen = camera ? .photo : .library
        config.wordings.libraryTitle = "Gallery"
        config.hidesStatusBar = false
//        config.overlayView = myOverlayView
        config.library.numberOfItemsInRow = 4
        config.library.spacingBetweenItems = 2
        config.isScrollToChangeModesEnabled = true
        
        // Build a picker with your configuration
        return YPImagePicker(configuration: config)
    }
    
    func selectPictureFromCamera(for host: PickerHostType) {
        selectPicture(for: host, using: cameraPicker)
//        imageHost?.delegate?.dismissImageMenu()
    }
    
    func selectPictureFromAlbum(for host: PickerHostType) {
        selectPicture(for: host, using: albumPicker)
//        imageHost?.delegate?.dismissImageMenu()
    }
    
    func selectPicture(for host: PickerHostType, using picker: YPImagePicker) {
        
        picker.didFinishPicking { [unowned picker] items, cancelled in
            if let photo = items.singlePhoto {
                print(photo.fromCamera) // Image source (camera or library)
                print(photo.image) // Final image selected by the user
                print(photo.originalImage) // original image selected by the user, unfiltered
                print(photo.modifiedImage) // Transformed image, can be nil
                print(photo.exifMeta) // Print exif meta data of original image.
                
                ImageManager.setBackground(image: photo.image, for: host)
                self.imageHost?.updateCustomImageSetting()
                if let savedImage = ImageManager.getBackgroundImage(for: host) {
                    self.imageHost?.updateBackgroundWith(savedImage)
                }
            }
            if cancelled {
                print("Picker was cancelled")
            }
            picker.dismiss(animated: true, completion: nil)
        }
        
        imageHost?.delegate?.present(picker, animated: true, completion: nil)
    }
}
