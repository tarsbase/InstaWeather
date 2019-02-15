//
//  ImageSlider.swift
//  InstaWeather
//
//  Created by Besher on 2018-10-07.
//  Copyright © 2018 Besher Al Maleh. All rights reserved.
//

import UIKit

class ImageMenu: UIView {
    
    static var imageMenusArray = [ImageMenu]()
    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var verticalStackView: UIStackView!
    
    var hostType = PickerHostType.mainScreen(.clear)
    var savedSettings: Background {
        get { return hostType.savedSettings }
        set { hostType.savedSettings = newValue }
    }
    var overlay: Overlay?
    
    @IBOutlet weak var blurEffectView: UIVisualEffectView!
    lazy var colorPicker: ColorPicker = setupColorPicker()
    
    lazy var imagePicker = setupImagePicker()
    var confirmButton: ConfirmBackgroundButton?
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
        savedSettings.blurSetting = blurSlider.value
    }
    
    @objc func updateBrightnessSettings() {
        savedSettings.brightnessSetting = brightnessSlider.value
    }
    
    func pickedNewColor(_ color: UIColor) {
        delegate?.pickedNewTextColor(color)
    }
    
    @IBAction func cameraButton(_ sender: Any) {
        imagePicker.selectPictureFromCamera(for: hostType)
    }
    
    @IBAction func albumButton(_ sender: Any) {
        imagePicker.selectPictureFromAlbum(for: hostType)
    }
    @IBAction func resetButton(_ sender: Any) {
        if savedSettings.allDefaultValues { return }
        delegate?.present(generalResetAlert(), animated: true, completion: nil)
    }
    
    @IBAction func textColorButton(_ sender: Any) {
        toggleColorPicker(visible: true)
    }
    
    @IBAction func blurChanged(_ sender: UISlider) {
        delegate?.changeBlurValueTo(value: CGFloat(sender.value))
    }
    
    @IBAction func brightnessChanged(_ sender: UISlider) {
        delegate?.changeBrightnessValueTo(value: CGFloat(sender.value))
    }
    
    func updateSliders() {
        blurSlider.value = savedSettings.blurSetting
        blurChanged(blurSlider)
        brightnessSlider.value = savedSettings.brightnessSetting
        brightnessChanged(brightnessSlider)
        
        delegate?.toggleShadows(on: savedSettings.enableShadows)
        
        colorPicker.brightnessSlider.value = savedSettings.textBrightness
        colorPicker.colorValue = savedSettings.textColor
        colorPicker.shadowsSwitch.isOn = savedSettings.enableShadows
    }
    
    func toggleOverlay(visible: Bool) {
        self.overlay?.alpha = visible ? 1 : 0
    }
    
    func createButton(controller: UIViewController) -> ConfirmBackgroundButton {
        deleteConfirmButton()
        let confirmButton = ConfirmBackgroundButton.createFor(controller: controller) {
            [weak self] in
            self?.delegate?.dismissImageMenu()
            self?.removeConfirmButton()
            self?.toggleColorPicker(visible: false)
        }
        self.confirmButton = confirmButton
        return confirmButton
    }
    
    func removeConfirmButton() {
        let anim = UIViewPropertyAnimator(duration: 0.2, curve: .linear) { [weak self] in
            self?.confirmButton?.alpha = 0
        }
        anim.addCompletion { [weak self] (_) in
            self?.deleteConfirmButton()
        }
        anim.startAnimation()
    }
    
    func deleteConfirmButton() {
        confirmButton?.removeFromSuperview()
        confirmButton = nil
    }
    
    func toggleColorPicker(visible: Bool) {
        if visible { colorPicker.createColorPicker() }
        let endAlpha: CGFloat = visible ? 0 : 1
        UIViewPropertyAnimator(duration: 0.15, curve: .linear) { [weak self] in
            guard let self = self else { return }
            for view in self.verticalStackView.arrangedSubviews {
                if view is UILabel { continue }
                view.alpha = endAlpha
            }
        }.startAnimation()
        visible ? colorPicker.show() : colorPicker.hide()
    }
    
    func prepareToShow() {
        // update title
        self.titleLabel.alpha = 1
        self.titleLabel.text = hostType.weather.title
        
        // update sliders
        updateSliders()
    }
    
    func refreshData() {
        updateSliders()
    }
    
    func resetBackgroundImage() {
        if case PickerHostType.mainScreen = hostType {
            self.delegate?.backgroundImage.image = ImageManager.loadImage(named:
                self.hostType.weather.defaultBackground)
            
            // this can be used if we need to dismiss imageMenu after reset
//            if let controller = delegate as? WeatherViewController {
//                controller.backgroundWasResetInImageMenu()
//            }
        } else {
            self.delegate?.resetBackgroundImage()
        }
    }
    
    func dismissalWrapUp() {
        self.alpha = 0
        self.removeConfirmButton()
        self.toggleOverlay(visible: false)
        self.toggleColorPicker(visible: false)
    }
    
    func dismissIfAllWeather() {
        if hostType.weather == .all {
            delegate?.dismissImageMenu()
        }
    }
    
}


extension ImageMenu: ImagePickerHost {
    func setupImagePicker() -> ImagePicker {
        let imagePicker = ImagePicker()
        imagePicker.imageHost = self
        return imagePicker
    }
    
    func setupColorPicker() -> ColorPicker {
        let picker = ColorPicker.createByView(self)
        
        return picker
    }
    
    func updateCustomImageSetting() {
        savedSettings.customBackground = true
    }
}

extension ImageMenu: ColorPickerDelegate {
    func hideColorPicker() {
        self.toggleColorPicker(visible: false)
    }
    
    func colorWasUpdatedTo(_ color: UIColor) {
        self.pickedNewColor(color)
    }
    
    func shadowsToggled(visible: Bool) {
        self.delegate?.toggleShadows(on: visible)
        savedSettings.enableShadows = visible
    }
    
    func updateSavedTextBrightnessSettings(to value: Float) {
        savedSettings.textBrightness = value
    }
    
    func updateSavedTextColorSettings(to color: UIColor) {
        savedSettings.textColor = color
    }
}

// MARK: - Alerts

extension ImageMenu {
    
    func generalResetAlert() -> UIAlertController {
        let ac = UIAlertController(title: "Reset Selection", message: nil, preferredStyle: .alert)
        ac.addAction(UIAlertAction(title: "Reset background and effects", style: .destructive, handler: { [weak self] (action) in
            guard let self = self else { return }
            self.savedSettings.customBackground = false
            self.savedSettings.brightnessSetting = 0.8
            self.savedSettings.blurSetting = 0
            self.savedSettings.textColor = UIColor.red
            self.savedSettings.textBrightness = 1
            self.savedSettings.enableShadows = true
            self.resetBackgroundImage()
            self.dismissIfAllWeather()
            self.updateSliders()
        }))
        
        if savedSettings.customBackground {
            ac.addAction(UIAlertAction(title: "Reset background", style: .default, handler: { [weak self] (action) in
                guard let self = self else { return }
                self.savedSettings.customBackground = false
                self.resetBackgroundImage()
                self.dismissIfAllWeather()
            }))
        }
        
        if savedSettings.defaultTextColor == false {
            ac.addAction(UIAlertAction(title: "Reset colors", style: .default, handler: { [weak self] (action) in
                guard let self = self else { return }
                self.savedSettings.textColor = .red
                self.savedSettings.textBrightness = 1
                self.updateSliders()
            }))
        }
        
        if savedSettings.defaultBlur == false {
            ac.addAction(UIAlertAction(title: "Reset blur effect", style: .default, handler: { [weak self] (action) in
                guard let self = self else { return }
                self.savedSettings.blurSetting = 0
                self.updateSliders()
            }))
        }
        
        if savedSettings.defaultBrightness == false {
            ac.addAction(UIAlertAction(title: "Reset brightness effect", style: .default, handler: { [weak self] (action) in
                guard let self = self else { return }
                self.savedSettings.brightnessSetting = 0.8
                self.updateSliders()
            }))
        }
        
        ac.addAction(UIAlertAction(title: "Cancel", style: .cancel, handler: nil))
        return ac
    }
}
