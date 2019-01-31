//
//  ImageMenuDismissButton.swift
//  InstaWeather
//
//  Created by Besher on 2019-01-29.
//  Copyright © 2019 Besher Al Maleh. All rights reserved.
//

import UIKit

class ImageMenuDismissButton: UIButton {

    var action: (() -> Void)?
    
    func addAction(_ action: @escaping () -> Void) {
        self.action = action
        addTarget(self, action: #selector(performAction), for: .touchUpInside)
    }
    
    @objc func performAction() {
        action?()
    }

}
