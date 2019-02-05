//
//  DashboardDelegate+ImageMenu.swift
//  InstaWeather
//
//  Created by Besher on 2019-01-28.
//  Copyright © 2019 Besher Al Maleh. All rights reserved.
//

import UIKit

extension DashboardDelegate where Self: ParallaxViewController {
    
    var width: CGFloat { return self.view.bounds.width }
    
    var imageMenu: ImageMenu {
        return ImageMenu()
    }
    
    func loadCustomImage() {
        if let savedImage = ImageFileManager.getBackgroundImage(for: imageMenu.hostType) {
            backgroundImage.image = savedImage
        }
    }
    
    func updateBackgroundImageTo(_ image: UIImage) {
        backgroundImage.image = image
    }
    
    func menuIsVisibleChanged(to visible: Bool) {
        
        if visible { self.imageMenu.alpha = 1 }
        let yValue: CGFloat = visible ? 33.5 : -148.5
        
        let anim = UIViewPropertyAnimator(duration: 0.5, dampingRatio: 0.9) { [weak self] in
            self?.imageMenu.center.y = yValue
        }
        anim.addCompletion { [weak self] (_) in
            guard let self = self else { return }
            if !visible { self.imageMenu.alpha = 0 }
        }
        createImageMenuButtonAndLabel(imageMenu: imageMenu, visible: visible)
        anim.startAnimation()
    }
    
    func dismissImageMenu() {
        imageMenuIsVisible = false
        restoreBackground()
    }
    
    func hideContainers() {
        if imageMenuIsVisible {
            dismissImageMenu()
        } else {
            hideDashboard()
        }
    }
    
    func handleTouch(by touches: Set<UITouch>) {
        if let location = touches.first?.location(in: self.view) {
            if !imageMenu.frame.contains(location) && !dashboardMenu.frame.contains(location) {
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
        return imageMenu
    }
    
    func createImageMenuButtonAndLabel(imageMenu: ImageMenu, visible: Bool) {
        if visible {
            view.addSubview(imageMenu.createWeatherLabel(controller: self))
        }
    }
    
    
}
