//
//  ImageDashboard.swift
//  InstaWeather
//
//  Created by Besher on 2019-01-26.
//  Copyright © 2019 Besher Al Maleh. All rights reserved.
//

import UIKit

class dashboardImage: UIView {

    @IBOutlet weak var blurEffectView: DashboardBlurEffect!
    @IBOutlet weak var storyboardBackground: UIImageView!
    
    @IBOutlet weak var imageCenter: DashboardButton!
    @IBOutlet weak var image1: DashboardButton!
    @IBOutlet weak var image2: DashboardButton!
    @IBOutlet weak var image3: DashboardButton!
    @IBOutlet weak var image4: DashboardButton!
    @IBOutlet weak var image5: DashboardButton!
    @IBOutlet weak var labelCenter: UILabel!
    @IBOutlet weak var label1: UILabel!
    @IBOutlet weak var label2: UILabel!
    @IBOutlet weak var label3: UILabel!
    @IBOutlet weak var label4: UILabel!
    @IBOutlet weak var label5: UILabel!
    var overlay: UIView?
    
    var images: [DashboardButton] { return [imageCenter, image1, image2, image3, image4, image5] }
    var labels: [UILabel] { return [labelCenter, label1, label2, label3, label4, label5]}
    
    var hostType: PickerHostType = .mainScreen(.clear)
    var dashboardStatus: DashboardStatus = .hidden
    var maskingLayer: CAShapeLayer?
    
    var previewBackground: ((DashboardButton) -> Void)?
    var dismissSelf: (() -> Void)?
    
    deinit {
        self.overlay?.removeFromSuperview()
        self.overlay = nil
    }
    
    func initialSetup() {
        alpha = 0
        blurEffectView.dismissSelf = { [weak self] in self?.dismissSelf?() }
        setupMaskingPolygon()
        setupLabels()
        setupShadow()
    }
    
    private func setupMaskingPolygon() {
        let maskingLayer = createMaskingPolygon()
        blurEffectView.layer.mask = maskingLayer
        storyboardBackground.isHidden = true
        self.maskingLayer = maskingLayer
    }
    
    func setupLabels() {
        labels.forEach { $0.isHidden = true }
        addShadow(opacity: 0.4, labels)
    }
    
    func attachOverlay(_ overlay: Overlay) {
        self.overlay?.removeFromSuperview()
        self.overlay = nil
        self.overlay = overlay
    }
    
    func setupShadow() {
        let maskingLayer = createMaskingPolygon()
        layer.shadowPath = maskingLayer.path
        layer.shadowRadius = 25
        layer.shadowOffset = .zero
        layer.shadowOpacity = 0.3
        
    }
    
    func createMaskingPolygon() -> CAShapeLayer {
        let clippingImage = UIImage(named: "dashboardPolygon")
        let cgImage = clippingImage?.cgImage
        let maskingLayer = CAShapeLayer()
        maskingLayer.contents = cgImage
        maskingLayer.frame = self.layer.bounds
        return maskingLayer
    }
    
    func fadeOut() {
        fade(fadeOut: true, justOverlay: false)
    }
    
    func fadeIn() {
        fade(fadeOut: false, justOverlay: false)
    }
    
    func fadeOutOverlay() {
        fade(fadeOut: true, justOverlay: true)
    }
    
    func fadeInOverlay() {
        fade(fadeOut: false, justOverlay: true)
    }
    
    private func fade(fadeOut: Bool, justOverlay: Bool) {
        let endAlpha: CGFloat = fadeOut ? 0 : 1
        if fadeOut { showTextLabels(show: false) }
        let anim = UIViewPropertyAnimator(duration: 0.15, curve: .linear) { [weak self] in
            if !justOverlay { self?.alpha = endAlpha }
            self?.overlay?.alpha = endAlpha
            }
        anim.addCompletion { [weak self] (_) in
            if !fadeOut { self?.showTextLabels(show: true) }
        }
        anim.startAnimation()
    }
    
    func showTextLabels(show: Bool) {
        labels.forEach { $0.isHidden = !show }
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
    
    func addShadow(opacity: Float = 0.5, _ views: [UIView]) {
        for view in views {
            view.layer.shadowColor = UIColor.black.cgColor
            view.layer.shadowOffset = CGSize(width: 0, height: 2)
            view.layer.shadowOpacity = opacity
            view.layer.shadowRadius = 1.0
        }
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
