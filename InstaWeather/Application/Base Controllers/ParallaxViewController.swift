//
//  ParallaxViewController.swift
//  InstaWeather
//
//  Created by Besher on 2018-10-27.
//  Copyright © 2018 Besher Al Maleh. All rights reserved.
//

import UIKit
import StoreKit

typealias UpdateModelHandler = ((WeatherDataModel) -> Void)
typealias GetModelHandler = (() -> WeatherDataModel)

class ParallaxViewController: UIViewController, ParallaxHost {
    
    var parallaxImage: UIImageView?
    weak var statusBarUpdater: StatusBarUpdater?
    
    var weatherDataModel: WeatherDataModel {
        get {
        return getDataModel?() ?? WeatherDataModel()
        }
        set {
            updateDataModel?(newValue)
        }
    }
    
    // closures to manipulate weather data struct in parent controller
    private var getDataModel: GetModelHandler?
    private var updateDataModel: UpdateModelHandler?
    
    func initialSetup(updateModel: @escaping UpdateModelHandler, getModel: @escaping GetModelHandler, statusBarUpdater: StatusBarUpdater) {
        self.updateDataModel = updateModel
        self.getDataModel = getModel
        self.statusBarUpdater = statusBarUpdater
    }
    
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
