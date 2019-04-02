//
//  ImageDashboard.swift
//  InstaWeather
//
//  Created by Besher on 2019-01-26.
//  Copyright © 2019 Besher Al Maleh. All rights reserved.
//

import UIKit

class Dashboard: UIView {

    @IBOutlet weak var blurEffectView: DashboardBlurEffect!
    @IBOutlet weak var storyboardBackground: UIImageView!
    
    @IBOutlet weak var imageCenter: DashboardButton!
    @IBOutlet weak var labelCenter: UILabel!
    
    @IBOutlet weak var clearImage: DashboardButton!
    @IBOutlet weak var clearLabel: UILabel!
    
    @IBOutlet weak var cloudyImage: DashboardButton!
    @IBOutlet weak var cloudyLabel: UILabel!
    
    @IBOutlet weak var rainyImage: DashboardButton!
    @IBOutlet weak var rainyLabel: UILabel!
    
    @IBOutlet weak var stormyImage: DashboardButton!
    @IBOutlet weak var stormyLabel: UILabel!
    
    @IBOutlet weak var snowyImage: DashboardButton!
    @IBOutlet weak var snowyLabel: UILabel!
    
    var overlay: UIView?
    
    var images: [DashboardButton] { return [imageCenter, clearImage, cloudyImage, rainyImage, stormyImage, snowyImage] }
    var labels: [UILabel] { return [labelCenter, clearLabel, cloudyLabel, rainyLabel, stormyLabel, snowyLabel]}
    
    var hostType: PickerHostType = .mainScreen(.clear)
    var dashboardStatus: DashboardStatus = .hidden {
        didSet {
            if case .displayed = dashboardStatus {
                addSwitch()
            } else {
                removeSwitch()
            }
        }
    }
    var maskingLayer: CAShapeLayer?
    
    var previewBackground: ((DashboardButton) -> Void)?
    var dismissSelf: (() -> Void)?
    
    var dashboardSwitch: DashboardSwitch?
    
    lazy var createButtonsOnce: Void = createButtons()
    
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
        _ = createButtonsOnce
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
        let clippingImage = ImageManager.loadImage(named: "dashboardPolygon")
        let cgImage = clippingImage.cgImage
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
        
        
        updateButtonsLayout()
    }
    
    func showTextLabels(show: Bool) {
        labels.forEach { $0.isHidden = !show }
//        imageCenter.toggleRingVisible(show)
    }
    
    override func layoutSubviews() {
        blurEffectView.layer.masksToBounds = true
    }
    
    func createButtons() {
        imageCenter.setupImage(with: .setup(weatherType: .all, from: hostType)) { [weak self] in
            AnalyticsEvents.logEvent(.dashboardAll)
            self?.showImageMenu(from: self?.imageCenter)
        }
        
        clearImage.setupImage(with: .setup(weatherType: .clear, from: hostType)) { [weak self] in
            AnalyticsEvents.logEvent(.dashboardClear)
            self?.showImageMenu(from: self?.clearImage)
        }
        
        cloudyImage.setupImage(with: .setup(weatherType: .cloudy, from: hostType)) { [weak self] in
            AnalyticsEvents.logEvent(.dashboardCloudy)
            self?.showImageMenu(from: self?.cloudyImage)
        }
        
        rainyImage.setupImage(with: .setup(weatherType: .rainy, from: hostType)) { [weak self] in
            AnalyticsEvents.logEvent(.dashboardRainy)
            self?.showImageMenu(from: self?.rainyImage)
        }
        
        stormyImage.setupImage(with: .setup(weatherType: .stormy, from: hostType)) { [weak self] in
            AnalyticsEvents.logEvent(.dashboardStormy)
            self?.showImageMenu(from: self?.stormyImage)
        }
        
        snowyImage.setupImage(with: .setup(weatherType: .snowy, from: hostType)) { [weak self] in
            AnalyticsEvents.logEvent(.dashboardSnowy)
            self?.showImageMenu(from: self?.snowyImage)
        }
    }
    
    func updateButtonsLayout() {
        images.forEach {
            $0.clipToCircle()
            $0.updateImageSize()
        }
    }
    
    func showImageMenu(from button: DashboardButton?) {
        guard let button = button else { return }
        previewBackground?(button)
    }
    
    func dashboardAnimationStarted(show: Bool) {
        if show {
            imageCenter.updateAllConditionsButton()
        } else {
//            imageCenter.removeRing()
        }
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

extension Dashboard {
    func addSwitch() {
        guard let switchView = UINib(nibName: "DashboardSwitch", bundle: nil)
                .instantiate(withOwner: self, options: nil)[0] as? DashboardSwitch else { fatalError() }
        switchView.setupWith { [weak self] single in self?.switchedToSingleImage(single) }
        super.addSubview(switchView)
        switchView.center = self.center
        switchView.center.y = self.frame.minY - (self.bounds.height * 0.5)
        switchView.layer.cornerRadius = 15
        self.dashboardSwitch = switchView
    }
    
    func removeSwitch() {
        self.dashboardSwitch?.removeFromSuperview()
        self.dashboardSwitch = nil
    }
    
    func switchedToSingleImage(_ single: Bool) {
        
    }
    
    func contains(_ point: CGPoint, in view: UIView) -> Bool {
        let convertedPoint = self.convert(point, from: view)
        let switchContains = dashboardSwitch?.frame.contains(convertedPoint) ?? false
        let dashboardContains = frame.contains(point)
        return dashboardContains || switchContains
    }
    
    override func hitTest(_ point: CGPoint, with event: UIEvent?) -> UIView? {
        
        let found = super.hitTest(point, with: event)
        
        let converted = self.convert(point, to: dashboardSwitch)
        
        let switchFound = dashboardSwitch?.hitTest(converted, with: event)
        return found ?? switchFound
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
