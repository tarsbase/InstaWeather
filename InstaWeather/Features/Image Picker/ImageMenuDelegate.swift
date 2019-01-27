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
    var dashboardMenu: ImageDashboard { get set }
    var imageMenuIsVisible: Bool { get set }
    var changeImageButton: CustomImageButton! { get }
    var statusBarUpdater: StatusBarUpdater? { get set }
    var width: CGFloat { get }
    
    func menuIsVisibleChanged(to visible: Bool)
    
    func resetBackgroundImage()
    func dismissImageMenu()
    func changeBlurValueTo(value: CGFloat)
    func changeBrightnessValueTo(value: CGFloat)
    
    func present(_ viewControllerToPresent: UIViewController, animated: Bool, completion: (() -> Void)?)
    func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?)
    func willTransition(to newCollection: UITraitCollection, with coordinator: UIViewControllerTransitionCoordinator)
}

extension ImageMenuDelegate where Self: UIViewController {
    
    var width: CGFloat { return self.view.bounds.width }
    
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
        let yValue: CGFloat = visible ? 33.5 : -148.5
        
        let anim = UIViewPropertyAnimator(duration: 0.5, dampingRatio: 0.9) { [weak self] in
            self?.imageMenu.center.y = yValue
        }
        anim.addCompletion { [weak self] (_) in
            if !visible { self?.imageMenu.alpha = 0 }
        }
        anim.startAnimation()
    }
    
    func dismissImageMenu() {
        imageMenuIsVisible = false
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
    
}

// MARK: - create properties

extension ImageMenuDelegate where Self: UIViewController {
    
    var dashboardCenterPoint: CGPoint {
        return CGPoint(x: Display.width / 2, y: (Display.height / 2) + 80)
    }
    
    var dashboardCenterFrame: CGRect {
        let width: CGFloat = min(Display.width, 550)
        let height: CGFloat = width
        
        let xValue = (Display.width / 2) - (width / 2)
        let yValue = (Display.height / 2) - (height / 2) + 80
        
        return CGRect(x: xValue, y: yValue, width: width, height: height)
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
        
        imageMenu.frame = CGRect(x: xValue, y: -287, width: width, height: 267)
        view.addSubview(imageMenu)
        imageMenu.hostType = host
        imageMenu.delegate = self
        imageMenu.alpha = 0
        return imageMenu
    }
    
    func createDashboardFor(host: PickerHostType) -> ImageDashboard {
        guard let dashboard = UINib(nibName: "ImageDashboard", bundle: nil)
            .instantiate(withOwner: self, options: nil)[0] as? ImageDashboard else { fatalError() }
        
        dashboard.frame = dashboardCenterFrame
        
        dashboard.hostType = host
        dashboard.initialSetup()
        dashboard.showImageMenuHandler = { [weak self] in self?.imageMenuIsVisible = true }
        dashboard.dismissSelf = { [weak self] in self?.hideContainers() }
        view.addSubview(dashboard)
        
        print("Creating dashboard for \(host)")
        return dashboard
    }
    
    func recreateMenusIfNotVisible() {
        guard !imageMenuIsVisible && dashboardMenu.dashboardStatus == .hidden else { return }
        recreateMenus()
    }
    
    func recreateMenus(){
        UIView.animate(withDuration: 0.2, animations: { [weak self] in
            guard let self = self else { return }
            self.imageMenu.alpha = 0
            self.dashboardMenu.alpha = 0
            }, completion: {[weak self] finish in
                guard let self = self else { return }
                self.imageMenu.removeFromSuperview()
                self.imageMenu = self.createImageMenuFor(host: self.imageMenu.hostType)
                self.dashboardMenu.removeFromSuperview()
                self.dashboardMenu = self.createDashboardFor(host: self.dashboardMenu.hostType)
        })
    }
}

// animations

extension ImageMenuDelegate where Self: UIViewController {
    
    // todo fill background with image from polygon when selected
    // slider shows upon selection, with banner text specifying condition (change snowy background)
    // use interactive buttons for images
    //
    
    func showDashboard() {
        changeImageButton.isEnabled = false
        animateDashboard(dashboard: dashboardMenu, fromButton: changeImageButton, show: true)
    }
    
    func hideDashboard() {
        animateDashboard(dashboard: dashboardMenu, fromButton: changeImageButton, show: false)
    }
    
    func animateDashboard(dashboard: ImageDashboard, fromButton button: UIButton, show: Bool) {
        print(dashboard.dashboardStatus)
        guard dashboard.dashboardStatus != .animating else { return }
        dashboardMenu.dashboardStatus = .animating
        
        let endCenter = show ? dashboardCenterPoint : button.center
        dashboard.transform = show ? CGAffineTransform(scaleX: 0.1, y: 0.1) : .identity
        dashboard.center = show ? button.center : dashboardCenterPoint
        
        let duration: TimeInterval = 0.8
        
        let anim = UIViewPropertyAnimator(duration: duration, dampingRatio: 0.9) {
            dashboard.transform = show ? .identity : CGAffineTransform(scaleX: 0.1, y: 0.1)
            for _ in 0...3 {
                let rotation = CGAffineTransform(rotationAngle: .pi / 2)
                dashboard.transform = dashboard.transform.concatenating(rotation)
            }
            dashboard.center = endCenter
        }
        
        anim.addCompletion { [weak self] _ in
            if !show {
//                self?.recreateMenus() // bad line
                self?.changeImageButton.isEnabled = true
            }
            dashboard.dashboardStatus = show ? .displayed : .hidden
        }
        

        anim.startAnimation()
        
        let alphaStart = show ? 0 : duration * 0.35
        DispatchQueue.main.asyncAfter(deadline: .now() + alphaStart) {
            UIViewPropertyAnimator(duration: 0.1, curve: .linear) {
                dashboard.alpha = show ? 1 : 0
            }.startAnimation()
        }
    }
    
}

enum DashboardStatus {
    case hidden, animating, displayed
}
