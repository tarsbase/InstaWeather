//
//  RecentPicksTable.swift
//  InstaWeather
//
//  Created by Besher on 2018-01-28.
//  Copyright © 2018 Besher Al Maleh. All rights reserved.
//

import UIKit

protocol RecentPicksDelegate {
    func deleteCity(_ city: String)
    func checkWeather(city: String)
    var recentPicks: [String] { get set }
}

class RecentPicksTable: UITableViewController {

    var delegate: RecentPicksDelegate?
    
    override func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        return "Recent Picks"
    }
    
    override func tableView(_ tableView: UITableView, willDisplayHeaderView view: UIView, forSection section: Int){
        let header = view as! UITableViewHeaderFooterView
        header.textLabel?.textColor = UIColor.white
    }
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return delegate?.recentPicks.count ?? 0
    }

    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "Cell", for: indexPath)
        cell.textLabel?.text = delegate?.recentPicks[indexPath.row]
        cell.textLabel?.textColor = UIColor.white
        cell.backgroundColor = UIColor.clear
        return cell
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        if let pick = delegate?.recentPicks[indexPath.row] {
            delegate?.checkWeather(city: pick)
        }
    }
    
    override func tableView(_ tableView: UITableView, editActionsForRowAt indexPath: IndexPath) -> [UITableViewRowAction]? {
        let delete = UITableViewRowAction(style: .destructive, title: "Delete") {
            [unowned self] action, index in
            self.delegate?.recentPicks.remove(at: index.row)
            tableView.deleteRows(at: [index], with: .automatic)
        }
        return [delete]
    }
    
}
