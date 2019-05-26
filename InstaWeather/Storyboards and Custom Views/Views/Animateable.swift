//
//  Animateable.swift
//  InstaWeather
//
//  Created by Besher on 2019-05-26.
//  Copyright © 2019 Besher Al Maleh. All rights reserved.
//

import UIKit

enum FadeDirection {
    case fadeIn, fadeOut
    var endAlpha: CGFloat {
        switch self {
        case .fadeIn: return 1.0
        case .fadeOut: return 0.0
        }
    }
}

enum Animation {
    case fade(direction: FadeDirection)
    case scale(endScale: CGFloat)
}

protocol Animateable {}

extension Animateable where Self: UIView {
    
    // call a group of animations
    func animate(_ animations: [Animation], duration: TimeInterval, completion: ((Bool) -> Void)? = nil) {
        let group = DispatchGroup()
        for animation in animations {
            group.enter()
            animate(animation, duration: duration) { _ in
                group.leave()
            }
        }
        group.notify(queue: .main) {
            completion?(true)
        }
    }
    
    // call a single animation
    func animate(_ animation: Animation, duration: TimeInterval, completion: ((Bool) -> Void)? = nil) {
        switch animation {
        case .fade(let direction):
            fade(direction: direction, duration: duration, completion: completion)
        case .scale(let endScale):
            scale(to: endScale, duration: duration, completion: completion)
        }
    }
    
    private func fade(direction: FadeDirection, duration: TimeInterval, completion: ((Bool) -> Void)? = nil) {
        UIView.animate(withDuration: duration, delay: 0, options: .curveLinear, animations: { [weak self] in
            self?.alpha = direction.endAlpha
            }, completion: completion)
    }
    
    private func scale(to endScale: CGFloat, duration: TimeInterval, completion: ((Bool) -> Void)? = nil) {
        UIView.animate(withDuration: duration, delay: 0, options: .curveEaseInOut, animations: {
            [weak self] in
            self?.transform = CGAffineTransform(scaleX: endScale, y: endScale)
            }, completion: completion)
    }
}

extension UIView: Animateable {}
