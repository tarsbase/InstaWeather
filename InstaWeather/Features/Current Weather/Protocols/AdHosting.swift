//
//  AdsHost.swift
//  InstaWeather
//
//  Created by Besher on 2018-09-27.
//  Copyright © 2018 Besher Al Maleh. All rights reserved.
//

import UIKit
import SafariServices

protocol AdHosting {}

extension AdHosting where Self: UIViewController {
    func launchAds() {
        let twoWeeks: Double = 1_209_600
        
        // don't show ads if user already has app
        if (UIApplication.shared.canOpenURL(URL(string:"dwmath:")!)) {
            return
        }
        
        // don't show ads if it was shown less than 2 weeks ago
        if let date = AppSettings.DateForMyOtherApp {
            let timeSinceLastAd = Date().timeIntervalSince(date)
            print ("\(timeSinceLastAd) seconds since last ad")
            if timeSinceLastAd < twoWeeks {
                return
            }
        }
        
        // Update the timer
        AppSettings.DateForMyOtherApp = Date()
        
        let ac = UIAlertController(title: "Draw with Math\n\n\n\n\n\n\n\n", message: "Check out my brand new family game that helps kids practice their math skills", preferredStyle: .alert)
        let appStoreAction = UIAlertAction(title: "Download", style: .default, handler: { [weak self] (action) in
            self?.loadWebpage(for: .drawWithMath)
            ac.dismiss(animated: true, completion: nil)
        })
        
        let cancel = UIAlertAction(title: "Cancel", style: .cancel, handler: nil)
        let imageView = UIImageView(image: UIImage(named: "DrawWithMathIcon"))
        imageView.layer.minificationFilter = CALayerContentsFilter.trilinear
        imageView.bounds.size = CGSize(width: 120, height: 120)
        ac.view.addSubview(imageView)
        imageView.center.y = 120
        imageView.centerXAnchor.constraint(equalTo: ac.view.centerXAnchor).isActive = true
        
        ac.addAction(appStoreAction)
        ac.addAction(cancel)
        present(ac, animated: true, completion: nil)
    }
    
    func loadWebpage(for app: AppStoreAppsKeys) {
        if let url = URL(string: app.url) {
            let config = SFSafariViewController.Configuration()
            let vc = SFSafariViewController(url: url, configuration: config)
            vc.modalPresentationStyle = .pageSheet
            present(vc, animated: true)
        }
    }
}
