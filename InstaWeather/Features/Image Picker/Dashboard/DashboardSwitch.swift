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
    
    func setupWith(switchToggled: ((Bool) -> Void)?) {
        self.switchToggled = switchToggled
    }
    
    @IBAction private func imageSwitchToggled(_ sender: UISwitch) {
        switchToggled?(sender.isOn)
    }
    
    override func layoutSubviews() {
        effectsView.layer.cornerRadius = 12
        effectsView.layer.masksToBounds = true
    }
    
    
}


