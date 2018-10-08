//
//  ImageSlider.swift
//  InstaWeather
//
//  Created by Besher on 2018-10-07.
//  Copyright © 2018 Besher Al Maleh. All rights reserved.
//

import UIKit

class ImageMenu: UIView {
    
    var hostType = PickerHostType.mainScreen
    @IBOutlet weak var blurEffectView: UIVisualEffectView!
    
    var savedSettings: (image: Bool, blur: Float, brightness: Float) {
        get {
            switch hostType {
            case .mainScreen:
                return (AppSettings.mainscreenCustomImage, AppSettings.mainscreenBlurSetting, AppSettings.mainscreenBrightnessSetting)
            case .changeCity:
                return (AppSettings.changecityCustomImage, AppSettings.changecityBlurSetting, AppSettings.changecityBrightnessSetting)
            case .weeklyForecast:
                return (AppSettings.weeklyForecastCustomImage, AppSettings.weeklyForecastBlurSetting, AppSettings.weeklyForecastBrightnessSetting)
            case .detailedForecast:
                return (AppSettings.detailedForecastCustomImage, AppSettings.detailedForecastBlurSetting, AppSettings.detailedForecastBrightnessSetting)
            }
        }
        set {
            switch hostType {
            case .mainScreen:
                (AppSettings.mainscreenCustomImage, AppSettings.mainscreenBlurSetting, AppSettings.mainscreenBrightnessSetting) = (newValue.image, newValue.blur, newValue.brightness)
            case .changeCity:
                (AppSettings.changecityCustomImage, AppSettings.changecityBlurSetting, AppSettings.changecityBrightnessSetting) = (newValue.image, newValue.blur, newValue.brightness)
            case .weeklyForecast:
                (AppSettings.weeklyForecastCustomImage, AppSettings.weeklyForecastBlurSetting, AppSettings.weeklyForecastBrightnessSetting) = (newValue.image, newValue.blur, newValue.brightness)
            case .detailedForecast:
                (AppSettings.detailedForecastCustomImage, AppSettings.detailedForecastBlurSetting, AppSettings.detailedForecastBrightnessSetting) = (newValue.image, newValue.blur, newValue.brightness)
            }
        }
    }
    
    lazy var imagePicker = setupImagePicker()
    weak var delegate: ImageMenuDelegate? {
        didSet {
            updateSliders()
        }
    }
    
    @IBOutlet weak var blurSlider: CustomSlider! {
        didSet { blurSlider.addTarget(self, action: #selector(updateBlurSettings), for: .touchUpInside)
        }
    }
    @IBOutlet weak var brightnessSlider: CustomSlider! {
        didSet { brightnessSlider.addTarget(self, action: #selector(updateBrightnessSettings), for: .touchUpInside) }
    }
    @IBOutlet weak var constraintToTop: NSLayoutConstraint!
    
    
    @objc func updateBlurSettings() {
        savedSettings.blur = blurSlider.value
    }
    
    @objc func updateBrightnessSettings() {
        savedSettings.brightness = brightnessSlider.value
    }
    
    @IBAction func cameraButton(_ sender: Any) {
        imagePicker.selectPictureFromCamera(for: hostType)
    }
    
    @IBAction func albumButton(_ sender: Any) {
        imagePicker.selectPictureFromAlbum(for: hostType)
    }
    @IBAction func resetButton(_ sender: Any) {
        delegate?.present(generalResetAlert(), animated: true, completion: nil)
    }
    @IBAction func okButton(_ sender: Any) {
        delegate?.dismissImageMenu()
    }
    
    @IBAction func blurChanged(_ sender: UISlider) {
        delegate?.changeBlurValueTo(value: CGFloat(sender.value))
    }
    
    @IBAction func brightnessChanged(_ sender: UISlider) {
        delegate?.changeBrightnessValueTo(value: CGFloat(sender.value))
    }
    
    func updateSliders() {
        blurSlider.value = savedSettings.blur
        blurChanged(blurSlider)
        brightnessSlider.value = savedSettings.brightness
        brightnessChanged(brightnessSlider)
    }
    
}


extension ImageMenu: ImagePickerHost {
    func setupImagePicker() -> ImagePicker {
        let imagePicker = ImagePicker()
        imagePicker.imageHost = self
        return imagePicker
    }
    
    func updateCustomImageSetting() {
        savedSettings.image = true
    }
}

// MARK: - Alerts

extension ImageMenu {
    
    func resetBackgroundAndEffectsAlert() -> UIAlertController {
        let ac = UIAlertController(title: "Reset All Backgrounds?", message: "Are you sure you want to reset the background to the default images?", preferredStyle: .alert)
        ac.addAction(UIAlertAction(title: "Yes", style: .default, handler: { [weak self] (action) in
            guard let self = self else { return }
            self.savedSettings.image = false
            self.delegate?.resetBackgroundImage()
            self.savedSettings.brightness = 0.8
            self.savedSettings.blur = 0
            self.updateSliders()
        }))
        ac.addAction(UIAlertAction(title: "Cancel", style: .cancel, handler: nil))
        return ac
    }
    
    func generalResetAlert() -> UIAlertController {
        let ac = UIAlertController(title: "Reset Selection", message: nil, preferredStyle: .alert)
        ac.addAction(UIAlertAction(title: "Reset background and effects", style: .destructive, handler: { [weak self] (action) in
            guard let self = self else { return }
            self.delegate?.present(self.resetBackgroundAndEffectsAlert(), animated: true, completion: nil)
        }))
        
        if savedSettings.image {
            ac.addAction(UIAlertAction(title: "Reset background", style: .default, handler: { [weak self] (action) in
                guard let self = self else { return }
                self.savedSettings.image = false
                self.delegate?.resetBackgroundImage()
            }))
        }
        ac.addAction(UIAlertAction(title: "Reset blur effect", style: .default, handler: { [weak self] (action) in
            guard let self = self else { return }
            self.savedSettings.blur = 0
            self.updateSliders()
        }))
        ac.addAction(UIAlertAction(title: "Reset brightness effect", style: .default, handler: { [weak self] (action) in
            guard let self = self else { return }
            self.savedSettings.brightness = 0.8
            self.updateSliders()
        }))
        ac.addAction(UIAlertAction(title: "Cancel", style: .cancel, handler: nil))
        return ac
    }
}
