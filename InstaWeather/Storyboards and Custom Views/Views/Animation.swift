//
//  AnimationToken.swift
//  InstaWeather
//
//  Created by Besher on 2019-05-26.
//  Copyright © 2019 Besher Al Maleh. All rights reserved.
//

import UIKit


public struct Animation {
    public typealias Completion = (() -> Void)
    
    public let duration: TimeInterval
    public let closure: (UIView) -> Void
    private let completion: Completion?
    
    public func fireOneCompletion() { completion?() }
}

public extension Animation {
    
    static func fadeIn(duration: TimeInterval = 0.3, completion: Completion? = nil) -> Animation {
        return Animation(duration: duration, closure: { $0.alpha = 1 }, completion: completion)
    }
    
    static func fadeOut(duration: TimeInterval = 0.3, completion: Completion? = nil) -> Animation {
        return Animation(duration: duration, closure: { $0.alpha = 0 }, completion: completion)
    }
    
    static func resize(to size: CGSize, duration: TimeInterval = 0.3, completion: Completion? = nil) -> Animation {
        return Animation(duration: duration, closure: { $0.bounds.size = size }, completion: completion)
    }
    
    static func scale(to scale: CGFloat, duration: TimeInterval = 0.3, completion: Completion? = nil) -> Animation {
        return Animation(duration: duration, closure: { $0.transform = CGAffineTransform(scaleX: scale, y: scale) }, completion: completion)
    }
    
    static func translate(by point: CGPoint, duration: TimeInterval = 0.3, completion: Completion? = nil) -> Animation {
        return Animation(duration: duration, closure: { $0.transform = CGAffineTransform(translationX: point.x, y: point.y) }, completion: completion)
    }
    
    static func reset(duration: TimeInterval = 0.3, completion: Completion? = nil) -> Animation {
        return Animation(duration: duration, closure: { $0.transform = .identity }, completion: completion)
    }
    
    // arbitrary animation
    static func animate(handler: @escaping (() -> Void), duration: TimeInterval = 0.3, completion: Completion? = nil) -> Animation {
        return Animation(duration: duration, closure: { _ in handler() }, completion: completion)
    }
}

// We add an enum to describe in which mode we want to animate
internal enum AnimationMode {
    case inSequence
    case inParallel
}

// MARK: - Global (!!) methods

public func animate(_ tokens: [AnimationToken], completionHandler: (() -> Void)? = nil) {
    guard !tokens.isEmpty else {
        completionHandler?()
        return
    }
    
    var tokens = tokens
    
    let token = tokens.removeFirst()
    token.perform {
        animate(tokens, completionHandler: completionHandler)
    }
}

public func animate(inParallel tokens: [AnimationToken], completionHandler: (() -> Void)? = nil) {
    guard !tokens.isEmpty else {
        completionHandler?()
        return
    }
    
    let group = DispatchGroup()
    tokens.forEach {
        group.enter()
        $0.perform { group.leave() }
    }
    group.notify(queue: .main) { completionHandler?() }
}

public func animate(_ tokens: AnimationToken..., completionHandler: (() -> Void)? = nil) {
    animate(tokens, completionHandler: completionHandler)
}

public func animate(inParallel tokens: AnimationToken..., completionHandler: (() -> Void)? = nil) {
    animate(inParallel: tokens, completionHandler: completionHandler)
}
