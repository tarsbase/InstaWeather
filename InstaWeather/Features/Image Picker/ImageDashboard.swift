//
//  ImageDashboard.swift
//  InstaWeather
//
//  Created by Besher on 2019-01-26.
//  Copyright © 2019 Besher Al Maleh. All rights reserved.
//

import UIKit

class ImageDashboard: UIView {

    @IBOutlet weak var blurEffectView: DashboardBlurEffect!
    @IBOutlet weak var storyboardBackground: UIImageView!
    
    @IBOutlet weak var imageCenter: DashboardButton!
    @IBOutlet weak var image1: DashboardButton!
    @IBOutlet weak var image2: DashboardButton!
    @IBOutlet weak var image3: DashboardButton!
    @IBOutlet weak var image4: DashboardButton!
    @IBOutlet weak var image5: DashboardButton!
    var overlay: UIView?
    
    var images: [DashboardButton] { return [imageCenter, image1, image2, image3, image4, image5] }
    
    var hostType: PickerHostType = .mainScreen
    var dashboardStatus: DashboardStatus = .hidden
    var maskingLayer: CAShapeLayer?
    
    var previewBackground: ((DashboardButton) -> Void)?
    var dismissSelf: (() -> Void)?
    
    func initialSetup() {
        alpha = 0
        blurEffectView.dismissSelf = { [weak self] in self?.dismissSelf?() }
        setupMaskingPolygon()
    }
    
    private func setupMaskingPolygon() {
        let clippingImage = UIImage(named: "dashboardPolygon")
        let cgImage = clippingImage?.cgImage
        let maskingLayer = CAShapeLayer()
        maskingLayer.contents = cgImage
        maskingLayer.frame = self.layer.bounds
        blurEffectView.layer.mask = maskingLayer
        storyboardBackground.isHidden = true
        
        self.maskingLayer = maskingLayer
    }
    
    func attachOverlay(_ overlay: DashboardOverlay) {
        self.overlay?.removeFromSuperview()
        self.overlay = overlay
    }
    
    func fadeOut() {
        fade(fadeOut: true)
    }
    
    func fadeIn() {
        fade(fadeOut: false)
    }
    
    private func fade(fadeOut: Bool) {
        let endAlpha: CGFloat = fadeOut ? 0 : 1
        UIViewPropertyAnimator(duration: 0.3, curve: .linear) { [weak self] in
            self?.alpha = endAlpha
            self?.overlay?.alpha = endAlpha
            }.startAnimation()
    }
    
    override func layoutSubviews() {
        images.forEach {
            $0.clipToCircle()
        }
        
        imageCenter.setupImageWith(name: "bglight_rain") { [weak self] in self?.showImageMenu(from: self?.imageCenter) }
        image1.setupImageWith(name: "bg1fog") { [weak self] in self?.showImageMenu(from: self?.image1) }
        image2.setupImageWith(name: "bg1clearnight") { [weak self] in self?.showImageMenu(from: self?.image2) }
        image3.setupImageWith(name: "bg2snow") { [weak self] in self?.showImageMenu(from: self?.image3) }
        image4.setupImageWith(name: "bg2cleariPhone3") { [weak self] in self?.showImageMenu(from: self?.image4) }
        image5.setupImageWith(name: "bg2cloudy") { [weak self] in self?.showImageMenu(from: self?.image5) }
        
        blurEffectView.layer.masksToBounds = true
    }
    
    func showImageMenu(from button: DashboardButton?) {
        guard let button = button else { return }
        previewBackground?(button)
    }
}

class DashboardBlurEffect: UIVisualEffectView {
    var dismissSelf: (() -> Void)?
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        if let location = touches.first?.location(in: self) {
            let alpha = alphaFromPoint(point: location)
            if alpha == 0 { dismissSelf?() }
        }
    }
}

/*
 
 all (middle, toggle)
 clear
 snow
 rain
 thunderstorm
 cloudy
 
*/
