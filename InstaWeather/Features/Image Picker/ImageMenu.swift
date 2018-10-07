//
//  ImageSlider.swift
//  InstaWeather
//
//  Created by Besher on 2018-10-07.
//  Copyright © 2018 Besher Al Maleh. All rights reserved.
//

import UIKit

protocol ImageMenuDelegate: class {
    var backgroundImage: UIImageView! { get set }
    func resetBackgroundImage()
    func dismissImageMenu()
    func changeBlurValueTo(value: CGFloat)
    func changeBrightnessValueTo(value: CGFloat)
    
    func present(_ viewControllerToPresent: UIViewController, animated: Bool, completion: (() -> Void)?)
}

class ImageMenu: UIView {
    
    var hostType = PickerHostType.mainScreen
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
        AppSettings.mainscreenBlurSetting = blurSlider.value
    }
    
    @objc func updateBrightnessSettings() {
        AppSettings.mainscreenBrightnessSetting = brightnessSlider.value
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
        blurSlider.value = AppSettings.mainscreenBlurSetting
        blurChanged(blurSlider)
        brightnessSlider.value = AppSettings.mainscreenBrightnessSetting
        brightnessChanged(brightnessSlider)
    }
    
}


extension ImageMenu: ImagePickerHost {
    func setupImagePicker() -> ImagePicker {
        let imagePicker = ImagePicker()
        imagePicker.imageHost = self
        return imagePicker
    }
}

// MARK: - Alerts

extension ImageMenu {
    
    func resetBackgroundAlert() -> UIAlertController {
        let ac = UIAlertController(title: "Reset All Backgrounds?", message: "Are you sure you want to reset the background to the default images?", preferredStyle: .alert)
        ac.addAction(UIAlertAction(title: "Yes", style: .default, handler: { [weak self] (action) in
            guard let self = self else { return }
            AppSettings.customImageMain = false
            self.delegate?.resetBackgroundImage()
        }))
        ac.addAction(UIAlertAction(title: "Cancel", style: .cancel, handler: nil))
        return ac
    }
    
    func generalResetAlert() -> UIAlertController {
        let ac = UIAlertController(title: "Reset Selection", message: nil, preferredStyle: .alert)
        ac.addAction(UIAlertAction(title: "Reset all backgrounds", style: .destructive, handler: { [weak self] (action) in
            guard let self = self else { return }
            self.delegate?.present(self.resetBackgroundAlert(), animated: true, completion: nil)
        }))
        
        if AppSettings.customImageMain {
            ac.addAction(UIAlertAction(title: "Reset current background", style: .default, handler: { [weak self] (action) in
                guard let self = self else { return }
                AppSettings.customImageMain = false
                self.delegate?.resetBackgroundImage()
            }))
        }
        ac.addAction(UIAlertAction(title: "Reset blur effect", style: .default, handler: { [weak self] (action) in
            guard let self = self else { return }
            AppSettings.mainscreenBlurSetting = 0
            self.updateSliders()
        }))
        ac.addAction(UIAlertAction(title: "Reset brightness effect", style: .default, handler: { [weak self] (action) in
            guard let self = self else { return }
            AppSettings.mainscreenBrightnessSetting = 0.8
            self.updateSliders()
        }))
        ac.addAction(UIAlertAction(title: "Cancel", style: .cancel, handler: nil))
        return ac
    }
}
