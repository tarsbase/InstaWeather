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
    weak var imageMenu: ImageMenu?
    private var cellsColor: UIColor = .red
    private var cellsShadow: Bool = false
    let backgroundAlpha: CGFloat = 0.5
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        tableView.reloadData()
        DispatchQueue.main.asyncAfter(deadline: .now() + 3.5) { [weak self] in
            self?.tableView.flashScrollIndicators()
        }
        
        // inset parameters
        self.tableView.contentInset = UIEdgeInsets(top: 0, left: 0, bottom: 40, right: 0)
        
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) { [weak self] in
            guard let self = self else { return }
            
            let interval = 0.055
            let translation = CGPoint(x: 12, y: 0)
            let duration = 0.17
            
            for (index, cell) in self.tableView.visibleCells.enumerated() {
                let delay = interval * Double(index)
                DispatchQueue.main.asyncAfter(deadline: .now() + delay) {
                    cell.animate(.translate(by: translation, duration: duration),
                                 .reset(duration: duration))
                }
            }
        }
    }
    
    func setup(with model: WeatherDataModel, imageMenu: ImageMenu) {
        self.model = model
        self.imageMenu = imageMenu
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
        guard let cell = tableView.dequeueReusableCell(withIdentifier: "DetailedForecastCell", for: indexPath)
            as? DetailedForecastCell else { fatalError() }
        cell.setup(with: model, indexPath: indexPath)
        cell.applyStyling(with: cellsColor, addShadow: cellsShadow)
        return cell
    }
    
    func changeCellsColorTo(_ color: UIColor) {
        self.cellsColor = color
        reloadData()
    }
    
    func getCellsToShade() -> [UIView] {
        var cells = [UIView]()
        for cell in tableView.visibleCells {
            cells.append(contentsOf: cell.contentView.subviews)
        }
        return cells
    }
    
    func toggleShadows(to enabled: Bool) {
        self.cellsShadow = enabled
        reloadData()
    }
    
    func reloadData() {
        if imageMenu?.isVisible == true {
            self.tableView.reloadData()
        }
    }
}
