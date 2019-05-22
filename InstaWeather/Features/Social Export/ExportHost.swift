//
//  ExportHost.swift
//  InstaWeather
//
//  Created by Besher on 2019-02-14.
//  Copyright © 2019 Besher Al Maleh. All rights reserved.
//

import UIKit

protocol ExportHost: AnyObject {
    var viewsExcludedFromScreenshot: [UIView] { get }
    var socialExport: SocialExport? { get set }
    func exportButtonPressed(_ sender: UIButton)
}

extension ExportHost where Self: UIViewController {
    func exportBy(_ sender: UIButton, anchorSide: SocialExport.AnchorSide) {
        AnalyticsEvents.LogEvent(.exportButtonTapped, controllerString: String(describing: self))
        
        let image = getExportImage()
        let social = SocialExport(delegate: self, source: sender, image: image, anchorSide: anchorSide)
        social.showAlert()
        self.socialExport = social
    }
    
    func getExportImage() -> UIImage? {
        hideViews(viewsExcludedFromScreenshot)
        let image = view.imageRepresentation()
        unHideViews(viewsExcludedFromScreenshot)
        return image
    }
    
    func hideViews(_ views: [UIView]?) {
        views?.forEach { $0.isHidden = true }
    }
    
    func unHideViews(_ views: [UIView]?) {
        views?.forEach { $0.isHidden = false }
    }
}
