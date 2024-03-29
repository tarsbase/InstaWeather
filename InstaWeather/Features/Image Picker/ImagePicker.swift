//
//  ImagePicker.swift
//  InstaWeather
//
//  Created by Besher on 2018-10-06.
//  Copyright © 2018 Besher Al Maleh. All rights reserved.
//

import UIKit
import YPImagePicker

protocol ImagePickerHost: AnyObject {
    var delegate: ImageMenuDelegate? { get set }
    func updateCustomImageSetting()
}

extension ImagePickerHost {
    func updateBackgroundWith(_ image: UIImage) {
        delegate?.backgroundImage?.image = image
    }
}

class ImagePicker: NSObject, UINavigationControllerDelegate, UIImagePickerControllerDelegate {
    
    weak var imageHost: ImagePickerHost?
    
    func setupYPImagePicker(camera: Bool, addOverlay: Bool = false) -> YPImagePicker {
        
        var config = YPImagePickerConfiguration()
        
        if addOverlay {
            let overlay = imageHost?.delegate?.getCameraOverlay()
            overlay?.contentMode = .scaleAspectFit
            overlay?.alpha = 0.6
            config.overlayView = overlay
        }
            
        config.library.mediaType = .photo
        config.library.onlySquare  = false
        config.onlySquareImagesFromCamera = false
        config.targetImageSize = .original
        config.showsPhotoFilters = true
        config.shouldSaveNewPicturesToAlbum = true
        config.albumName = "InstaWeather"
        config.screens = [.library, .photo]
        config.startOnScreen = camera ? .photo : .library
        config.wordings.libraryTitle = "Gallery"
        config.hidesStatusBar = false
        config.library.numberOfItemsInRow = 4
        config.library.spacingBetweenItems = 2
        config.library.maxNumberOfItems = 1
        config.library.minNumberOfItems = 1
        config.icons.capturePhotoImage = UIImage(named: "iconCapture") ?? config.icons.capturePhotoImage
        
        config.isScrollToChangeModesEnabled = true
        
        // Build a picker with your configuration
        return YPImagePicker(configuration: config)
    }
    
    func selectPictureFromCamera(for host: PickerHostType, addOverlay: Bool) {
        AnalyticsEvents.logEvent(addOverlay ? .withOverlay : .withoutOverlay)
        let picker = setupYPImagePicker(camera: true, addOverlay: addOverlay)
        selectPicture(for: host, using: picker)
    }
    
    func selectPictureFromAlbum(for host: PickerHostType) {
        let picker = setupYPImagePicker(camera: false)
        selectPicture(for: host, using: picker)
    }
    
    func selectPicture(for host: PickerHostType, using picker: YPImagePicker) {
        picker.didFinishPicking { [unowned picker] items, cancelled in
            if let photo = items.singlePhoto {
                AnalyticsEvents.logEvent(.changedBackground)
                ImageManager.saveBackground(image: photo.image, for: host)
                self.imageHost?.updateCustomImageSetting()
                if let savedImage = ImageManager.getBackgroundImage(for: host) {
                    self.imageHost?.updateBackgroundWith(savedImage)
                }
            }
            if cancelled {
                print("Picker was cancelled")
            }
            picker.dismiss(animated: true)
        }
        
        imageHost?.delegate?.present(picker, animated: true, completion: nil)
    }
}
