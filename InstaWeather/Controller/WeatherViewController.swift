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
    @IBOutlet weak var feelsLikeLabel: UILabel!
    @IBOutlet weak var windLabel: UILabel!
    @IBOutlet weak var humidityLabel: UILabel!
    @IBOutlet weak var windIcon: UIImageView!
    
    let locationManager = CLLocationManager()
    var weatherDataModel = WeatherDataModel()
    var recentPicksDataSource: RecentPicksDataSource?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        assignDelegate()
        locationManager.desiredAccuracy = kCLLocationAccuracyHundredMeters
        locationManager.requestWhenInUseAuthorization()
        updateData()
        loadScale()
        // updates location when app goes to foreground
        NotificationCenter.default.addObserver(forName: .UIApplicationWillEnterForeground, object: nil, queue: .main) {
            [unowned self] _ in
            self.assignDelegate()
            self.updateData()
        }
        addShadow(segmentedControl, conditionImage, changeCityButton, cityLabel, tempLabel, maxTempLabel, minTempLabel, feelsLikeLabel, windLabel, humidityLabel, windIcon)
    }
    
    override func viewDidAppear(_ animated: Bool) {
        let feelsLikeScale:CGFloat = 1.06
        let conditionScale:CGFloat = 1.03
        UIView.animate(withDuration: 0.2, delay: 0, options: .curveEaseInOut, animations: {
            [unowned self] in
            self.conditionImage.transform = CGAffineTransform(scaleX: conditionScale, y: conditionScale)
            self.feelsLikeLabel.transform = CGAffineTransform(scaleX: feelsLikeScale, y: feelsLikeScale)
            }, completion: {
                [unowned self] boolean in
                print(boolean)
                UIView.animate(withDuration: 0.2, delay: 0, options: .curveEaseOut, animations: {
                    [unowned self] in
                    self.conditionImage.transform = CGAffineTransform(scaleX: 1, y: 1)
                    self.feelsLikeLabel.transform = CGAffineTransform(scaleX: 1, y: 1)
                    }, completion: nil)
        })
        super.viewDidAppear(animated)
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
        if let defaults = UserDefaults(suiteName: "group.com.besher.InstaWeather") {
            defaults.set(segmentedControl.selectedSegmentIndex, forKey: "tempScale")
        }
    }
    
    func evaluateSegment(onStartup: Bool = false) {
        weatherDataModel.toggleScale(to: segmentedControl.selectedSegmentIndex)
        if !onStartup {
            updateLabel(tempLabel, toValue: weatherDataModel.temperature, forType: .mainTemperature)
            updateLabel(minTempLabel, toValue: weatherDataModel.minTemp, forType: .minTemp)
            updateLabel(maxTempLabel, toValue: weatherDataModel.maxTemp, forType: .maxTemp)
            updateYahooLabels()
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
//    func loadWhiteBackground() {
//
//        // start with white background
//        let rect = CGRect(x: 0, y: 0, width: view.frame.size.width, height: view.frame.size.height)
//        UIGraphicsBeginImageContextWithOptions(view.frame.size, false, 0)
//        UIColor.white.setFill()
//        UIRectFill(rect)
//        let image: UIImage = UIGraphicsGetImageFromCurrentImageContext()!
//        UIGraphicsEndImageContext()
//        backgroundImage.image = image
//    }
    func assignDelegate() {
        locationManager.delegate = self
    }
    
    func loadScale() { // takes migration into account
        if let defaults = UserDefaults(suiteName: "group.com.besher.InstaWeather") {
            var scale: Int = 0
            if let loadOBject = UserDefaults.standard.object(forKey: "tempScale") as? Int {
                scale = loadOBject
                segmentedControl.selectedSegmentIndex = scale
                clickSegment(self)
                UserDefaults.standard.removeObject(forKey: "tempScale")
            }
            if let loadObject = defaults.object(forKey: "tempScale") as? Int {
                scale = loadObject
            }
            segmentedControl.selectedSegmentIndex = scale
            evaluateSegment(onStartup: true)
        }
    }
    
    func updateLabel(_ label: UILabel, toValue value: Int, forType type: LabelType) {
        let animationObject = CoreAnimationObject(label: label, endValue: value, labelType: type)
        animationObject.updateLabel()
    }
    
}

