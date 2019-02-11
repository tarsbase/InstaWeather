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
    var overlay: Overlay?
    
    @IBOutlet weak var blurEffectView: UIVisualEffectView!
    lazy var colorPicker: ColorPicker = setupColorPicker()
    
    var savedSettings: Background {
        get {
            switch hostType {
            case .mainScreen(let weather):
                return AppSettings.mainscreenBackgrounds.background(for: weather)
            case .changeCity(let weather):
                return AppSettings.changecityBackgrounds.background(for: weather)
            case .weeklyForecast(let weather):
                return AppSettings.weeklyForecastBackgrounds.background(for: weather)
            case .detailedForecast(let weather):
                return AppSettings.detailedForecastBackgrounds.background(for: weather)
            }
        }
        set {
            switch hostType {
            case .mainScreen(let weather):
                AppSettings.mainscreenBackgrounds.setSettings(newValue, for: weather)
            case .changeCity(let weather):
                AppSettings.changecityBackgrounds.setSettings(newValue, for: weather)
            case .weeklyForecast(let weather):
                AppSettings.weeklyForecastBackgrounds.setSettings(newValue, for: weather)
            case .detailedForecast(let weather):
                AppSettings.detailedForecastBackgrounds.setSettings(newValue, for: weather)
            }
        }
    }
    
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
    
    @IBAction func cameraButton(_ sender: Any) {
        imagePicker.selectPictureFromCamera(for: hostType)
    }
    
    @IBAction func albumButton(_ sender: Any) {
        imagePicker.selectPictureFromAlbum(for: hostType)
    }
    @IBAction func resetButton(_ sender: Any) {
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
    
    func pickedNewColor(_ color: UIColor) {
        delegate?.pickedNewTextColor(color)
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
    
}


extension ImageMenu: ImagePickerHost {
    func setupImagePicker() -> ImagePicker {
        let imagePicker = ImagePicker()
        imagePicker.imageHost = self
        return imagePicker
    }
    
    func setupColorPicker() -> ColorPicker {
        let picker = ColorPicker.createByView(self) { [weak self] in
            self?.toggleColorPicker(visible: false)
        }
        picker.colorWasUpdated = { [weak self] color in
            self?.pickedNewColor(color)
        }
        
        picker.shadowsToggled = { [weak self] on in
           self?.delegate?.toggleShadows(on: on)
        }
        return picker
    }
    
    func updateCustomImageSetting() {
        savedSettings.customBackground = true
    }
}

// MARK: - Alerts

extension ImageMenu {
    
    func resetBackgroundAndEffectsAlert() -> UIAlertController {
        let ac = UIAlertController(title: "Reset Background?", message: "Are you sure you want to reset the background and effects to their default values?", preferredStyle: .alert)
        ac.addAction(UIAlertAction(title: "Yes", style: .default, handler: { [weak self] (action) in
            guard let self = self else { return }
            self.savedSettings.customBackground = false
            self.resetBackgroundImage()
            self.savedSettings.brightnessSetting = 0.8
            self.savedSettings.blurSetting = 0
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
        
        if savedSettings.customBackground {
            ac.addAction(UIAlertAction(title: "Reset background", style: .default, handler: { [weak self] (action) in
                guard let self = self else { return }
                self.savedSettings.customBackground = false
                self.delegate?.resetBackgroundImage()
            }))
        }
        ac.addAction(UIAlertAction(title: "Reset blur effect", style: .default, handler: { [weak self] (action) in
            guard let self = self else { return }
            self.savedSettings.blurSetting = 0
            self.updateSliders()
        }))
        ac.addAction(UIAlertAction(title: "Reset brightness effect", style: .default, handler: { [weak self] (action) in
            guard let self = self else { return }
            self.savedSettings.brightnessSetting = 0.8
            self.updateSliders()
        }))
        ac.addAction(UIAlertAction(title: "Cancel", style: .cancel, handler: nil))
        return ac
    }
}
