//
//  DashboardSwitch.swift
//  InstaWeather
//
//  Created by Besher on 2019-04-01.
//  Copyright © 2019 Besher Al Maleh. All rights reserved.
//

import UIKit

class DashboardSwitch: UIView {

    private var switchToggled: ((Bool) -> Void)?
    
    @IBOutlet private weak var effectsView: UIVisualEffectView!
    @IBOutlet private weak var imageSwitch: UISwitch!
    @IBOutlet weak var label: UILabel!
    
    func setupWith(switchToggled: ((Bool) -> Void)?) {
        self.switchToggled = switchToggled
    }
    
    @IBAction private func imageSwitchToggled(_ sender: UISwitch) {
        switchToggled?(sender.isOn)
    }
    
    override func layoutSubviews() {
        effectsView.layer.cornerRadius = 15
        effectsView.layer.masksToBounds = true
        setupShadow()
    }
    
    func setupShadow() {
        label.layer.shadowColor = UIColor.black.cgColor
        label.layer.shadowOffset = CGSize(width: 0, height: 2)
        label.layer.shadowOpacity = 0.5
        label.layer.shadowRadius = 1.0
    }
}


