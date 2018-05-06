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
    @IBOutlet weak var maxTempLabel: UILabel!
    @IBOutlet weak var minTempLabel: UILabel!

    let locationManager = CLLocationManager()
    var weatherDataModel = WeatherDataModel()
    var recentPicksDataSource: RecentPicksDataSource?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        let defaults = UserDefaults.standard
        assignDelegate()
        locationManager.desiredAccuracy = kCLLocationAccuracyHundredMeters
        locationManager.requestWhenInUseAuthorization()
        
        if let loadObject = defaults.string(forKey: "cityChosen") {
            userEnteredNewCity(city: loadObject)
        } else {
            locationManager.startUpdatingLocation()
        }
        
        if let loadObject = defaults.object(forKey: "tempScale") as? Int {
                segmentedControl.selectedSegmentIndex = loadObject
                evaluateSegment()
        }
        
        
        
        // updates location when app goes to foreground
        NotificationCenter.default.addObserver(forName: .UIApplicationWillEnterForeground, object: nil, queue: .main) {
            [unowned self] _ in
            self.assignDelegate()
            self.locationManager.startUpdatingLocation()
        }
        
        addShadow(segmentedControl, conditionImage, changeCityButton, cityLabel, tempLabel, maxTempLabel, minTempLabel)
    }
        
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "changeCity" {
            if let destination = segue.destination as? ChangeCityViewController {
                destination.delegate = self
                recentPicksDataSource = destination
            }
        }
    }
    @IBAction func clickSegment(_ sender: Any) {
        evaluateSegment()
        let defaults = UserDefaults.standard
        defaults.set(segmentedControl.selectedSegmentIndex, forKey: "tempScale")
    }
    
    func evaluateSegment() {
        weatherDataModel.toggleScale(to: segmentedControl.selectedSegmentIndex)
        tempLabel.text = "\(weatherDataModel.temperature)°"
        minTempLabel.text = "↓\(weatherDataModel.minTemp)"
        maxTempLabel.text = "↑\(weatherDataModel.maxTemp)"
    }
    
    func addShadow(_ views: UIView...) {
        for view in views {
            view.layer.shadowColor = UIColor.black.cgColor
            view.layer.shadowOffset = CGSize(width: 0, height: 2)
            view.layer.shadowOpacity = 0.5
            view.layer.shadowRadius = 1.0
        }
    }
    
    func loadWhiteBackground() {
        
        // start with white background
        let rect = CGRect(x: 0, y: 0, width: view.frame.size.width, height: view.frame.size.height)
        UIGraphicsBeginImageContextWithOptions(view.frame.size, false, 0)
        UIColor.white.setFill()
        UIRectFill(rect)
        let image: UIImage = UIGraphicsGetImageFromCurrentImageContext()!
        UIGraphicsEndImageContext()
        backgroundImage.image = image
    }
    func assignDelegate() {
        locationManager.delegate = self
    }
    
    
}

