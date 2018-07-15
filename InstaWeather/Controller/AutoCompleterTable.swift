//
//  AutoCompleterTableTableViewController.swift
//  InstaWeather
//
//  Created by Besher on 2018-07-14.
//  Copyright © 2018 Besher Al Maleh. All rights reserved.
//

import UIKit
import MapKit

class AutoCompleterTable: UITableViewController, MKLocalSearchCompleterDelegate {

    var changeCityVC: ChangeCityViewController?
    let completer = MKLocalSearchCompleter()
    var completionResults = [String]() {
        didSet {
            if completionResults.count > 0 && changeCityVC?.cityField.text != "" {
                changeCityVC?.showAutoComplete()
            } else {
                changeCityVC?.hideAutoComplete()
                completionResults.removeAll() // prevents crash
            }
        }
    }
    var cityfieldText: String {
        return changeCityVC?.cityField.text ?? ""
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()

        view.layer.cornerRadius = 5
        
        completer.delegate = self
        completer.filterType = .locationsOnly
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
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        let title = completionResults[indexPath.row]
        changeCityVC?.checkWeatherFromAutocomplete(for: title)
    }
    
    func startCompleter() {
        completer.queryFragment = cityfieldText
    }
    
    func completerDidUpdateResults(_ completer: MKLocalSearchCompleter) {
        update()
    }
    
    func update() {
        completionResults = completer.results.filter {
            let rangeOfDigits = $0.subtitle.rangeOfCharacter(from: .decimalDigits)
            return rangeOfDigits == nil
            }.map { $0.title }
        NSLog("\(cityfieldText)")
        NSLog("\(completionResults.count)")
        print(completionResults)
        tableView.reloadData()
        
    }
}
