//
//  ImageButton.swift
//  InstaWeather
//
//  Created by Besher on 2018-11-10.
//  Copyright © 2018 Besher Al Maleh. All rights reserved.
//

import UIKit

fileprivate var imgCounter = 0

class ImageButton: UIControl {
    
    // TODO add text above button to describe which weather state, fades as you touch down
    
    var normalScale: CGFloat = 1.0
    
    private var growAnimator = UIViewPropertyAnimator()
    
    var buttonActionHandler: (() -> Void)?
    
    
    var imageView: UIImageView?
    var ringView: UIView?
    var hostType: PickerHostType = .mainScreen(.clear)
    
    var savedSettings: Background {
        get { return hostType.savedSettings }
        set { hostType.savedSettings = newValue }
    }
    
    lazy var initialSetupOnce: Void = initialSetup()
    
    var imageWidthConstraint: NSLayoutConstraint?
    var imageHeightConstraint: NSLayoutConstraint?
    
    var isCustomImageSelected: Bool {
        return ImageManager.customBackgroundFor(host: hostType)
    }
    
    override func layoutSubviews() {
        _ = initialSetupOnce
    }
    
    func initialSetup() {
        addTarget(self, action: #selector(touchDown), for: [.touchDown, .touchDragEnter])
        addTarget(self, action: #selector(touchUp), for: [.touchUpInside, .touchDragExit, .touchCancel])
        
        isUserInteractionEnabled = true
        backgroundColor = .clear
        imageView?.contentMode = .scaleAspectFit
        imageView?.layer.minificationFilter = CALayerContentsFilter.trilinear
    }
    
    @objc private func touchDown() {
        let scale = normalScale * 1.2
        
        // size
        growAnimator = UIViewPropertyAnimator(duration: 0.5, dampingRatio: 0.4) { [weak self] in
            self?.transform = CGAffineTransform(scaleX: scale, y: scale)
            self?.ringView?.transform = CGAffineTransform(scaleX: scale, y: scale)
        }
        growAnimator.startAnimation()
    }
    
    @objc private func touchUp() {
        let scale = normalScale
        guard isEnabled else { return }
        
        // size
        growAnimator = UIViewPropertyAnimator(duration: 0.08, curve: .easeOut, animations: { [weak self] in
            self?.transform = CGAffineTransform(scaleX: scale, y: scale)
            self?.ringView?.transform = CGAffineTransform(scaleX: scale, y: scale)
        })
        growAnimator.startAnimation()
    }
    
    // this is currently unnecessary, keeping it for later
    override func touchesEnded(_ touches: Set<UITouch>, with event: UIEvent?) {
        super.touchesEnded(touches, with: event)
    }
    
    func setupImage(with type: PickerHostType, action: @escaping (() -> Void)) {
        self.hostType = type
        
        let image = UIImageView(frame: self.frame)
        
        image.image = updateDashboardImage()
        
        image.contentMode = .scaleAspectFill
        self.addSubview(image)
        image.translatesAutoresizingMaskIntoConstraints = false
        image.layer.minificationFilter = .trilinear
        
        let dimensions = image.image?.size ?? .zero
        // ensures image fills up circle
        var aspect = dimensions.width / dimensions.height
        if aspect < 1 { aspect = 1 / aspect }
        
        let imageWidthConstraint = image.widthAnchor.constraint(equalToConstant: self.bounds.width * aspect)
        let imageHeightConstraint = image.heightAnchor.constraint(equalToConstant: self.bounds.height * aspect)
        
        NSLayoutConstraint.activate([
            image.centerXAnchor.constraint(equalTo: self.centerXAnchor),
            image.centerYAnchor.constraint(equalTo: self.centerYAnchor),
            imageWidthConstraint,
            imageHeightConstraint
            ])
        
        // remove old image first
        self.imageView?.removeFromSuperview()
        self.imageView = image
        self.imageWidthConstraint = imageWidthConstraint
        self.imageHeightConstraint = imageHeightConstraint
        
        // add action
        addSelector(action: action)
    }
    
    func updateAllConditionsButton() {
        guard hostType.weather == .all else { return }
        
        if hostType.savedBackgrounds.oneBackgroundForAllConditions {
            setupRing()
        } else {
            removeRing()
        }
    }
    
    func setupRing() {
        removeRing()
        
        let ringWidth: CGFloat = bounds.width * 0.05
        
        let ring = UIView(frame: self.bounds.insetBy(dx: -ringWidth, dy: -ringWidth))
        
        superview?.insertSubview(ring, belowSubview: self)
        ring.backgroundColor = .green
        ring.center = center
        ring.clipToCircle()
        
        ring.translatesAutoresizingMaskIntoConstraints = false
        
        NSLayoutConstraint.activate( [
            ring.widthAnchor.constraint(equalToConstant: ring.bounds.width),
            ring.heightAnchor.constraint(equalToConstant: ring.bounds.height),
            ring.centerXAnchor.constraint(equalTo: self.centerXAnchor),
            ring.centerYAnchor.constraint(equalTo: self.centerYAnchor)
            ])
        
        self.ringView = ring
    }
    
    func removeRing() {
        self.ringView?.removeFromSuperview()
        self.ringView = nil
    }
    
    func updateImageSize() {
        guard let imageView = self.imageView else { return }
        let dimensions = imageView.image?.size ?? .zero
        // ensures image fills up circle
        var aspect = dimensions.width / dimensions.height
        if aspect < 1 { aspect = 1 / aspect }
        self.imageWidthConstraint?.constant = self.bounds.width * aspect
        self.imageHeightConstraint?.constant = self.bounds.height * aspect
    }
    
    @objc func buttonAction() {
        buttonActionHandler?()
    }
    
    func addSelector(action: @escaping (() -> Void)) {
        self.buttonActionHandler = action
        addTarget(self, action: #selector(buttonAction), for: .touchUpInside)
    }
    
    func updateDashboardImage() -> UIImage {
        // first check if custom image is selected
        if isCustomImageSelected {
            return updateCustomDashboardImage()
            
            // otherwise load default image
        } else {
            return ImageManager.loadDashboardDefaultImage(weather: hostType.weather)
        }
    }
    
    private func updateCustomDashboardImage() -> UIImage {
        let image = ImageManager.getDashboardIconImage(for: hostType, size: self.bounds.size)
        return image ?? ImageManager.loadDashboardDefaultImage(weather: hostType.weather)
    }
    
    func getFullSizedImage() -> UIImage {
        if isCustomImageSelected {
            let image = ImageManager.getBackgroundImage(for: hostType)
            return image ?? ImageManager.loadImage(named: hostType.weather.defaultBackground)
        } else {
            return ImageManager.loadImage(named: hostType.weather.defaultBackground)
        }
    }
    
    // makes button easier to activate
    override func point(inside point: CGPoint, with event: UIEvent?) -> Bool {
        let biggerFrame = bounds.insetBy(dx: -15, dy: -15)
        return biggerFrame.contains(point)
    }
}

class DashboardButton: ImageButton {
    
    var buttonIsSelected: Bool = false { didSet { updateSelection(to: buttonIsSelected) }}
    
    
    func updateSelection(to selected: Bool) {
        let duration = 0.4
        UIViewPropertyAnimator(duration: duration, dampingRatio: 0.9) { [weak self] in
            let newScale: CGFloat = selected ? 1.5 : 1.0
            self?.normalScale = newScale
            self?.transform = CGAffineTransform(scaleX: newScale, y: newScale)
            }.startAnimation()
    }
}
