//
//  DashboardOverlay.swift
//  InstaWeather
//
//  Created by Besher on 2019-01-28.
//  Copyright © 2019 Besher Al Maleh. All rights reserved.
//

import UIKit

class DashboardOverlay: UIView {
    
    static func setupOverlayBy(vc: UIViewController, dismiss: @escaping (() -> Void)) -> DashboardOverlay {
        let overlay = DashboardOverlay()
        overlay.frame.size = CGSize(width: 5000, height: 5000)
        overlay.center = vc.view.center
        overlay.backgroundColor = UIColor.init(white: 0, alpha: 0.12)
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
