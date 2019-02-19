//
//  ImageMenuDelegate.swift
//  InstaWeather
//
//  Created by Besher on 2019-01-28.
//  Copyright © 2019 Besher Al Maleh. All rights reserved.
//

import UIKit

protocol ImageMenuDelegate: AnyObject {
    var backgroundImage: UIImageView! { get set }
    var backgroundContainer: UIView! { get set }
    var backgroundBlur: UIVisualEffectView { get set }
    var backgroundBrightness: UIView { get set }
    var blurAnimator: UIViewPropertyAnimator { get set }
    var imageMenu: ImageMenu { get set }
    var imageMenuIsVisible: Bool { get set }
    var changeImageButton: CustomImageButton! { get }
    var statusBarUpdater: StatusBarUpdater? { get set }
    var width: CGFloat { get }
    var viewsToColor: [UIView] { get }
    
    func addAllShadows()
    func removeAllShadows()
    
    func toggleImageMenu(visible: Bool)
    func toggleShadows(on: Bool) 
    
    func updateBackgroundImageTo(_ image: UIImage)
    func resetBackgroundImage()
    func dismissImageMenu()
    func changeBlurValueTo(value: CGFloat)
    func changeBrightnessValueTo(value: CGFloat)
    func pickedNewTextColor(_ color: UIColor)
    
    func present(_ viewControllerToPresent: UIViewController, animated: Bool, completion: (() -> Void)?)
    func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?)
}

extension ImageMenuDelegate where Self: ParallaxViewController {
    
    var width: CGFloat { return self.view.bounds.width }
    
    var imageMenuDisplacement: CGFloat { return 10 }
    
    var imageMenu: ImageMenu {
        return ImageMenu()
    }
    
    func loadCustomImage() {
        if let savedImage = ImageManager.getBackgroundImage(for: imageMenu.hostType) {
            backgroundImage.image = savedImage
        }
    }
    
    func createImageMenuFor(host: PickerHostType) -> ImageMenu {
        guard let imageMenu = UINib(nibName: "ImageMenu", bundle: nil)
            .instantiate(withOwner: self, options: nil)[0] as? ImageMenu else { fatalError() }
        let width = min(view.bounds.width,400)
        
        if width == 400 {
            imageMenu.blurEffectView.layer.cornerRadius = 8
            imageMenu.blurEffectView.clipsToBounds = true
        }
        
        let xValue = (view.bounds.width / 2) - (width / 2)
        
        imageMenu.frame = CGRect(x: xValue, y: -287, width: width, height: 300)
        view.addSubview(imageMenu)
        imageMenu.hostType = host
        imageMenu.delegate = self
        imageMenu.alpha = 0
        let overlay = Overlay.setupOverlayBy(vc: self) { [weak self] in
            self?.hideContainers()
        }
        imageMenu.overlay = overlay
        view.insertSubview(overlay, belowSubview: imageMenu)
        return imageMenu
    }
    
    func createImageMenuConfirmButton(imageMenu: ImageMenu, visible: Bool) {
        if visible {
            view.addSubview(imageMenu.createButton(controller: self))
        }
    }
    
    func updateBackgroundImageTo(_ image: UIImage) {
        backgroundImage.image = image
    }
    
    func toggleImageMenu(visible: Bool) {
        
        if visible {
            AnalyticsEvents.logEvent(.imageMenuTapped, parameters: ["controller" : String(describing: self)])
            self.imageMenu.alpha = 1
            self.imageMenu.toggleOverlay(visible: true)
            self.statusBarUpdater?.pageViewDataSourceIsActive(false)
        } else {
            self.imageMenu.removeConfirmButton()
        }
        
        let yValue: CGFloat = visible ? imageMenuDisplacement : -175.5
        
        let curve: UIView.AnimationCurve = visible ? .easeOut : .easeIn
        
        let anim = UIViewPropertyAnimator(duration: 0.25, curve: curve) { [weak self] in 
            self?.imageMenu.center.y = yValue
        }
        
        anim.addCompletion { [weak self] (_) in
            guard let self = self else { return }
            if !visible {
                self.imageMenu.dismissalWrapUp()
            }
        }
        createImageMenuConfirmButton(imageMenu: imageMenu, visible: visible)
        anim.startAnimation()
    }
    
    func dismissImageMenu() {
        imageMenuIsVisible = false
        
        // restore paging
        statusBarUpdater?.pageViewDataSourceIsActive(true)
    }
    
    func hideContainers() {
        dismissImageMenu()
    }
    
    func handleTouch(by touches: Set<UITouch>) {
        if let location = touches.first?.location(in: self.view) {
            if !imageMenu.frame.contains(location) {
                hideContainers()
            }
        }
    }
    
    func changeBlurValueTo(value: CGFloat) {
        let finalValue = value * 0.5
        blurAnimator.fractionComplete = finalValue
    }
    
    func changeBrightnessValueTo(value: CGFloat) {
        var finalValue: CGFloat = 0
        // if below 0.8 we decrease brightness, otherwise we increase
        if value < 0.8 {
            finalValue = 1 - (0.5 + (value * 0.625))
            backgroundBrightness.backgroundColor = UIColor.init(white: 0, alpha: finalValue)
        } else {
            finalValue = (value - 0.8) / 2
            backgroundBrightness.backgroundColor = UIColor.init(white: 1, alpha: finalValue)
        }
    }
    
    func setupBackgroundBlur() -> UIVisualEffectView {
        let visualView = UIVisualEffectView()
        visualView.frame = self.view.frame
        visualView.transform = CGAffineTransform(scaleX: 10, y: 10)
        backgroundContainer.addSubview(visualView)
        return visualView
    }
    
    func setupBackgroundBrightness() -> UIView {
        let view = UIView(frame: self.view.frame)
        view.transform = CGAffineTransform(scaleX: 10, y: 10)
        backgroundContainer.addSubview(view)
        return view
    }
    
    func setupBlurAnimator() -> UIViewPropertyAnimator {
        let animator = UIViewPropertyAnimator(duration: 1, curve: .easeOut) {
            self.backgroundBlur.effect = UIBlurEffect(style: .regular)
        }
        animator.pausesOnCompletion = true
        return animator
    }
    
    func addShadow(opacity: Float = 0.5, _ views: UIView...) {
        for view in views {
            view.layer.shadowColor = UIColor.black.cgColor
            view.layer.shadowOffset = CGSize(width: 0, height: 2)
            view.layer.shadowOpacity = opacity
            view.layer.shadowRadius = 1.0
        }
    }
    
    func toggleShadows(on: Bool) {
        on ? addAllShadows() : removeAllShadows()
    }
    
    func recreateMenusIfNotVisible() {
        guard !imageMenuIsVisible else { return }
        recreateMenus()
    }
    
    func recreateMenus(){
        imageMenuIsVisible = false
        UIView.animate(withDuration: 0.1, animations: { [weak self] in
            guard let self = self else { return }
            self.imageMenu.alpha = 0
            }, completion: {[weak self] finish in
                guard let self = self else { return }
                self.imageMenu.removeFromSuperview()
                self.imageMenu.overlay?.removeFromSuperview()
                self.imageMenu = self.createImageMenuFor(host: self.imageMenu.hostType)
        })
    }
}
