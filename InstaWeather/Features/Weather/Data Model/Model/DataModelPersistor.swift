//
//  DataModelPersistor.swift
//  InstaWeather
//
//  Created by Besher on 2019-05-20.
//  Copyright © 2019 Besher Al Maleh. All rights reserved.
//

import UIKit

enum DataModelPersistor {
    
    static let defaults = UserDefaults.standard
    
    static func loadDataModel() -> WeatherDataModel {
        let decoder = JSONDecoder()
        if let object = defaults.object(forKey: "dataModel") as? Data {
            do {
                return try decoder.decode(WeatherDataModel.self, from: object)
            } catch {
                print(error.localizedDescription)
            }
        }
        
        
        // fallback code for migration
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
        // end of migration code
    }
    
    static func saveDataModel(model: WeatherDataModel) {
        let encoder = JSONEncoder()
        if let data = try? encoder.encode(model) {
            defaults.set(data, forKey: "dataModel")
        }
    }
}
