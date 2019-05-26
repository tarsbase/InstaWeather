//
//  UIView+Animation.swift
//  InstaWeather
//
//  Created by Besher on 2019-05-26.
//  Copyright © 2019 Besher Al Maleh. All rights reserved.
//

import UIKit

internal extension UIView {
    fileprivate func performAnimations(_ animations: [Animation], completionHandler: @escaping () -> Void) {
        // This implementation is exactly the same as before, only now we call
        // the completion handler when our exit condition is hit
        guard !animations.isEmpty else {
            return completionHandler()
        }
        
        var animations = animations
        let animation = animations.removeFirst()
        
        UIView.animate(withDuration: animation.duration, animations: {
            animation.closure(self)
        }, completion: { _ in
            animation.fireOneCompletion()
            self.performAnimations(animations, completionHandler: completionHandler)
        })
    }
    
    fileprivate func performAnimationsInParallel(_ animations: [Animation], completionHandler: @escaping () -> Void) {
        // If we have no animations, we can exit early
        guard !animations.isEmpty else {
            return completionHandler()
        }
        
        // In order to call the completion handler once all animations
        // have finished, we need to keep track of these counts
        let animationCount = animations.count
        var completionCount = 0
        
        let animationCompletionHandler = {
            completionCount += 1
            
            // Once all animations have finished, we call the completion handler
            if completionCount == animationCount {
                completionHandler()
            }
        }
        
        // Same as before, only with the call to the animation
        // completion handler added
        for animation in animations {
            UIView.animate(withDuration: animation.duration, animations: {
                animation.closure(self)
            }, completion: { _ in
                animation.fireOneCompletion()
                animationCompletionHandler()
            })
        }
    }
}

public extension UIView {
    
    @discardableResult func animate(_ animations: [Animation]) -> AnimationToken {
        return AnimationToken(
            view: self,
            animations: animations,
            mode: .inSequence
        )
    }
    
    @discardableResult func animate(inParallel animations: [Animation]) -> AnimationToken {
        return AnimationToken(
            view: self,
            animations: animations,
            mode: .inParallel
        )
    }
    
    @discardableResult func animate(_ animations: Animation...) -> AnimationToken {
        return animate(animations)
    }
    
    @discardableResult func animate(inParallel animations: Animation...) -> AnimationToken {
        return animate(inParallel: animations)
    }
}

public final class AnimationToken {
    private let view: UIView
    private let animations: [Animation]
    private let mode: AnimationMode
    private var isValid = true
    
    // We don't want the API user to think that they should create tokens
    // themselves, so we make the initializer internal to the framework
    fileprivate init(view: UIView, animations: [Animation], mode: AnimationMode) {
        self.view = view
        self.animations = animations
        self.mode = mode
    }
    
    deinit {
        // Automatically perform the animations when the token gets deallocated
        perform {}
    }
    
    internal func perform(completionHandler: @escaping () -> Void) {
        // To prevent the animation from being executed twice, we invalidate
        // the token once its animation has been performed
        guard isValid else {
            return
        }
        
        isValid = false
        
        switch mode {
        case .inSequence:
            view.performAnimations(animations,
                                   completionHandler: completionHandler)
        case .inParallel:
            view.performAnimationsInParallel(animations,
                                             completionHandler: completionHandler)
        }
    }
}
