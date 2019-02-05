//
//  WeatherLabel.swift
//  InstaWeather
//
//  Created by Besher on 2019-01-30.
//  Copyright © 2019 Besher Al Maleh. All rights reserved.
//

import UIKit

class ConfirmBackgroundButton: UIView {
    
    @IBOutlet weak var buttonVisualEffectView: UIVisualEffectView!
    @IBOutlet weak var button: UIButton!
    var confirmAction: (() -> Void)?
    
    static func createFor(controller: UIViewController, action: @escaping () -> Void) -> ConfirmBackgroundButton {
        guard let confirmButton = UINib(nibName: "ConfirmBackgroundButton", bundle: nil)
            .instantiate(withOwner: self, options: nil)[0] as? ConfirmBackgroundButton else { fatalError() }
        let yOffset: CGFloat = Display.typeIsLike == .iphoneXFamily ? 242 : 230
        confirmButton.center = CGPoint(x: controller.view.center.x, y: yOffset)
        confirmButton.confirmAction = action
        confirmButton.button.addTarget(confirmButton, action: #selector(performAction), for: .touchUpInside)
        confirmButton.alpha = 0
        confirmButton.fadeIn()
        return confirmButton
    }
    
    func fadeIn() {
        UIViewPropertyAnimator(duration: 0.2, curve: .linear) { [weak self] in
            self?.alpha = 1
        }.startAnimation(afterDelay: 0.35)
    }
    
    @objc func performAction() {
        confirmAction?()
    }
    
    override func layoutSubviews() {
        buttonVisualEffectView.layer.cornerRadius = 12
        buttonVisualEffectView.layer.masksToBounds = true
    }
    
}
