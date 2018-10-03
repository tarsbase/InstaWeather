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
    
    var id: Int {
        switch self {
        case .instagram: return 389801252
        case .snapchat: return 447188370
        case .facebook: return 284882215
        case .twitter: return 333903271
        case .findMyLatte: return 1435110287
        }
    }
}
