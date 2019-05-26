//
//  WeatherDataType.swift
//  InstaWeather
//
//  Created by Besher on 2019-05-26.
//  Copyright © 2019 Besher Al Maleh. All rights reserved.
//

import Foundation

enum WeatherDataType {
    case live // fetched from weather API
    case fromDisk // loaded from Codable store
    case scaleChange // tapped on C or F
}
