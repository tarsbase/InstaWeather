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
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        if let imageView = self.imageView {
            imageView.contentMode = .scaleAspectFit
            imageView.layer.minificationFilter = .trilinear
            imageView.tintColor = nil
            setImage(imageView.image, for: .normal)
            layer.minificationFilter = .trilinear
        }
    }
    
    func hide(_ hide: Bool) {
        let alpha: CGFloat = hide ? 0 : 1
        UIViewPropertyAnimator(duration: 0.2, curve: .linear) { [weak self] in
            self?.alpha = alpha
            }.startAnimation()
    }
    
    func pulseAnimation(counter: Int = 0) {
        guard AppSettings.appLaunchCount < 3 else { return }
        guard counter < 10 else { return }
        let scale: CGFloat = 1.3
        
        UIView.animateKeyframes(withDuration: 1, delay: 0, options: [.calculationModeCubic, .allowUserInteraction], animations: {
            UIView.addKeyframe(withRelativeStartTime: 0, relativeDuration: 0.5, animations: { [ weak self] in
                guard let self = self else { return }
                self.transform = CGAffineTransform(scaleX: scale, y: scale)
            })
            UIView.addKeyframe(withRelativeStartTime: 0.5, relativeDuration: 0.5, animations: { [ weak self] in
                guard let self = self else { return }
                self.transform = .identity
            })
        }) { [weak self] (finish) in
            self?.pulseAnimation(counter: counter + 1)
        }
    }
}
