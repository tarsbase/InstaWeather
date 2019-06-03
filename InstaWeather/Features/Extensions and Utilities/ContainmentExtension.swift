//
//  ContainmentExtension.swift
//  InstaWeather
//
//  Created by Besher on 2018-01-28.
//  Copyright © 2018 Besher Al Maleh. All rights reserved.
//

import UIKit

@nonobjc extension UIViewController {
    func add(_ child: UIViewController?, parent: UIView? = nil, hidden: Bool = false) {
        guard let child = child else { return }
        let parentView: UIView = parent ?? self.view
        
        addChild(child)
        child.view.frame = parentView.frame
        parentView.addSubview(child.view)
        child.view.bounds = parentView.bounds
        child.view.frame.origin = .zero
        child.didMove(toParent: self)
        
        if hidden {
            parent?.sendSubviewToBack(child.view)
        }
    }
    
    func add(_ child: UIViewController?, frame: CGRect) {
        guard let child = child else { return }
        
        addChild(child)
        child.view.frame = frame
        view.addSubview(child.view)
        child.didMove(toParent: self)
    }
    
    func addAnchored(_ child: UIViewController, frame: CGRect, centerX: NSLayoutXAxisAnchor, centerY: NSLayoutYAxisAnchor) {
        addChild(child)
        child.view.frame = frame
        child.view.centerXAnchor.constraint(equalTo: centerX).isActive = true
        child.view.centerYAnchor.constraint(equalTo: centerY).isActive = true
        
        view.addSubview(child.view)
        child.didMove(toParent: self)
    }
    
    func remove() {
        willMove(toParent: nil)
        view.removeFromSuperview()
        removeFromParent()
    }
}
