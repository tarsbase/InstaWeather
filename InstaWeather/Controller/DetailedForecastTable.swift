//
//  DetailedForecastTable.swift
//  InstaWeather
//
//  Created by Besher on 2018-02-01.
//  Copyright © 2018 Besher Al Maleh. All rights reserved.
//

import UIKit

class DetailedForecastTable: UITableViewController {

    var model: WeatherDataModel?
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        refreshModel()
        tableView.reloadData()
        DispatchQueue.main.asyncAfter(deadline: .now() + 3.5) {
            [unowned self] in
            self.tableView.flashScrollIndicators()
        }
        
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        let imageView = UIImageView(image: UIImage(named: "forecast"))
        imageView.contentMode = .scaleAspectFill
        tableView.backgroundView = imageView
        tableView.showsVerticalScrollIndicator = true
    }
    
    func refreshModel() {
        if let parent = self.parent as? PageViewController {
            for case let weatherVC as WeatherViewController in parent.orderedViewControllers {
                model = weatherVC.weatherDataModel
            }
        }
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        self.tableView.contentInset = UIEdgeInsets(top: 10, left: 0, bottom: 40, right: 0)
        
    }

    override func numberOfSections(in tableView: UITableView) -> Int {
        refreshModel()
        return model?.forecastDayTitles.count ?? 0
    }
    
    
    override func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        return model?.forecastDayTitles[section]
    }
    
    override func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        if let cell = tableView.dequeueReusableCell(withIdentifier: "headerCell") {
            cell.backgroundColor = UIColor.clear
            cell.contentView.backgroundColor = UIColor.clear
            cell.textLabel?.text = model?.forecastDayTitles[section]
            cell.textLabel?.textAlignment = NSTextAlignment.center
            cell.textLabel?.textColor = UIColor.white
            cell.textLabel?.font = UIFont.systemFont(ofSize: 18, weight: UIFont.Weight(rawValue: 200))
            return cell
        }
        return nil
    }
    
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        guard let daySections = model?.forecastSections else { return 0 }
        return daySections[section].forecastChunks.count
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let section = model?.forecastSections[indexPath.section], var currentModel = model else { fatalError() }
        
        let time = section.forecastChunks[indexPath.row].time
        let icon = section.forecastChunks[indexPath.row].condition
//        let minTemp = section.forecastChunks[indexPath.row].minTemp
//        let maxTemp = section.forecastChunks[indexPath.row].maxTemp
        let minTemp = currentModel.minTempForSection(indexPath.section, row: indexPath.row)
        let maxTemp = currentModel.maxTempForSection(indexPath.section, row: indexPath.row)
        let timeDigits = section.forecastChunks[indexPath.row].timeDigits
        let sunrise = section.forecastChunks[indexPath.row].sunrise
        let sunset = section.forecastChunks[indexPath.row].sunset
        
        let cell = tableView.dequeueReusableCell(withIdentifier: "cell", for: indexPath)
        cell.backgroundColor = UIColor.clear
        for case let imageView as UIImageView in cell.contentView.subviews {
            let iconName = model?.updateWeatherIcon(condition: icon, objectTime: timeDigits, objectSunrise: sunrise, objectSunset: sunset) ?? ""
            imageView.image = UIImage(named: iconName)
        }
        for case let label as UILabel in cell.contentView.subviews {
            if label.tag == 0 {
                label.text = time
            } else {
                var temp = 0
                if (minTemp + maxTemp) != 0 {
                    temp = Int((minTemp + maxTemp) / 2)
                }
                label.text = "\(String(temp))°"
            }
        }
        return cell
    }
}
