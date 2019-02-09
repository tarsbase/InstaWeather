//
//  UIView Extension.swift
//  Find My Latte
//
//  Created by Besher on 2018-07-03.
//  Copyright © 2018 Besher. All rights reserved.
//

import Foundation
import UIKit

// MARK: - Extend UIImage

extension UIImage {
    
    var scaledToSafeThumbnailSize: UIImage? {
        let maxImageSideLength: CGFloat = 120
        
        let largerSide: CGFloat = max(size.width, size.height)
        let ratioScale: CGFloat = largerSide > maxImageSideLength ? largerSide / maxImageSideLength : 1
        let newImageSize = CGSize(width: size.width / ratioScale, height: size.height / ratioScale)
        
        return image(scaledTo: newImageSize)
    }
    
    func image(scaledTo size: CGSize) -> UIImage? {
        defer {
            UIGraphicsEndImageContext()
        }
        
        UIGraphicsBeginImageContextWithOptions(size, true, 0)
        draw(in: CGRect(origin: .zero, size: size))
        
        return UIGraphicsGetImageFromCurrentImageContext()
    }
}

extension UIView {
    
    func imageRepresentation() -> UIImage? {
        UIGraphicsBeginImageContextWithOptions(self.bounds.size, self.isOpaque, 0.0)
        defer { UIGraphicsEndImageContext() }
        if let context = UIGraphicsGetCurrentContext() {
            self.layer.render(in: context)
            let image = UIGraphicsGetImageFromCurrentImageContext()
            return image
        }
        return nil
    }
    
}

extension UIView {
    
    func smoothRoundCorners(to radius: CGFloat) {
        let maskLayer = CAShapeLayer()
        maskLayer.frame = bounds
        maskLayer.path = UIBezierPath(
            roundedRect: bounds,
            cornerRadius: radius
            ).cgPath
        
        layer.mask = maskLayer
    }
    
    func smoothRoundTopCornersOnly(to radius: CGFloat) {
        let maskLayer = CAShapeLayer()
        maskLayer.frame = bounds
        maskLayer.path = UIBezierPath(
            roundedRect: bounds,
            byRoundingCorners: [.topLeft, .topRight],
            cornerRadii: CGSize(width: radius, height: radius)).cgPath
        layer.mask = maskLayer
    }
    
    func clipToCircle() {
        let maskLayer = CAShapeLayer()
        maskLayer.frame = bounds
        maskLayer.path = CGPath(ellipseIn: self.bounds, transform: nil)
        layer.mask = maskLayer
    }
    
    
    func alphaFromPoint(point: CGPoint) -> CGFloat {
        var pixel: [UInt8] = [0, 0, 0, 0]
        let colourSpace = CGColorSpaceCreateDeviceRGB()
        let alphaInfo = CGBitmapInfo(rawValue: CGImageAlphaInfo.premultipliedLast.rawValue)
        let context = CGContext(data: &pixel, width: 1, height: 1, bitsPerComponent: 8, bytesPerRow: 4, space: colourSpace, bitmapInfo: alphaInfo.rawValue)
        
        context?.translateBy(x: -point.x, y: -point.y)
        
        self.layer.render(in: context!)
        
        let floatAlpha = CGFloat(pixel[3])
        return floatAlpha
    }
    
}

extension UIView {
    func getDeviceCenterOfScreen() -> CGPoint {
        return CGPoint(x: UIScreen.main.bounds.size.width*0.5,y: UIScreen.main.bounds.size.height*0.5)
    }
    
    func getDeviceScreenSize() -> CGRect {
         return UIScreen.main.bounds
    }
    
}

extension CGPoint {
    func distanceTo(_ point: CGPoint) -> CGFloat {
        let xDist = self.x - point.x
        let yDist = self.y - point.y
        return CGFloat(sqrt((xDist * xDist) + (yDist * yDist)))
    }
}

extension Double {
    func rounded(toPlaces places:Int) -> Double {
        let divisor = pow(10.0, Double(places))
        return (self * divisor).rounded() / divisor
    }
}

//public extension UIViewController {
//    static var visibleViewController: UIViewController? {
//        return UIApplication.shared.keyWindow?.visibleViewController
//    }
//}

public extension UIWindow {
    public var visibleViewController: UIViewController? {
        return UIWindow.getVisibleViewControllerFrom(self.rootViewController)
    }
    
    private static func getVisibleViewControllerFrom(_ vc: UIViewController?) -> UIViewController? {
        if let nc = vc as? UINavigationController {
            return UIWindow.getVisibleViewControllerFrom(nc.visibleViewController)
        } else if let tc = vc as? UITabBarController {
            return UIWindow.getVisibleViewControllerFrom(tc.selectedViewController)
        } else {
            if let pvc = vc?.presentedViewController {
                return UIWindow.getVisibleViewControllerFrom(pvc)
            } else {
                return vc
            }
        }
    }
}

extension UIColor {
    
    private func lighterColor(removeSaturation val: CGFloat, removeBrightness brt: CGFloat, resultAlpha alpha: CGFloat = -1) -> UIColor {
        var h: CGFloat = 0, s: CGFloat = 0
        var b: CGFloat = 0, a: CGFloat = 0
        
        guard getHue(&h, saturation: &s, brightness: &b, alpha: &a)
            else {return self}
        
        return UIColor(hue: h,
                       saturation: s - val,
                       brightness: b - brt,
                       alpha: alpha == -1 ? a : alpha)
    }
    
    func setBrightnessTo(_ value: CGFloat) -> UIColor {
        if value > 0 {
            return lighterColor(removeSaturation: value, removeBrightness: 0)
        } else {
            return lighterColor(removeSaturation: 0, removeBrightness: -value)
        }
    }
}
