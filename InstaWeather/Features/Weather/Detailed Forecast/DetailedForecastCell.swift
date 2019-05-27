//
//  DetailedForecastCell.swift
//  InstaWeather
//
//  Created by Besher on 2019-05-26.
//  Copyright © 2019 Besher Al Maleh. All rights reserved.
//

import UIKit

class DetailedForecastCell: UITableViewCell {
    
    @IBOutlet weak var iconView: UIImageView!
    @IBOutlet weak var timeLabel: UILabel!
    @IBOutlet weak var tempLabel: UILabel!

    var views: [UIView] { return [iconView, timeLabel, tempLabel] }
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
    func setup(with model: WeatherDataModel?, indexPath: IndexPath) {
        guard var model = model else { return }
        let section = model.forecastSections[indexPath.section]
        let time = section.forecastChunks[indexPath.row].time
        let icon = section.forecastChunks[indexPath.row].condition
        let minTemp = model.minTempForSection(indexPath.section, row: indexPath.row)
        let maxTemp = model.maxTempForSection(indexPath.section, row: indexPath.row)
        let timeDigits = section.forecastChunks[indexPath.row].timeDigits
        let sunrise = section.forecastChunks[indexPath.row].sunrise
        let sunset = section.forecastChunks[indexPath.row].sunset
        let iconName = model.updateOpenWeatherIcon(condition: icon,
                                                    objectTime: timeDigits,
                                                    objectSunrise: sunrise,
                                                    objectSunset: sunset)
        iconView.image = UIImage(named: iconName)
        timeLabel.text = time
        
        var temp = 0
        if (minTemp + maxTemp) != 0 { temp = Int((minTemp + maxTemp) / 2) }
        tempLabel.text = "\(String(temp))°"
    }
    
    func applyStyling(with color: UIColor, addShadow: Bool) {
        self.backgroundColor = UIColor.clear
        views.forEach {
            if addShadow {
                $0.addShadow()
            } else {
                $0.removeShadow()
            }
        }
        
        iconView.tintColor = color
        timeLabel.textColor = color
        tempLabel.textColor = color
    }
}
