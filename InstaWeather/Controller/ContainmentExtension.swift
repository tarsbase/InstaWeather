//
//  ContainmentExtension.swift
//  InstaWeather
//
//  Created by Besher on 2018-01-28.
//  Copyright © 2018 Besher Al Maleh. All rights reserved.
//

import UIKit

@nonobjc extension UIViewController {
    func add(_ child: UIViewController, frame: CGRect? = nil) {
        addChildViewController(child)
        
        if let frame = frame {
            child.view.frame = frame
        }
        
        view.addSubview(child.view)
        child.didMove(toParentViewController: self)
    }
    
    func remove() {
        willMove(toParentViewController: nil)
        view.removeFromSuperview()
        removeFromParentViewController()
    }
}


