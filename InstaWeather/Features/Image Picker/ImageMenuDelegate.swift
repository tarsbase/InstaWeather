//
//  ImageMenuDelegate.swift
//  InstaWeather
//
//  Created by Besher on 2018-10-07.
//  Copyright © 2018 Besher Al Maleh. All rights reserved.
//

import UIKit

protocol ImageMenuDelegate: class {
    var backgroundImage: UIImageView! { get set }
    var backgroundContainer: UIView! { get set }
    var backgroundBlur: UIVisualEffectView { get set }
    var backgroundBrightness: UIView { get set }
    var blurAnimator: UIViewPropertyAnimator { get set }
    var imageMenu: ImageMenu { get set }
    var imageMenuIsVisible: Bool { get set }
    var statusBarUpdater: StatusBarUpdater? { get set }
    
    func menuIsVisibleChanged(to visible: Bool)
    
    func resetBackgroundImage()
    func dismissImageMenu()
    func changeBlurValueTo(value: CGFloat)
    func changeBrightnessValueTo(value: CGFloat)
    
    func present(_ viewControllerToPresent: UIViewController, animated: Bool, completion: (() -> Void)?)
    func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?)
}

extension ImageMenuDelegate where Self: UIViewController {
    var imageMenu: ImageMenu {
        return ImageMenu()
    }
    
    func loadCustomImage() {
        if let savedImage = ImageManager.getBackgroundImage(for: imageMenu.hostType) {
            backgroundImage.image = savedImage
        }
    }
    
    func menuIsVisibleChanged(to visible: Bool) {
        // disable paging while menu is visible
        statusBarUpdater?.pageViewDataSourceIsActive(!visible)
        if visible { self.imageMenu.alpha = 1 }
        let yValue: CGFloat = visible ? 33.5 : -143.5
        UIView.animate(withDuration: 0.3, animations: { [weak self] in
            guard let self = self else { return }
            self.imageMenu.center.y = yValue
            }, completion: { [weak self] action in
              guard let self = self else { return }
                if !visible { self.imageMenu.alpha = 0 }
        })
    }
    
    func dismissImageMenu() {
        imageMenuIsVisible = false
    }
    
    func handleTouch(by touches: Set<UITouch>) {
        if let location = touches.first?.location(in: self.view) {
            if !imageMenu.frame.contains(location) {
                imageMenuIsVisible = false
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
    
}

// MARK: - create properties

extension ImageMenuDelegate where Self: UIViewController {
    
    func createImageMenuFor(host: PickerHostType) -> ImageMenu {
        guard let imageMenu = UINib(nibName: "ImageMenu", bundle: nil)
            .instantiate(withOwner: self, options: nil)[0] as? ImageMenu else { fatalError() }
        let width = min(view.bounds.width,400)
        
        if width == 400 {
            imageMenu.blurEffectView.layer.cornerRadius = 8
            imageMenu.blurEffectView.clipsToBounds = true
        }

        let xValue = (view.bounds.width / 2) - (width / 2)
        
        
        imageMenu.frame = CGRect(x: xValue, y: -287, width: width, height: 267)
        view.addSubview(imageMenu)
        imageMenu.hostType = host
        imageMenu.delegate = self
        imageMenu.alpha = 0
        return imageMenu
    }
    
    func setupBackgroundBlur() -> UIVisualEffectView {
        let visualView = UIVisualEffectView()
        visualView.frame = self.view.frame
        visualView.transform = CGAffineTransform(scaleX: 2, y: 2)
        backgroundContainer.addSubview(visualView)
        return visualView
    }
    
    func setupBackgroundBrightness() -> UIView {
        let view = UIView(frame: self.view.frame)
        view.transform = CGAffineTransform(scaleX: 2, y: 2)
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
}
