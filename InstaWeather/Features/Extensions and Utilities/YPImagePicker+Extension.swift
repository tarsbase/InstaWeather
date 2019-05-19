//
//  YPImagePicker+Extension.swift
//  InstaWeather
//
//  Created by Besher on 2018-10-15.
//  Copyright © 2018 Besher Al Maleh. All rights reserved.
//

import Foundation
import YPImagePicker

extension YPImagePicker {
    override open var supportedInterfaceOrientations: UIInterfaceOrientationMask {
        return UIInterfaceOrientationMask.portrait //return the value as per the required orientation
    }
    
    override open var shouldAutorotate: Bool {
        return false
    }
}
