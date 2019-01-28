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
        overlay.backgroundColor = UIColor.init(white: 0, alpha: 0.2)
        overlay.alpha = 0
        overlay.isUserInteractionEnabled = true
        return overlay
    }
}
