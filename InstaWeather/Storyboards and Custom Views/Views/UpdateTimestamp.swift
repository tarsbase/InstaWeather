//
//  UpdateTimestamp.swift
//  InstaWeather
//
//  Created by Besher on 2019-05-26.
//  Copyright © 2019 Besher Al Maleh. All rights reserved.
//

import UIKit

class UpdateTimestamp: UILabel {

    func update(model: WeatherDataModel) -> WeatherDataModel {
        let date = Date()
        var updatedModel = model
        updatedModel.lastUpdated = date
        updateLabel(withDate: date)
        return updatedModel
    }
    
    func updateLabel(withDate date: Date) {
        let formatter = DateFormatter()
        formatter.dateStyle = .medium
        formatter.timeStyle = .short
        let dateString = formatter.string(from: date)
        self.text = "Last update: \(dateString)"
    }

}
