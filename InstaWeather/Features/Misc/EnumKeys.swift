//
//  EnumKeys.swift
//  InstaWeather
//
//  Created by Besher on 2018-09-27.
//  Copyright © 2018 Besher Al Maleh. All rights reserved.
//

import Foundation

enum AppStoreAppsKeys: String {
    case instagram
    case snapchat
    case facebook
    case twitter
    case findMyLatte
    case drawWithMath
    
    var id: Int {
        switch self {
        case .instagram: return 389801252
        case .snapchat: return 447188370
        case .facebook: return 284882215
        case .twitter: return 333903271
        case .findMyLatte: return 1435110287
        case .drawWithMath: return 1447996733
        }
    }
    
    var url: String {
        switch self {
        case .findMyLatte: return "https://itunes.apple.com/us/app/find-my-latte/id1435110287?ls=1&mt=8"
        case .drawWithMath: return "https://itunes.apple.com/us/app/draw-with-math/id1447996733?ls=1&mt=8"
        default: return ""
        }
    }
}
