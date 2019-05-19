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
    
    var allImages: [DashboardButton] { return [imageCenter, clearImage, cloudyImage, rainyImage, stormyImage, snowyImage] }
    var allLabels: [UILabel] { return [labelCenter, clearLabel, cloudyLabel, rainyLabel, stormyLabel, snowyLabel] }
    
    var visibleLabels: [UILabel] {
        return singleImage ? [labelCenter] : weatherLabels
    }
    
    // shown during off switch
    var weatherImages: [DashboardButton] { return [clearImage, cloudyImage, rainyImage, stormyImage, snowyImage] }
    var weatherLabels: [UILabel] { return [clearLabel, cloudyLabel, rainyLabel, stormyLabel, snowyLabel]}
    
    var hostType: PickerHostType = .mainScreen(.clear)
    var generalSettings: SavedBackgrounds {
        get { return AppSettings.mainscreenBackgrounds }
        set { AppSettings.mainscreenBackgrounds = newValue }
    }
    
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
    
    var singleImage: Bool {
        get { return generalSettings.singleBackground }
        set {
            generalSettings.singleBackground = newValue
            performUIChangesFor(newValue)
        }
    }
    
    var dashboardSwitch: DashboardSwitch?
    weak var delegate: DashboardDelegate?
    
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
        performUIChangesFor(AppSettings.mainscreenBackgrounds.singleBackground)
    }
    
    private func setupMaskingPolygon() {
        let maskingLayer = createMaskingPolygon()
        blurEffectView.layer.mask = maskingLayer
        storyboardBackground.isHidden = true
        self.maskingLayer = maskingLayer
    }
    
    func setupLabels() {
        allLabels.forEach { $0.isHidden = true }
        addShadow(opacity: 0.4, allLabels)
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
        visibleLabels.forEach { $0.isHidden = !show }
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
        allImages.forEach {
            $0.clipToCircle()
            $0.updateImageSize()
        }
    }
    
    func showImageMenu(from button: DashboardButton?) {
        guard let button = button else { return }
        previewBackground?(button)
    }
    
    func dashboardAnimationStarted(show: Bool) {
        
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
        switchView.center.x = imageCenter.center.x
        switchView.center.y = -switchView.bounds.height + 15
        print(self.bounds)
        switchView.layer.cornerRadius = 15
        switchView.toggleSwitchTo(singleImage)
        switchView.alpha = 0
        animateSwitch(switchView, visible: true)
        self.dashboardSwitch = switchView
    }
    
    func removeSwitch() {
        if let switchView = self.dashboardSwitch {
            animateSwitch(switchView, visible: false) { [weak self] in
                self?.dashboardSwitch?.removeFromSuperview()
                self?.dashboardSwitch = nil
            }
        }
    }
    
    func switchedToSingleImage(_ single: Bool) {
        singleImage = single
    }
    
    func performUIChangesFor(_ singleImage: Bool) {
        // UI Changes
        singleImage ? animateButtonsInwards() : animateButtonsOutwards()
        delegate?.resetBackgroundImage()
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

// MARK: - Animations
extension Dashboard {
    func animateSwitch(_ switchView: UIView, visible: Bool, completion: (() -> Void)? = nil) {
        let endAlpha: CGFloat = visible ? 1.0 : 0.0
        let duration: TimeInterval = visible ? 0.2 : 0.0
        let delay: TimeInterval = visible ? 0.3 : 0.0
        
        DispatchQueue.main.asyncAfter(deadline: .now() + delay) {
            UIView.animate(withDuration: duration, animations: {
                switchView.alpha = endAlpha
            }, completion: { _ in
                completion?()
            })
        }
    }
    
    var buttonsDampingRatio: CGFloat { return 0.6
        
    }
    var buttonsAnimationDuration: TimeInterval { return 0.8 }
    
    func animateButtonsInwards() {
        self.weatherLabels.forEach { $0.alpha = 0 }
        self.imageCenter.transform = CGAffineTransform(scaleX: 0.5, y: 0.5)
        let anim = UIViewPropertyAnimator(duration: buttonsAnimationDuration, dampingRatio: buttonsDampingRatio) { [weak self] in
            guard let self = self else { return }
            for image in self.weatherImages {
                let (x, y) = self.getDistanceFromCenter(forView: image)
                image.transform = CGAffineTransform(translationX: x, y: y)
            }
            self.imageCenter.alpha = 1
        }
        
        UIViewPropertyAnimator(duration: buttonsAnimationDuration * 1.3, dampingRatio: buttonsDampingRatio * 0.8) { [weak self] in
            guard let self = self else { return }
            self.imageCenter.transform = .identity
        }.startAnimation()
        
        anim.addCompletion { [weak self] (_) in
            guard let self = self else { return }
            self.labelCenter.alpha = 1
            self.weatherImages.forEach { $0.alpha = 0 }
        }
        
        anim.startAnimation()
    }
    
    func animateButtonsOutwards() {
        self.weatherImages.forEach { $0.alpha = 1 }
        
        UIView.animate(withDuration: 0.1) { [weak self] in
            guard let self = self else { return }
            self.labelCenter.alpha = 0
            self.imageCenter.alpha = 0
        }
        
        let anim = UIViewPropertyAnimator(duration: buttonsAnimationDuration, dampingRatio: buttonsDampingRatio) { [weak self] in
            guard let self = self else { return }
            self.imageCenter.transform = .identity
            for image in self.weatherImages {
                image.transform = .identity
            }
        }
        
        anim.addCompletion { [weak self] (_) in
            guard let self = self else { return }
            self.weatherLabels.forEach { $0.alpha = 1; $0.isHidden = false }
        }
        
        anim.startAnimation()
    }
    
    func getDistanceFromCenter(forView view: UIView) -> (x: CGFloat, y: CGFloat) {
        return ((imageCenter.center.x - view.center.x), (imageCenter.center.y - view.center.y))
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
