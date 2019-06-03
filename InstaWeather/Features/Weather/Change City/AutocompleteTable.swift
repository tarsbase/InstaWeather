//
//  AutoCompleterTableTableViewController.swift
//  InstaWeather
//
//  Created by Besher on 2018-07-14.
//  Copyright © 2018 Besher Al Maleh. All rights reserved.
//

import UIKit

protocol HandlerDelegate: AnyObject {
    var firstAutocompleteResult: String? { get }
    func updateTable(with results: [String])
}

class AutocompleteTable: UITableViewController, HandlerDelegate {
    
    private(set) var handler: AutocompleteHandler?
    private weak var delegate: AutocompleteDelegate?
    
    private var completionResults = [String]() {
        // update constraints in ViewController
        didSet { processCompletion(results: completionResults, oldValue: oldValue) }
        
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
    
    private func removeResults() {
        completionResults.removeAll()
    }
    
    private func checkWeatherFromAutocomplete(for result: String, recentPicks: [String]) {
        delegate?.filterCityAndCheckWeather(for: result)
    }
    
    func searchFirstResult() {
        handler?.searchFirstResult()
    }
    
    private func processCompletion(results: [String], oldValue: [String]) {
        if results != oldValue {
            let city = delegate?.cityField.text ?? ""
            
            if results.count > 0 && city != "" {
                delegate?.toggleAutoComplete(visible: true)
            } else {
                delegate?.toggleAutoComplete(visible: false)
                removeResults() // prevents crash
            }
            tableView.reloadData()
        }
    }
}
