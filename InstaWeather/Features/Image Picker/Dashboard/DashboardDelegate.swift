//
//  ImageMenuDelegate.swift
//  InstaWeather
//
//  Created by Besher on 2018-10-07.
//  Copyright © 2018 Besher Al Maleh. All rights reserved.
//

import UIKit

protocol DashboardDelegate: class {
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
    
    func updateBackgroundImageTo(_ image: UIImage)
    func resetBackgroundImage()
    func dismissImageMenu()
    func changeBlurValueTo(value: CGFloat)
    func changeBrightnessValueTo(value: CGFloat)
    
    func present(_ viewControllerToPresent: UIViewController, animated: Bool, completion: (() -> Void)?)
    func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?)
    func willTransition(to newCollection: UITraitCollection, with coordinator: UIViewControllerTransitionCoordinator)
}



// MARK: - create dashboard

extension DashboardDelegate where Self: ParallaxViewController {
    
    var dashboardCenterPoint: CGPoint {
        return CGPoint(x: Display.width / 2, y: (Display.height / 2))
    }
    
    var dashboardCenterFrame: CGRect {
        let width: CGFloat = min(Display.width, 550)
        let height: CGFloat = width
        
        let xValue = (Display.width / 2) - (width / 2)
        let yValue = (Display.height / 2) - (height / 2)
        
        return CGRect(x: xValue, y: yValue, width: width, height: height)
    }
    
    func createDashboardFor(host: PickerHostType) -> ImageDashboard {
        guard let dashboard = UINib(nibName: "ImageDashboard", bundle: nil)
            .instantiate(withOwner: self, options: nil)[0] as? ImageDashboard else { fatalError() }
        
        dashboard.updateFrame(dashboardCenterFrame)
        dashboard.hostType = host
        dashboard.initialSetup()
        dashboard.previewBackground = { [weak self] button in self?.previewBackground(by: button) }
        dashboard.dismissSelf = { [weak self] in self?.hideContainers() }
        view.addSubview(dashboard)

        print("Creating dashboard for \(host)")
        return dashboard
    }
    
    func createOverlayFor(dashboard: ImageDashboard) {
        guard dashboard.overlay == nil else { return }
        let overlay = DashboardOverlay.setupOverlayBy(vc: self) { [weak self] in
            self?.hideContainers()
        }
        dashboard.attachOverlay(overlay)
        view.insertSubview(overlay, belowSubview: dashboard)
    }
    
    func recreateMenusIfNotVisible() {
        guard !imageMenuIsVisible, case DashboardStatus.hidden = dashboardMenu.dashboardStatus else { return }
        recreateMenus()
    }
    
    func recreateMenus(){
        UIView.animate(withDuration: 0.1, animations: { [weak self] in
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



enum DashboardStatus {
    case hidden, animating, displayed, preview(DashboardButton)
}
