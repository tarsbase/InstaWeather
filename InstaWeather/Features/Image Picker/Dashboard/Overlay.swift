//
//  Overlay.swift
//  InstaWeather
//
//  Created by Besher on 2019-01-28.
//  Copyright © 2019 Besher Al Maleh. All rights reserved.
//

import UIKit

class Overlay: UIView {
    
    static func setupOverlayBy(vc: UIViewController, dismiss: @escaping (() -> Void)) -> Overlay {
        let overlay = Overlay()
        overlay.frame.size = CGSize(width: 5000, height: 5000)
        overlay.center = vc.view.center
        overlay.alpha = 0
        overlay.dismissHandler = dismiss
        overlay.isUserInteractionEnabled = true
        let tap = UITapGestureRecognizer(target: overlay, action: #selector(performDismiss))
        overlay.addGestureRecognizer(tap)
        return overlay
    }
    
    var dismissHandler: (() -> Void)?
    
    @objc func performDismiss() {
        dismissHandler?()
    }
}
