//
//  ImageMenuDelegate.swift
//  InstaWeather
//
//  Created by Besher on 2018-10-07.
//  Copyright © 2018 Besher Al Maleh. All rights reserved.
//

import UIKit

protocol DashboardDelegate: ImageMenuDelegate {
    var dashboardMenu: Dashboard { get set }
    var hostType: PickerHostType { get }
}

// MARK: - override parent protocol

extension DashboardDelegate where Self: ParallaxViewController {
    
    var imageMenuDisplacement: CGFloat { return 33.5 }
    
    func toggleImageMenu(visible: Bool) {
        
        if visible {
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
        imageMenu.isVisible = false
        restoreBackground()
    }
    
    func hideContainers() {
        if case DashboardStatus.animating = dashboardMenu.dashboardStatus { return }
        
        if imageMenu.isVisible {
            dismissImageMenu()
        } else {
            hideDashboard()
        }
    }
    
    func handleTouch(by touches: Set<UITouch>) {
        if let location = touches.first?.location(in: self.view) {
            let dashboardOrSwitchContains = dashboardMenu.contains(location, in: self.view)
            
            if !imageMenu.frame.contains(location) && dashboardOrSwitchContains == false {
                hideContainers()
            } else if !imageMenu.frame.contains(location) {
                if case DashboardStatus.preview = dashboardMenu.dashboardStatus {
                    hideContainers()
                }
            }
        }
    }
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
    
    func createDashboardFor(host: PickerHostType) -> Dashboard {
        guard let dashboard = UINib(nibName: "ImageDashboard", bundle: nil)
            .instantiate(withOwner: self, options: nil)[0] as? Dashboard else { fatalError() }
        
        dashboard.frame = dashboardCenterFrame
        dashboard.hostType = host
        dashboard.initialSetup()
        dashboard.previewBackground = { [weak self] button in self?.previewBackground(by: button) }
        dashboard.dismissSelf = { [weak self] in self?.hideContainers() }
        dashboard.delegate = self
        view.addSubview(dashboard)

        print("Creating dashboard for \(host)")
        return dashboard
    }
    
    func createOverlayFor(dashboard: Dashboard) {
        guard dashboard.overlay == nil else { return }
        let overlay = Overlay.setupOverlayBy(vc: self) { [weak self] in
            self?.hideContainers()
        }
        dashboard.attachOverlay(overlay)
        view.insertSubview(overlay, belowSubview: dashboard)
    }
    
    func recreateMenusIfNotVisible() {
        guard !imageMenu.isVisible, case DashboardStatus.hidden = dashboardMenu.dashboardStatus else { return }
        recreateMenus()
    }
    
    func recreateMenus(){
        imageMenu.isVisible = false
        resetBackgroundImage()
        hideDashboard()
        UIView.animate(withDuration: 0.1, animations: { [weak self] in
            guard let self = self else { return }
            self.imageMenu.alpha = 0
            self.dashboardMenu.alpha = 0
            }, completion: {[weak self] finish in
                guard let self = self else { return }
                self.imageMenu.removeFromSuperview()
                self.imageMenu.overlay?.removeFromSuperview()
                self.imageMenu = self.createImageMenuFor(host: self.imageMenu.hostType)
                self.dashboardMenu.removeFromSuperview()
                self.dashboardMenu = self.createDashboardFor(host: self.dashboardMenu.hostType)
        })
    }
}

// MARK: - Dashboard Default Actions (overridable)
extension DashboardDelegate where Self: ParallaxViewController {
    func pickedNewTextColor(_ color: UIColor) {
        viewsToColor.forEach { $0.tintColor = color }
        _ = viewsToColor.compactMap { $0 as? UILabel }.map { $0.textColor = color }
        _ = viewsToColor.compactMap { $0 as? UIButton }.map { $0.setTitleColor(color, for: .normal) }
    }
    
    func addAllShadows() {
        viewsToColor.forEach { addShadow($0) }
    }
    
    func removeAllShadows() {
        viewsToColor.forEach { $0.layer.shadowOpacity = 0 }
    }
}


enum DashboardStatus {
    case hidden, animating, displayed, preview(DashboardButton)
}
