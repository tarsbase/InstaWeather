//
//  CustomImageButton.swift
//  InstaWeather
//
//  Created by Besher on 2018-10-07.
//  Copyright © 2018 Besher Al Maleh. All rights reserved.
//

import UIKit

class LargeTapAreaButton: UIButton {
    
    override func point(inside point: CGPoint, with event: UIEvent?) -> Bool {
        let newArea = CGRect(x: bounds.origin.x - 20, y: bounds.origin.y - 20, width: bounds.width + 40, height: bounds.height + 40)
        return newArea.contains(point)
    }
}

class CustomImageButton: LargeTapAreaButton {
    static var buttonsArray: Set<CustomImageButton> = Set<CustomImageButton>() {
        didSet {
            print("Buttons array is now at \(buttonsArray.count)")
        }
    }
    
    func hide(_ hide: Bool) {
        let alpha: CGFloat = hide ? 0 : 1
        UIViewPropertyAnimator(duration: 0.2, curve: .linear) { [weak self] in
            self?.alpha = alpha
            }.startAnimation()
    }
}
