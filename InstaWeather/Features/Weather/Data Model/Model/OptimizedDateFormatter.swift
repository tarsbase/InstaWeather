//
//  OptimizedDateFormatter.swift
//  InstaWeather
//
//  Created by Besher on 2019-05-20.
//  Copyright © 2019 Besher Al Maleh. All rights reserved.
//

import UIKit

struct OptimizedDateFormatter {
    enum Format {
        case long, medium, short
    }
    
    private static var generalFormatter = DateFormatter()
    private init(){}
    
    static func getFormatter(_ type: Format) -> DateFormatter {
        switch type {
        case .long:
            generalFormatter.dateFormat = "yyyy-MM-dd HH:mm:ss"
        case .medium:
            generalFormatter.dateFormat = "E MMM dd, yyyy"
        case .short:
            generalFormatter.dateFormat = "yyyy-MM-dd"
        }
        return generalFormatter
    }
}
