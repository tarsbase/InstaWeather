//
//  ImageDashboard.swift
//  InstaWeather
//
//  Created by Besher on 2019-01-26.
//  Copyright © 2019 Besher Al Maleh. All rights reserved.
//

import UIKit

class ImageDashboard: UIView {

    @IBOutlet weak var blurEffectView: UIVisualEffectView!
    @IBOutlet weak var storyboardBackground: UIImageView!
    
    @IBOutlet weak var imageCenter: DashboardButton!
    @IBOutlet weak var image1: DashboardButton!
    @IBOutlet weak var image2: DashboardButton!
    @IBOutlet weak var image3: DashboardButton!
    @IBOutlet weak var image4: DashboardButton!
    @IBOutlet weak var image5: DashboardButton!
    
    var images: [DashboardButton] { return [imageCenter, image1, image2, image3, image4, image5] }
    
    var hostType: PickerHostType = .mainScreen
    var dashboardStatus: DashboardStatus = .hidden
    var maskingLayer: CAShapeLayer?
    
    var previewBackground: ((DashboardButton) -> Void)?
    var dismissSelf: (() -> Void)?
    
    func initialSetup() {
        alpha = 0
        setupMaskingPolygon()
    }
    
    private func setupMaskingPolygon() {
        let clippingImage = UIImage(named: "dashboardPolygon")
        let cgImage = clippingImage?.cgImage
        let maskingLayer = CAShapeLayer()
        maskingLayer.contents = cgImage
        maskingLayer.frame = self.layer.bounds
        self.layer.mask = maskingLayer
        storyboardBackground.isHidden = true
        
        self.maskingLayer = maskingLayer
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
        
        layer.masksToBounds = true
    }
    
    func showImageMenu(from button: DashboardButton?) {
        guard let button = button else { return }
        previewBackground?(button)
    }
    
    
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
