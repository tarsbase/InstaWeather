//
//  ParallaxViewController.swift
//  InstaWeather
//
//  Created by Besher on 2018-10-27.
//  Copyright © 2018 Besher Al Maleh. All rights reserved.
//

import UIKit
import StoreKit

class ParallaxViewController: UIViewController, ParallaxHost {
    var parallaxImage: UIImageView?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
    }
    
    override func viewDidDisappear(_ animated: Bool) {
        super.viewDidDisappear(animated)
        if let backgroundImage = parallaxImage {
            self.removeParallaxFromView(vw: backgroundImage)
        }
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        if let backgroundImage = parallaxImage {
            self.addParallaxToView(vw: backgroundImage)
        }
    }
    
    func requestReviewAfterLaunchCount() {
        // skip if already presenting
        if self.presentedViewController != nil {
            return
        }
        
        if !AppSettings.alreadySubmittedReview && AppSettings.appLaunchCount > 1 {
            AppSettings.alreadySubmittedReview = true
            SKStoreReviewController.requestReview()
        }
    }
    
    func requestReview() {
        // skip if already presenting
        if self.presentedViewController != nil {
            return
        }
        
        if !AppSettings.alreadySubmittedReview {
            AppSettings.alreadySubmittedReview = true
            SKStoreReviewController.requestReview()
        }
    }

}
