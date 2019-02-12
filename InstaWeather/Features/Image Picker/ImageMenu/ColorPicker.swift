//
//  ColorPicker.swift
//  InstaWeather
//
//  Created by Besher on 2019-01-30.
//  Copyright © 2019 Besher Al Maleh. All rights reserved.
//

import UIKit

protocol ColorPickerDelegate {
    func hideColorPicker()
    func colorWasUpdatedTo(_ color: UIColor)
    func shadowsToggled(visible: Bool)
    
    func updateSavedTextBrightnessSettings(to value: Float)
    func updateSavedTextColorSettings(to color: UIColor)
}

class ColorPicker: UIView {
    
    @IBOutlet weak var pickedColorView: UIView! { didSet { pickedColorView.clipToCircle() }}
    @IBOutlet weak var colorPickerContainer: UIView!
    @IBOutlet weak var brightnessSlider: UISlider! {
        didSet { brightnessSlider.addTarget(self, action: #selector(updateSavedTextBrightnessSettings), for: .touchUpInside) }}
    @IBOutlet weak var okButton: UIButton!
    @IBOutlet weak var shadowsSwitch: UISwitch!
    var colorPickerView = ColorPickerView()
    
    var delegate: ColorPickerDelegate?
    
    var brightnessValue: CGFloat {
        let value = CGFloat(brightnessSlider.value)
        return (value * 2) - 1
    }
    
    var colorValue: UIColor = .red { didSet { colorUpdated() }}
    
    var adjustedColorValue: UIColor {
        return colorValue.setBrightnessTo(brightnessValue)
    }
    
    static func createByView<T: UIView & ColorPickerDelegate> (_ delegate: T) -> ColorPicker {
        guard let picker = UINib(nibName: "ColorPicker", bundle: nil)
            .instantiate(withOwner: self, options: nil)[0] as? ColorPicker else { fatalError() }
        picker.frame = CGRect(x: 0, y: delegate.bounds.height - 133, width: delegate.bounds.width, height: 150)
        
        picker.createColorPicker()
        picker.alpha = 0
        picker.delegate = delegate
        delegate.addSubview(picker)
        return picker
    }
    
    func createColorPicker() {
        guard let container = colorPickerContainer else { return }
        self.colorPickerView.removeFromSuperview()
        
        let colorPickerView = ColorPickerView(frame: container.bounds)
        
        container.addSubview(colorPickerView)
        
        colorPickerView.translatesAutoresizingMaskIntoConstraints = false
        
        NSLayoutConstraint.activate([
            colorPickerView.widthAnchor.constraint(equalTo: container.widthAnchor),
            colorPickerView.heightAnchor.constraint(equalTo: container.heightAnchor),
            colorPickerView.centerXAnchor.constraint(equalTo: container.centerXAnchor),
            colorPickerView.centerYAnchor.constraint(equalTo: container.centerYAnchor)
            ])
        
        colorPickerView.didChangeColor = { [weak self] color in
            if let color = color {
                self?.colorSliderMoved(to: color)
            }
        }
        
        colorPickerView.touchUpHandler = { [weak self] in
            self?.updateSavedTextColorSettings()
        }
        
        self.colorPickerView = colorPickerView
    }
    
    func colorSliderMoved(to color: UIColor) {
        if brightnessSlider.value == 1 {
            brightnessSlider.value = 0.5
            updateSavedTextBrightnessSettings()
        }
        self.colorValue = color
    }
    
    func colorUpdated() {
        pickedColorView.backgroundColor = adjustedColorValue
        delegate?.colorWasUpdatedTo(adjustedColorValue)
    }
    
    func updateSavedTextColorSettings() {
        delegate?.updateSavedTextColorSettings(to: colorValue)
    }
        
    @objc func updateSavedTextBrightnessSettings() {
        delegate?.updateSavedTextBrightnessSettings(to: brightnessSlider.value)
    }
    
    @IBAction func okTapped(_ sender: UIButton) {
        delegate?.hideColorPicker()
    }
    
    @IBAction func shadowSwitchToggled(_ sender: UISwitch) {
        delegate?.shadowsToggled(visible: sender.isOn)
    }
    
    func show() {
        changeVisibility(visible: true)
    }
    
    func hide() {
        changeVisibility(visible: false)
    }
    
    @IBAction func brightnessChanged(_ sender: UISlider) {
        colorUpdated()
    }
    
    private func changeVisibility(visible: Bool) {
        let endAlpha: CGFloat = visible ? 1 : 0
        UIViewPropertyAnimator(duration: 0.2, curve: .linear) { [weak self] in
            self?.alpha = endAlpha
        }.startAnimation()
    }
}
