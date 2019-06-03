//
//  RecentPicksTable.swift
//  InstaWeather
//
//  Created by Besher on 2018-01-28.
//  Copyright © 2018 Besher Al Maleh. All rights reserved.
//

import UIKit

protocol RecentPicksDelegate: AnyObject {
    func filterCityAndCheckWeather(for result: String)
}

class RecentPicksTable: UITableViewController {
    
    private var cellsColor: UIColor = .red
    weak var delegate: RecentPicksDelegate?
    var recentPicks = [String]() {
        didSet { DataPersistor.setRecentPicks(recentPicks) }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        loadRecentPicksFromDisk()
    }
    
    override func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        return "Recent Picks"
    }
    
    override func tableView(_ tableView: UITableView, willDisplayHeaderView view: UIView, forSection section: Int){
        let header = view as! UITableViewHeaderFooterView
        header.textLabel?.textColor = .white
        if #available(iOS 11.0, *) {
            header.backgroundView?.backgroundColor = UIColor(named: "RecentPicksHeader")
        } else {
            header.backgroundView?.backgroundColor = UIColor(red: 46/255, green: 50/255, blue: 56/255, alpha: 1)
        }
    }
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return recentPicks.count
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "Cell", for: indexPath)
        cell.textLabel?.text = recentPicks[indexPath.row]
        cell.textLabel?.textColor = cellsColor
        cell.backgroundColor = UIColor.clear
        return cell
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        let city = recentPicks[indexPath.row]
        AnalyticsEvents.logEvent(.tappedPreviousCity)
        delegate?.filterCityAndCheckWeather(for: city)
    }
    
    override func tableView(_ tableView: UITableView, editActionsForRowAt indexPath: IndexPath) -> [UITableViewRowAction]? {
        let delete = UITableViewRowAction(style: .destructive, title: "Delete") { [weak self] _, index in
            self?.recentPicks.remove(at: index.row)
            tableView.deleteRows(at: [index], with: .automatic)
        }
        return [delete]
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
    
    private func loadRecentPicksFromDisk() {
        let recentPicks = DataPersistor.getRecentPicks()
        guard recentPicks.isEmpty == false else { return }
        self.recentPicks = recentPicks
    }
}
