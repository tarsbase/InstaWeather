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
}

// MARK: - override parent protocol

extension DashboardDelegate where Self: ParallaxViewController {
    func dismissImageMenu() {
        imageMenuIsVisible = false
        restoreBackground()
    }
    
    func hideContainers() {
        if case DashboardStatus.animating = dashboardMenu.dashboardStatus { return }
        
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
