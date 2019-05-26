//
//  WeatherDataModel+Codable.swift
//  InstaWeather
//
//  Created by Besher on 2019-05-26.
//  Copyright © 2019 Besher Al Maleh. All rights reserved.
//

import Foundation


extension WeatherDataModel: Codable {
    enum CodingKeys: String, CodingKey {
        case temperatureScale
        case weatherIconName
        case defaultBackgroundName
        case temperature
        case minTemp
        case maxTemp
        case city
        case lastUpdated
        case feelsLike
        case humidity
        case windSpeed
        case windDirection
        case weatherType
    }
    
    public init(from decoder: Decoder) throws {
        self.init()
        do {
            let container = try decoder.container(keyedBy: CodingKeys.self)
            let scaleInt = try container.decode(Int.self, forKey: .temperatureScale)
            toggleScale(to: scaleInt)
            weatherIconName = try container.decode(String.self, forKey: .weatherIconName)
            defaultBackgroundName = try container.decode(String.self, forKey: .defaultBackgroundName)
            temperatureCelsius = try container.decode(Int.self, forKey: .temperature)
            minTempCelsius = try container.decode(Int.self, forKey: .minTemp)
            maxTempCelsius = try container.decode(Int.self, forKey: .maxTemp)
            city = try container.decode(String.self, forKey: .city)
            lastUpdated = try container.decode(Date.self, forKey: .lastUpdated)
            humidity = try container.decode(Int.self, forKey: .humidity)
            windSpeed = try container.decode(Int.self, forKey: .windSpeed)
            windDirectionInDegrees = try container.decode(Double.self, forKey: .windDirection)
            weatherType = try container.decode(ImageWeatherType.self, forKey: .weatherType)
        } catch {
            print(error.localizedDescription)
        }
    }
    
    public func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        let scaleInt = temperatureScale.rawValue
        try container.encode(scaleInt, forKey: .temperatureScale)
        try container.encode(weatherIconName, forKey: .weatherIconName)
        try container.encode(defaultBackgroundName, forKey: .defaultBackgroundName)
        try container.encode(temperatureCelsius, forKey: .temperature)
        try container.encode(minTempCelsius, forKey: .minTemp)
        try container.encode(maxTempCelsius, forKey: .maxTemp)
        try container.encode(city, forKey: .city)
        try container.encode(lastUpdated, forKey: .lastUpdated)
        try container.encode(humidity, forKey: .humidity)
        try container.encode(windSpeed, forKey: .windSpeed)
        try container.encode(windDirectionInDegrees, forKey: .windDirection)
        try container.encode(weatherType, forKey: .weatherType)
    }
}
