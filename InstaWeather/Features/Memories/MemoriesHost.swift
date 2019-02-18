//
//  MemoriesHost.swift
//  InstaWeather
//
//  Created by Besher on 2019-02-15.
//  Copyright © 2019 Besher Al Maleh. All rights reserved.
//

import UIKit

protocol MemoriesHost: AnyObject {
    var swipeableView: ZLSwipeableView? { get set }
    var snapshots: [MemoriesSnapshot] { get set }
    var scaledSnapshots: [MemoriesSnapshot] { get set }
    var scalingTimer: Timer? { get set }
}

extension MemoriesHost where Self: UIViewController {
    
//    func getMemoriesSnapshot() -> UIImage? {
//        let image = view.imageRepresentation()
//        return image
//    }
    
    func launchMemories() {
        let swipeableView = ZLSwipeableView(frame: self.view.frame)
        
        // adjust downwards
        swipeableView.center.y += (swipeableView.bounds.height * 0.03)
        
        swipeableView.numberOfActiveView = UInt(snapshots.count)
        swipeableView.numberOfHistoryItem = UInt(snapshots.count)
        
        addCustomAnimationTo(swipeableView)
        swipeableView.shouldSwipeView = customShouldSwipeViewHandler()
        
        swipeableView.alpha = 0
        swipeableView.loadViews()
        view.addSubview(swipeableView)
        self.swipeableView = swipeableView
        
        startScalingTimer()
    }
    
    private func startScalingTimer() {
//        for snap in snapshots {
//            scaleNextImage()
//        }
        
        
        let interval: TimeInterval = 0.01
        let timer = Timer.scheduledTimer(withTimeInterval: interval, repeats: true, block: { [weak self] _ in
            self?.scaleNextImage()
        })

        timer.tolerance = 0.2
        RunLoop.current.add(timer, forMode: RunLoop.Mode.common)
        self.scalingTimer = timer
    }
    
    private func scaleNextImage() {
        guard snapshots.isEmpty == false else {
            scalingTimer?.invalidate()
            scalingTimer = nil
            return
        }
        
        guard scaledSnapshots.count <= snapshots.count else {
            scalingTimer?.invalidate()
            scalingTimer = nil
            return
        }
        
        let next = snapshots.dropFirst(scaledSnapshots.count).first
        
        if let scaled = self.getRandomizedSize(from: next?.image), let date = next?.date {
            let scaledSnapshot = MemoriesSnapshot(image: scaled, date: date)
            self.scaledSnapshots.append(scaledSnapshot)
            self.createCardFrom(scaled)
        }
    }
    
    private func createCardFrom(_ image: UIImage) {
        let screenshot = UIImageView(image: image)
        
        screenshot.layer.cornerRadius = 12
        screenshot.layer.masksToBounds = true
        
        swipeableView?.nextView = {
            return screenshot
        }
    }
    

}

// Helpers

extension MemoriesHost where Self: UIViewController {
    
    private func getRandomizedSize(from image: UIImage?) -> UIImage? {
        let aspectRatio = view.bounds.height / view.bounds.width
        
        let decrease: CGFloat = 100
        
        let minWidth: CGFloat = view.bounds.width - decrease
        let maxWidth: CGFloat = view.bounds.width - (decrease - 10)
        
        let width = CGFloat.random(in: minWidth...maxWidth)
        
        let height = width * aspectRatio
        
        let scale = CGSize(width: width, height: height)
        return image?.image(scaledTo: scale)
    }
    
    private func addCustomAnimationTo(_ swipeableView: ZLSwipeableView) {
        
        func toRadian(_ degree: CGFloat) -> CGFloat {
            return degree * CGFloat(Double.pi/180)
        }
        
        func rotateAndTranslateView(_ view: UIView, forDegree degree: CGFloat, translation: CGPoint, duration: TimeInterval, offsetFromCenter offset: CGPoint, swipeableView: ZLSwipeableView) {
            UIView.animate(withDuration: duration, delay: 0, options: .allowUserInteraction, animations: {
                view.center = swipeableView.convert(swipeableView.center, from: swipeableView.superview)
                var transform = CGAffineTransform(translationX: offset.x, y: offset.y)
                transform = transform.rotated(by: toRadian(degree))
                transform = transform.translatedBy(x: -offset.x, y: -offset.y)
                transform = transform.translatedBy(x: translation.x, y: translation.y)
                view.transform = transform
            }, completion: nil)
        }
        
        swipeableView.animateView = {(view: UIView, index: Int, views: [UIView], swipeableView: ZLSwipeableView) in
            let degree = CGFloat(sin(0.5*Double(index)))
            let offset = CGPoint(x: 0, y: swipeableView.bounds.height*0.3)
            let translation = CGPoint(x: degree*10, y: CGFloat(-index*5))
            let duration = 0.4
            rotateAndTranslateView(view, forDegree: degree, translation: translation, duration: duration, offsetFromCenter: offset, swipeableView: swipeableView)
        }
    }
    
    private func customShouldSwipeViewHandler() -> ShouldSwipeHandler {
        return { (view: UIView, movement: Movement, swipeableView: ZLSwipeableView) -> Bool in
            let translation = movement.translation
            let velocity = movement.velocity
            let bounds = swipeableView.bounds
            let minTranslationInPercent = swipeableView.minTranslationInPercent
            let minVelocityInPointPerSecond = swipeableView.minVelocityInPointPerSecond
            let allowedDirection = swipeableView.allowedDirection
            
            func areTranslationAndVelocityInTheSameDirection() -> Bool {
                return CGPoint.areInSameTheDirection(translation, p2: velocity)
            }
            
            func isDirectionAllowed() -> Bool {
                return Direction.fromPoint(translation).intersection(allowedDirection) != .None
            }
            
            func isTranslationLargeEnough() -> Bool {
                return abs(translation.x) > minTranslationInPercent * bounds.width || abs(translation.y) > minTranslationInPercent * bounds.height
            }
            
            func isVelocityLargeEnough() -> Bool {
                return velocity.magnitude > minVelocityInPointPerSecond
            }
            
            
            if swipeableView.activeViews().count <= 1 {
                return false
            }
            
            return isDirectionAllowed() && areTranslationAndVelocityInTheSameDirection() && (isTranslationLargeEnough() || isVelocityLargeEnough())
        }
    }
}
