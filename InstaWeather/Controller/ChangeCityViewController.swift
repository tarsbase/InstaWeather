//
//  ChangeCityViewController.swift
//  Rain Check
//
//  Created by Besher on 2018-01-27.
//  Copyright © 2018 Besher Al Maleh. All rights reserved.
//

import UIKit
import SVProgressHUD
import CoreLocation
import MapKit

protocol ChangeCityDelegate {
    func assignDelegate()
    func getWeatherForCoordinates(latitude: String, longitude: String, location: CLLocation, city: String)
    var locationManager: CLLocationManager { get }
}

protocol RecentPicksDataSource {
    func removeLastRecentPick()
}

class ChangeCityViewController: UIViewController, RecentPicksDataSource, UITextFieldDelegate {
    
    @IBOutlet weak var autoCompleteContainer: UIView!
    @IBOutlet weak var tableContainer: UIView!
    @IBOutlet weak var backgroundImage: UIImageView!
    @IBOutlet weak var cityField: UITextField!
    @IBOutlet weak var autoCompleteConstraint: NSLayoutConstraint!
    @IBOutlet weak var tablePicksConstraint: NSLayoutConstraint!
    @IBOutlet weak var checkBtn: UIButton!
    var delegate: ChangeCityDelegate?
    var picksTable: RecentPicksTable?
    var autoCompleteTable: AutoCompleterTable?
    var recentPicks = [String]() {
        didSet {
            UserDefaults.standard.set(recentPicks, forKey: "recentPicks")
        }
    }
    
    override var preferredStatusBarStyle: UIStatusBarStyle {
        return .lightContent
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.cityField.delegate = self
        SVProgressHUD.setBackgroundColor(UIColor.white)
        SVProgressHUD.setDefaultMaskType(.gradient)
        
    }
    
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        if let loadObjet = UserDefaults.standard.array(forKey: "recentPicks") as? [String] {
            recentPicks = loadObjet
        }
        if !recentPicks.isEmpty {
            picksTable = storyboard?.instantiateViewController(withIdentifier: "picks") as? RecentPicksTable
            if let picksTable = picksTable {
                add(picksTable, frame: tableContainer.frame)
                picksTable.tableView.reloadData()
            }
        }
        
        autoCompleteTable = storyboard?.instantiateViewController(withIdentifier: "autocomplete") as? AutoCompleterTable
        autoCompleteTable?.changeCityVC = self
        if let autoCompleteTable = autoCompleteTable {
            add(autoCompleteTable, frame: tableContainer.frame)
        }
        autoCompleteConstraint.constant = 0
    }
    
    // necessary to line up the tableView properly
    override func viewDidLayoutSubviews() {
        picksTable?.view.frame = tableContainer.frame
        autoCompleteTable?.view.frame = autoCompleteContainer.frame
        super.viewDidLayoutSubviews()
    }
    
        
    override func viewWillDisappear(_ animated: Bool) {
        picksTable?.remove()
        autoCompleteTable?.remove()
        super.viewWillDisappear(animated)
    }
   
    
    @IBAction func checkWeatherButton(_ sender: Any) {
        searchFirstResult()
    }
    
    
    @IBAction func backButton(_ sender: Any) {
        dismiss(animated: true)
    }
    
    func checkWeatherFromAutocomplete(for result: String) {
        SVProgressHUD.show()
        UserDefaults.standard.set(result, forKey: "cityChosen")
        let indexOfComma = result.index(of: ",")
        var city = result
        
        if let index = indexOfComma {
            city = String(result[result.startIndex..<index])
        }
        
        let request = MKLocalSearchRequest()
        request.naturalLanguageQuery = result
        let search = MKLocalSearch(request: request)
        search.start { [unowned self](response, error) in
            guard let response = response, result.count > 1 else {
                self.dismiss(animated: true) {
                    SVProgressHUD.dismiss()
                }
                return }
            if let coordinates = response.mapItems.first?.placemark.coordinate {
                let latitude = coordinates.latitude
                let longitude = coordinates.longitude
                self.delegate?.getWeatherForCoordinates(latitude: String(latitude), longitude: String(longitude), location: CLLocation(latitude: latitude, longitude: longitude), city: city)
                let name = result.lowercased().capitalized
                if !self.recentPicks.contains(name) {
                    self.recentPicks.insert(name, at: 0)
                } else {
                    if let index = self.recentPicks.index(of: name) {
                        self.recentPicks.insert(self.recentPicks.remove(at: index), at: 0)
                    }
                }
                self.dismiss(animated: true) {
                    SVProgressHUD.dismiss()
                }
            }
        }
    }
    
    @IBAction func currentLocationButton(_ sender: Any) {
        delegate?.assignDelegate()
        delegate?.locationManager.startUpdatingLocation()
        UserDefaults.standard.removeObject(forKey: "cityChosen")
        SVProgressHUD.show()
        dismiss(animated: true) {
            SVProgressHUD.dismiss()
        }
    }
    
    func deleteCity(_ city: String) {
        let cityToDelete = city.lowercased().capitalized
        if let index = recentPicks.index(of: cityToDelete) {
            recentPicks.remove(at: index)
        }
    }
    
    func removeLastRecentPick() {
        recentPicks.removeFirst()
        UserDefaults.standard.set(recentPicks, forKey: "recentPicks")
    }
    
    // MARK: - UITextField Delegate methods
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        textField.resignFirstResponder()
        searchFirstResult()
        return true
    }
    
    func searchFirstResult() {
        var cityName = cityField.text!
        if let searchResult = autoCompleteTable?.completionResults.first {
            cityName = searchResult
        }
        checkWeatherFromAutocomplete(for: cityName)
    }
    
    func textField(_ textField: UITextField, shouldChangeCharactersIn range: NSRange, replacementString string: String) -> Bool {
        autoCompleteTable?.startCompleter()
        return true
    }
    
    func showAutoComplete() {
        UIView.animate(withDuration: 0.2, delay: 0, options: .curveEaseOut, animations: {
            [weak self] in
            self?.autoCompleteConstraint.constant = 180
            self?.tablePicksConstraint.constant = 20
            self?.checkBtn.alpha = 0
            self?.view.layoutIfNeeded()
        })
        
    }
    
    func hideAutoComplete() {
        UIView.animate(withDuration: 0.3, delay: 0, options: .curveEaseOut, animations: {
            [weak self] in
            self?.autoCompleteConstraint.constant = 0
            self?.tablePicksConstraint.constant = 50
            self?.view.layoutIfNeeded()
            }, completion: {
                [weak self] _ in
                UIView.animate(withDuration: 0.2, animations: {
                    [weak self] in
                    self?.checkBtn.alpha = 1
                })
        })
    }
}
