//
//  ColorPicker.swift
//  InstaWeather
//
//  Created by Besher on 2019-01-30.
//  Copyright © 2019 Besher Al Maleh. All rights reserved.
//

import UIKit

class ColorPicker: UIView {
    
    @IBOutlet weak var pickedColorView: UIView! { didSet { pickedColorView.clipToCircle() }}
    @IBOutlet weak var colorPickerView: ColorPickerView!
    @IBOutlet weak var brightnessSlider: UISlider!
    @IBOutlet weak var okButton: UIButton!
    var hideHandler: (() -> Void)?
    
    var brightnessValue: CGFloat {
        let value = CGFloat(brightnessSlider.value)
        return (value * 2) - 1
    }
    
    var colorValue: UIColor = .red { didSet { updateColor() }}
    
    static func createByView(_ view: UIView, hideHandler: @escaping (() -> Void)) -> ColorPicker {
        guard let picker = UINib(nibName: "ColorPicker", bundle: nil)
            .instantiate(withOwner: self, options: nil)[0] as? ColorPicker else { fatalError() }
        picker.frame = CGRect(x: 0, y: view.bounds.height - 133, width: view.bounds.width, height: 150)
        picker.colorPickerView.didChangeColor = { color in
            picker.colorValue = color ?? .red
        }
        picker.alpha = 0
        picker.hideHandler = hideHandler
        view.addSubview(picker)
        return picker
    }
    
    func updateColor() {
        let color = colorValue
        let adjustedColor = color.setBrightnessTo(brightnessValue)
        pickedColorView.backgroundColor = adjustedColor
    }
    
    @IBAction func okTapped(_ sender: UIButton) {
        hideHandler?()
    }
    
    func show() {
        changeVisibility(visible: true)
    }
    
    func hide() {
        changeVisibility(visible: false)
    }
    
    @IBAction func brightnessChanged(_ sender: UISlider) {
        updateColor()
    }
    
    private func changeVisibility(visible: Bool) {
        let endAlpha: CGFloat = visible ? 1 : 0
        UIViewPropertyAnimator(duration: 0.2, curve: .linear) { [weak self] in
            self?.alpha = endAlpha
        }.startAnimation()
    }
}
