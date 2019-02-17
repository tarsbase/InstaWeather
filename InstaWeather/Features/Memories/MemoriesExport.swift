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
}

extension MemoriesExport {
    var viewsExcludedFromScreenshot: [UIView] {
        return []
    }
    func getExportImage() -> UIImage? {
        return swipeableView?.topView()?.imageRepresentation()
    }
}
