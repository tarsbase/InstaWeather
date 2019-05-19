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
    var cellsColor: UIColor = .red
    var cellsShadow: Bool = false
    let backgroundAlpha: CGFloat = 0.5
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        tableView.reloadData()
        DispatchQueue.main.asyncAfter(deadline: .now() + 3.5) {
            [weak self] in
            self?.tableView.flashScrollIndicators()
        }
        
        // inset parameters
        self.tableView.contentInset = UIEdgeInsets(top: 0, left: 0, bottom: 40, right: 0)
        
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
            var counter = 0
            func animateRow() {
                guard counter < self.tableView.visibleCells.count else { return }
                for (index, cell) in self.tableView.visibleCells.enumerated() {
                    if counter == index {
                        counter += 1
                        UIView.animate(withDuration: 0.17, delay: 0, options: [.curveEaseInOut, .allowUserInteraction], animations: {
                            cell.transform = CGAffineTransform(translationX: 12, y: 0)
                        }, completion: {
                            boolean in
                            UIView.animate(withDuration: 0.17, delay: 0, options: .allowUserInteraction, animations: {
                                cell.transform = CGAffineTransform.identity
                            }, completion: nil)
                        })
                        DispatchQueue.main.asyncAfter(deadline: .now() + 0.055) {
                            animateRow()
                        }
                        break
                    }
                }
            }
            animateRow()
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        tableView.showsVerticalScrollIndicator = true
    }

    override func numberOfSections(in tableView: UITableView) -> Int {
        return model?.forecastDayTitles.count ?? 0
    }
    
    
    override func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        return model?.forecastDayTitles[section]
    }
    
    override func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        if let cell = tableView.dequeueReusableCell(withIdentifier: "headerCell") {
            cell.backgroundColor = UIColor(red: 0, green: 0, blue: 0, alpha: backgroundAlpha)
            cell.textLabel?.text = model?.forecastDayTitles[section]
            cell.textLabel?.textAlignment = NSTextAlignment.center
            cell.textLabel?.textColor = cellsColor
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
        let minTemp = currentModel.minTempForSection(indexPath.section, row: indexPath.row)
        let maxTemp = currentModel.maxTempForSection(indexPath.section, row: indexPath.row)
        let timeDigits = section.forecastChunks[indexPath.row].timeDigits
        let sunrise = section.forecastChunks[indexPath.row].sunrise
        let sunset = section.forecastChunks[indexPath.row].sunset
        
        let cell = tableView.dequeueReusableCell(withIdentifier: "cell", for: indexPath)
        cell.backgroundColor = UIColor.clear
        for case let imageView as UIImageView in cell.contentView.subviews {
            let iconName = model?.updateOpenWeatherIcon(condition: icon, objectTime: timeDigits, objectSunrise: sunrise, objectSunset: sunset) ?? ""
            imageView.image = UIImage(named: iconName)
            imageView.tintColor = cellsColor
            if cellsShadow { addShadow(imageView) }
        }
        for case let label as UILabel in cell.contentView.subviews {
            label.textColor = cellsColor
            if cellsShadow { addShadow(label) }
            
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
    
    func changeCellsColorTo(_ color: UIColor) {
        self.cellsColor = color
        for cell in tableView.visibleCells {
            let subviews = cell.contentView.subviews
            subviews.forEach { $0.tintColor = color }
            _ = subviews.map { $0 as? UILabel }.compactMap { $0?.textColor = color }
            _ = subviews.map { $0 as? UIButton }.compactMap { $0?.setTitleColor(color, for: .normal) }
        }
    }
    
    func getCellsToShade() -> [UIView] {
        var cells = [UIView]()
        for cell in tableView.visibleCells {
            cells.append(contentsOf: cell.contentView.subviews)
        }
        return cells
    }
    
    func addShadow(opacity: Float = 0.5, _ views: UIView...) {
        for view in views {
            view.layer.shadowColor = UIColor.black.cgColor
            view.layer.shadowOffset = CGSize(width: 0, height: 2)
            view.layer.shadowOpacity = opacity
            view.layer.shadowRadius = 1.0
        }
    }
}
