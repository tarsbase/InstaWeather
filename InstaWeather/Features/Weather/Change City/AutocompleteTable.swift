//
//  AutoCompleterTableTableViewController.swift
//  InstaWeather
//
//  Created by Besher on 2018-07-14.
//  Copyright © 2018 Besher Al Maleh. All rights reserved.
//

import UIKit

//protocol AutocompleteDelegate: AnyObject {
//    func updateWith(autocomplete: [String])
//    func getCityText() -> String?
//    func checkWeatherFromAutocomplete(for result: String)
//}

protocol HandlerDelegate: AnyObject {
    var firstAutocompleteResult: String? { get }
    func updateTable(with results: [String])
}

class AutocompleteTable: UITableViewController, HandlerDelegate {
    
    var handler: AutocompleteHandler?
    weak var delegate: AutocompleteDelegate?

    var completionResults = [String]() {
        // update constraints in ViewController
        didSet {
            if completionResults != oldValue {
                delegate?.updateConstraintsWith(autocomplete: completionResults)
                tableView.reloadData()
            }
        }
    }
    
    var firstAutocompleteResult: String? {
        return completionResults.first
    }
    
    func setup(delegate: AutocompleteDelegate) {
        view.layer.cornerRadius = 5
        self.delegate = delegate
        handler = AutocompleteHandler(delegate: delegate, table: self)
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        let title = completionResults[indexPath.row]
        AnalyticsEvents.logEvent(.tappedAutoCompleteResult)
        delegate?.filterCityAndCheckWeather(for: title)
    }
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return completionResults.count
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "CityCell", for: indexPath)
        cell.textLabel?.text = completionResults[indexPath.row]
        cell.textLabel?.textColor = UIColor.white
        cell.backgroundColor = UIColor.clear
        return cell
    }
    
    func updateTable(with results: [String]) {
        completionResults = results
    }
    
    func removeResults() {
        completionResults.removeAll()
    }
    
    func checkWeatherFromAutocomplete(for result: String, recentPicks: [String]) {
        delegate?.filterCityAndCheckWeather(for: result)
    }
    
    func searchFirstResult() {
        handler?.searchFirstResult()
    }
}
