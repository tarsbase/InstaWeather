//
//  DashboardDelegate+Animations.swift
//  InstaWeather
//
//  Created by Besher on 2019-01-28.
//  Copyright © 2019 Besher Al Maleh. All rights reserved.
//

import UIKit


// MARK: - Dashboard animations

extension DashboardDelegate where Self: ParallaxViewController {
    
    // slider shows upon selection, with banner text specifying condition (change snowy background)
    
    func showDashboard() {
        changeImageButton.hide(true)
        animateDashboard(dashboard: dashboardMenu, fromButton: changeImageButton, show: true)
    }
    
    func hideDashboard() {
        animateDashboard(dashboard: dashboardMenu, fromButton: changeImageButton, show: false)
    }
    
    func animateDashboard(dashboard: Dashboard, fromButton button: UIButton, show: Bool) {
        if case DashboardStatus.animating = dashboardMenu.dashboardStatus { return }
        dashboardMenu.dashboardStatus = .animating
    
        // disable paging while menu is visible
        statusBarUpdater?.pageViewDataSourceIsActive(!show)
        
        dashboard.dashboardAnimationStarted(show: show)
        
        if show { createOverlayFor(dashboard: dashboard) }
        
        let endCenter = show ? dashboardCenterPoint : button.center
        dashboard.center = show ? button.center : dashboardCenterPoint
        applyTransformTo(dashboard, big: !show)
        
        let duration: TimeInterval = 0.8
        
        let anim = UIViewPropertyAnimator(duration: duration, dampingRatio: 0.9) { [weak self] in
            dashboard.center = endCenter
            self?.applyTransformTo(dashboard, big: show)
            let rotationAngle: CGFloat = show ? .pi / 2 : .pi / 4
            for _ in 0...3 {
                let rotation = CGAffineTransform(rotationAngle: rotationAngle)
                dashboard.transform = dashboard.transform.concatenating(rotation)
            }
            show ? dashboard.fadeInOverlay() : dashboard.fadeOutOverlay()
            }
        
        anim.addCompletion { (_) in
            
        }
        
        anim.startAnimation()
        
        // hide camera towards the end
        let fadeCameraTime = duration * 0.4
        DispatchQueue.main.asyncAfter(deadline: .now() + fadeCameraTime) { [weak self] in
            if !show {
                self?.changeImageButton.hide(false)
            }
            dashboard.dashboardStatus = show ? .displayed : .hidden
        }
        
        // fade
        let alphaStartTime = show ? 0 : duration * 0.35
        DispatchQueue.main.asyncAfter(deadline: .now() + alphaStartTime) {
            UIViewPropertyAnimator(duration: 0.1, curve: .linear) {
                dashboard.alpha = show ? 1 : 0
                }.startAnimation()
        }
    }
    
    func applyTransformTo(_ dashboard: Dashboard, big: Bool) {
        if big {
            dashboard.transform = .identity
            dashboard.bounds.size = self.dashboardCenterFrame.size
        } else {
            dashboard.transform = CGAffineTransform(scaleX: 0.1, y: 0.1)
        }
    }
    
}



// MARK: - Background animations

extension DashboardDelegate where Self: ParallaxViewController {
    
    func previewBackground(by button: DashboardButton) {
        if case DashboardStatus.animating = dashboardMenu.dashboardStatus { return }
        
        let background = button.getFullSizedImage()
        
        dashboardMenu.dashboardStatus = .animating
        
        // update image menu
        imageMenu.hostType = button.hostType
        
        let imageView = UIImageView(image: background)
        let frame = button.superview?.convert(button.frame, to: self.view) ?? .zero
        
        dashboardMenu.fadeOut()
        imageView.frame = frame
        imageView.layer.cornerRadius = imageView.bounds.height / 2
        imageView.contentMode = .scaleAspectFill
        imageView.clipsToBounds = true
        self.view.addSubview(imageView)
        
        let duration: TimeInterval = 0.7
        
        let anim = UIViewPropertyAnimator(duration: duration, dampingRatio: 0.9) {
            imageView.frame = self.backgroundImage.frame
            imageView.layer.cornerRadius = 0
        }
        
        anim.addCompletion { [weak self] (_) in
            self?.dashboardMenu.dashboardStatus = .preview(button)
        }
        anim.startAnimation()
        
        let imageMenuDelayMultiplier: Double = 0.45
        
        DispatchQueue.main.asyncAfter(deadline: .now() + duration * imageMenuDelayMultiplier) { [weak self] in
            self?.backgroundImage.image = background
            self?.imageMenu.prepareToShow()
            let fade = UIViewPropertyAnimator(duration: 0.2, curve: .linear){
                imageView.alpha = 0
            }
            fade.addCompletion{ (_) in
                imageView.removeFromSuperview()
            }
            fade.startAnimation()
            self?.imageMenu.isVisible = true
        }
    }
    
    func restoreBackground() {
        guard case DashboardStatus.preview(let button) = dashboardMenu.dashboardStatus else { return }
        let background = button.getFullSizedImage()
        
        launchReviewIfValid()
        
        // reflect new change
        button.imageView?.image = button.updateDashboardImage()
        
        // restore imageMenu values
        imageMenu.hostType = hostType
        imageMenu.refreshData()
        
        dashboardMenu.dashboardStatus = .animating
        dashboardMenu.updateButtonsLayout()
        
        let imageView = UIImageView(image: background)
        imageView.layer.minificationFilter = .trilinear
        imageView.alpha = 0.99 // this prevents strange alpha artifacts / white strips
        let backgroundFrame = self.backgroundImage.frame
        let buttonFrame = button.superview?.convert(button.frame, to: view) ?? .zero
        
        dashboardMenu.fadeIn()
        
        imageView.frame = backgroundFrame
        imageView.contentMode = .scaleAspectFill
        imageView.clipsToBounds = true
        self.view.addSubview(imageView)
        
        let duration: TimeInterval = 0.6
        
        resetBackgroundImage() // to be amended later
        self.imageMenu.isVisible = false
        
        let anim = UIViewPropertyAnimator(duration: duration, dampingRatio: 0.9) {
            imageView.frame = buttonFrame
            imageView.layer.cornerRadius = imageView.bounds.height / 2
        }
        
        anim.addCompletion { [weak self] (_) in
            self?.dashboardMenu.dashboardStatus = .displayed
        }
        
        anim.startAnimation()
        
        DispatchQueue.main.asyncAfter(deadline: .now() + duration * 0.9) {
            let fade = UIViewPropertyAnimator(duration: 0.2, curve: .linear){
                imageView.alpha = 0
            }
            fade.addCompletion{ (_) in
                imageView.removeFromSuperview()
            }
            fade.startAnimation()
        }
    }
    
    fileprivate func launchReviewIfValid() {
        if AppSettings.mainscreenBackgrounds.adjusted {
            requestReviewIfReadyAfter(delay: 0.0)
        }
    }
}
