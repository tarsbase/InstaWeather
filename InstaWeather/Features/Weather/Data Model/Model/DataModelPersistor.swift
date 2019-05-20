//
//  DataModelPersistor.swift
//  InstaWeather
//
//  Created by Besher on 2019-05-20.
//  Copyright © 2019 Besher Al Maleh. All rights reserved.
//

import UIKit

enum DataModelPersistor {
    static func saveDataModel(model: WeatherDataModel) {
        let defaults = UserDefaults.standard
        defaults.set(model.weatherIconName, forKey: "conditionImage")
        defaults.set(model.defaultBackgroundName, forKey: "backgroundName")
        defaults.set(model.temperatureCelsius, forKey: "temperature")
        defaults.set(model.minTempCelsius, forKey: "minTemp")
        defaults.set(model.maxTempCelsius, forKey: "maxTemp")
        defaults.set(model.city, forKey: "city")
        defaults.set(model.lastUpdated, forKey: "lastUpdated")
        defaults.set(model.feelsLikeCelsius, forKey: "feelsLike")
        defaults.set(model.humidity, forKey: "humidity")
        defaults.set(model.windSpeed, forKey: "windSpeed")
        defaults.set(model.windDirectionInDegrees, forKey: "windDirection")
        let scale = model.scaleIsCelsius.rawValue
        defaults.set(scale, forKey: "temperatureScale")
    }
    
    static func loadDataModel() -> WeatherDataModel {
        let defaults = UserDefaults.standard
        let scale = defaults.integer(forKey: "temperatureScale")
        var model = WeatherDataModel(scale: scale)
        model.windSpeed = defaults.integer(forKey: "windSpeed")
        model.windDirectionInDegrees = defaults.double(forKey: "windDirection")
        model.weatherIconName = defaults.string(forKey: "conditionImage") ?? "light_rain"
        model.defaultBackgroundName = defaults.string(forKey: "backgroundName") ?? "bglight_rain"
        model.temperature = defaults.integer(forKey: "temperature")
        model.minTemp = defaults.integer(forKey: "minTemp")
        model.maxTemp = defaults.integer(forKey: "maxTemp")
        model.feelsLike = defaults.integer(forKey: "feelsLike")
        model.humidity = defaults.integer(forKey: "humidity")
        model.city = defaults.string(forKey: "city") ?? "Montreal"
        if let date = defaults.object(forKey: "lastUpdated") as? Date {
            model.lastUpdated = date
        }
        return model
    }
}
