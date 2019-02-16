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
    var images: [UIImage] { get set }
}

extension MemoriesHost where Self: UIViewController {
    
    func getMemoriesSnapshot() -> UIImage? {
        let image = view.imageRepresentation()
        return image
    }
    
//    func getRandomizedSize(from image: UIImage?) -> UIImage? {
//        let aspectRatio = view.bounds.height / view.bounds.width
//
//        let minWidth: CGFloat = view.bounds.width - 35
//        let maxWidth: CGFloat = view.bounds.width - 25
//
//        let width = CGFloat.random(in: minWidth...maxWidth)
//
//        let height = width * aspectRatio
//
//        let scale = CGSize(width: width, height: height)
//        return image?.image(scaledTo: scale)
//    }
    
    func launchMemories() {
        let swipeableView = ZLSwipeableView(frame: self.view.frame)
        
        // adjust downwards
        swipeableView.center.y += (swipeableView.bounds.height * 0.03)
        
        swipeableView.numberOfActiveView = UInt(images.count)
        swipeableView.numberOfHistoryItem = UInt(images.count)
        
        for image in images {
            let screenshot = UIImageView(image: image)
            
            screenshot.layer.cornerRadius = 12
            screenshot.layer.masksToBounds = true
            
            
            swipeableView.nextView = {
                return screenshot
            }
        }
        
        addCustomAnimationTo(swipeableView)
        
        swipeableView.alpha = 0
        swipeableView.loadViews()
        view.addSubview(swipeableView)
        self.swipeableView = swipeableView
    }

}

// Helpers

extension MemoriesHost {
    
    func addCustomAnimationTo(_ swipeableView: ZLSwipeableView) {
        
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
}
