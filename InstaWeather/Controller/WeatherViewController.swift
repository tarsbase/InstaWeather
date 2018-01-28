//
//  ViewController.swift
//  Rain Check
//
//  Created by Besher on 2018-01-27.
//  Copyright © 2018 Besher Al Maleh. All rights reserved.
//

import UIKit
import CoreLocation

class WeatherViewController: UIViewController, ChangeCityDelegate {
    @IBOutlet weak var segmentedControl: UISegmentedControl!
    @IBOutlet weak var changeCityButton: UIButton!
    @IBOutlet weak var backgroundImage: UIImageView!
    @IBOutlet weak var tempLabel: UILabel!
    @IBOutlet weak var cityLabel: UILabel!
    @IBOutlet weak var conditionImage: UIImageView!
    
    let WEATHER_URL = "http://api.openweathermap.org/data/2.5/weather"
    let locationManager = CLLocationManager()
    var weatherDataModel = WeatherDataModel()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        locationManager.delegate = self
        locationManager.desiredAccuracy = kCLLocationAccuracyHundredMeters
        locationManager.requestWhenInUseAuthorization()
        locationManager.startUpdatingLocation()
        
        let defaults = UserDefaults.standard
        if let loadObject = defaults.object(forKey: "tempScale") as? Int {
                segmentedControl.selectedSegmentIndex = loadObject
                evaluateSegment()
        }
        
        addShadow(segmentedControl, conditionImage, changeCityButton, cityLabel, tempLabel)
    }
    
    
    
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "changeCity" {
            if let destination = segue.destination as? ChangeCityViewController {
                destination.delegate = self
            }
        }
    }
    @IBAction func clickSegment(_ sender: Any) {
        evaluateSegment()
        let defaults = UserDefaults.standard
        defaults.set(segmentedControl.selectedSegmentIndex, forKey: "tempScale")
    }
    
    func evaluateSegment() {
        var temp = weatherDataModel.temperature
        if segmentedControl.selectedSegmentIndex == 0 {
            tempLabel.text = "\(temp)°"
        } else {
            temp = Int((Double(temp) * 1.8) + 32)
            tempLabel.text = "\(temp)°"
        }
    }
    
    func addShadow(_ views: UIView...) {
        for view in views {
            view.layer.shadowColor = UIColor.black.cgColor
            view.layer.shadowOffset = CGSize(width: 0, height: 2)
            view.layer.shadowOpacity = 0.5
            view.layer.shadowRadius = 1.0
        }
    }
    
}

