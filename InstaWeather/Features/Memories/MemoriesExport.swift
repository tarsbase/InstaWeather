//
//  MemoriesExport.swift
//  InstaWeather
//
//  Created by Besher on 2019-02-16.
//  Copyright © 2019 Besher Al Maleh. All rights reserved.
//

import UIKit

protocol MemoriesExport: ExportHost {
    var swipeableView: ZLSwipeableView? { get set }
    func getCurrentCard() -> MemoriesSnapshot
}

extension MemoriesExport where Self: UIViewController {
    var viewsExcludedFromScreenshot: [UIView] {
        return []
    }
    
    func exportBy(_ sender: UIButton) {
        let image = getExportImage()
        let social = SocialExport(delegate: self, source: sender, image: image)
        social.showAlert()
        self.socialExport = social
    }
    
    func getExportImage() -> UIImage? {
        return getCurrentCard().image
    }
    
}
