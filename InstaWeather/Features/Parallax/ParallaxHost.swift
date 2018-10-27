//
//  ParallaxHost.swift
//  InstaWeather
//
//  Created by Besher on 2018-10-26.
//  Copyright © 2018 Besher Al Maleh. All rights reserved.
//

import UIKit

protocol ParallaxHost: class {}

extension ParallaxHost where Self: UIViewController {
    func addParallaxToView(vw: UIView) {
        guard vw.motionEffects.isEmpty else { return }
        
        let amount = 1
        let horizontal = UIInterpolatingMotionEffect(keyPath: "center.x", type: .tiltAlongHorizontalAxis)
        horizontal.minimumRelativeValue = -amount
        horizontal.maximumRelativeValue = amount
        
        let vertical = UIInterpolatingMotionEffect(keyPath: "center.y", type: .tiltAlongVerticalAxis)
        vertical.minimumRelativeValue = -amount
        vertical.maximumRelativeValue = amount
        
        let group = UIMotionEffectGroup()
        group.motionEffects = [horizontal, vertical]
        vw.addMotionEffect(group)
        
        // spread out the effect over time, to prevent jerking
        for amount in 1...50 {
            let interval = 0.1 * Double(amount)
            DispatchQueue.main.asyncAfter(deadline: .now() + interval) {
                
                horizontal.minimumRelativeValue = -amount
                horizontal.maximumRelativeValue = amount
                
                vertical.minimumRelativeValue = -amount
                vertical.maximumRelativeValue = amount
            }
        }
    }
    
    func removeParallaxFromView(vw: UIView) {
        for effect in vw.motionEffects {
            vw.removeMotionEffect(effect)
        }
    }
}
