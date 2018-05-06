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

protocol ChangeCityDelegate {
    func userEnteredNewCity (city: String)
    func assignDelegate()
    var locationManager: CLLocationManager { get }
}

protocol RecentPicksDataSource {
    func removeLastRecentPick()
}

class ChangeCityViewController: UIViewController, RecentPicksDataSource, UITextFieldDelegate {
    
    @IBOutlet weak var tableContainer: UIView!
    @IBOutlet weak var backgroundImage: UIImageView!
    @IBOutlet weak var cityField: UITextField!
    var delegate: ChangeCityDelegate?
    var picksTable: RecentPicksTable?
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
            add(picksTable!, frame: tableContainer.frame)
            picksTable?.tableView.reloadData()
        }
    }
    
    override func viewDidLayoutSubviews() {
        picksTable?.view.frame = tableContainer.frame
    }
    
        
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        picksTable?.remove()
    }
   
    
    @IBAction func checkWeatherButton(_ sender: Any) {
        let cityName = cityField.text!
        checkWeather(city: cityName)
    }
    
    
    @IBAction func backButton(_ sender: Any) {
        dismiss(animated: true)
    }
    
    func checkWeather(city: String) {
        if city != "" {
            delegate?.userEnteredNewCity(city: city)
            let name = city.lowercased().capitalized
            if !recentPicks.contains(name) {
                recentPicks.insert(name, at: 0)
            } else {
                if let index = recentPicks.index(of: name) {
                    recentPicks.insert(recentPicks.remove(at: index), at: 0)
                }
            }
            SVProgressHUD.show()
        }
        dismiss(animated: true) {
            SVProgressHUD.dismiss()
        }
    }
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        textField.resignFirstResponder()
        checkWeather(city: cityField.text!)
        return true
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

}
