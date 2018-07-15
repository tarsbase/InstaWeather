//
//  TodayViewController.swift
//  InstaWeatherToday
//
//  Created by Besher on 2018-05-07.
//  Copyright © 2018 Besher Al Maleh. All rights reserved.
//

import UIKit
import NotificationCenter
import Alamofire
import SwiftyJSON
import CoreLocation


class TodayViewController: UIViewController, NCWidgetProviding, CLLocationManagerDelegate {
    @IBOutlet weak var conditionImage: UIImageView!
    @IBOutlet weak var cityLabel: UILabel!
    @IBOutlet weak var currentTempLabel: UILabel!
    @IBOutlet weak var minTempLabel: UILabel!
    @IBOutlet weak var maxTempLabel: UILabel!
    @IBOutlet weak var summaryLabel: UILabel!
    @IBOutlet weak var dailySummaryLabel: UILabel!
    @IBOutlet weak var nextHourLabel: UILabel!
    @IBOutlet weak var umbrellaLabel: UIImageView!
    @IBOutlet weak var percipProbabilityLabel: UILabel!
    @IBOutlet weak var dailyStack: UIStackView!
    @IBOutlet weak var divider: UIView!
    
    @IBOutlet weak var dailyTime0: UILabel!
    @IBOutlet weak var dailyTime1: UILabel!
    @IBOutlet weak var dailyTime2: UILabel!
    @IBOutlet weak var dailyTime3: UILabel!
    @IBOutlet weak var dailyTime4: UILabel!
    
    @IBOutlet weak var dailyCondition0: UIImageView!
    @IBOutlet weak var dailyCondition1: UIImageView!
    @IBOutlet weak var dailyCondition2: UIImageView!
    @IBOutlet weak var dailyCondition3: UIImageView!
    @IBOutlet weak var dailyCondition4: UIImageView!
    
    @IBOutlet weak var dailyPrecip0: UILabel!
    @IBOutlet weak var dailyPrecip1: UILabel!
    @IBOutlet weak var dailyPrecip2: UILabel!
    @IBOutlet weak var dailyPrecip3: UILabel!
    @IBOutlet weak var dailyPrecip4: UILabel!
    
    @IBOutlet weak var dailyTemp0: UILabel!
    @IBOutlet weak var dailyTemp1: UILabel!
    @IBOutlet weak var dailyTemp2: UILabel!
    @IBOutlet weak var dailyTemp3: UILabel!
    @IBOutlet weak var dailyTemp4: UILabel!
    
    @IBOutlet weak var umbrella0: UIImageView!
    @IBOutlet weak var umbrella1: UIImageView!
    @IBOutlet weak var umbrella2: UIImageView!
    @IBOutlet weak var umbrella3: UIImageView!
    @IBOutlet weak var umbrella4: UIImageView!
    
    
    lazy var dailyTimes: [UILabel] = {
        return [dailyTime0, dailyTime1, dailyTime2, dailyTime3, dailyTime4]
    }()
    lazy var dailyConditions: [UIImageView] = {
        return [dailyCondition0, dailyCondition1, dailyCondition2, dailyCondition3, dailyCondition4]
    }()
    lazy var dailyPrecips: [UILabel] = {
        return [dailyPrecip0, dailyPrecip1, dailyPrecip2, dailyPrecip3, dailyPrecip4]
    }()
    lazy var dailyTemps: [UILabel] = {
        return [dailyTemp0, dailyTemp1, dailyTemp2, dailyTemp3, dailyTemp4]
    }()
    lazy var umbrellas: [UIImageView] = {
        return [umbrella0, umbrella1, umbrella2, umbrella3, umbrella4, umbrellaLabel]
    }()
    lazy var scale: String = {
        var scale = "ca"
        if let loadObject = defaults?.object(forKey: "tempScale") as? Int {
            if loadObject != 0 {
                scale = "us"
            }
        }
        return scale
    }()
    let locationManager = CLLocationManager()
    var todayModel = TodayDataModel()
    let defaults = UserDefaults(suiteName: "group.com.besher.InstaWeather")
    
    override func viewWillAppear(_ animated: Bool) {
        assignDelegate()
        locationManager.desiredAccuracy = kCLLocationAccuracyHundredMeters
        locationManager.requestWhenInUseAuthorization()
        updateData()
        updateUmbrellas()
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        extensionContext?.widgetLargestAvailableDisplayMode = .expanded
        todayModel.loadSavedData()
        updateUI()
        addShadow(conditionImage)
    }
    
    func assignDelegate() {
        locationManager.delegate = self
    }
    
    func updateData() {
        locationManager.startUpdatingLocation()
    }
    
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        let location = locations[locations.count - 1]
        if location.horizontalAccuracy > 0 {
            locationManager.stopUpdatingLocation()
            locationManager.delegate = nil // prevents multiple refreshes
            updateCityFromLocation(location: location)
            let latitude = String(location.coordinate.latitude)
            let longitude = String(location.coordinate.longitude)
            updateTodayModelWith(longitude: longitude, latitude: latitude)
        }
    }
    
    func updateTodayModelWith(longitude: String, latitude: String) {
        let urlBegin = "https://api.darksky.net/forecast/"
        let coords = latitude + "," + longitude
        let units = "?units=\(scale)"
        let url = urlBegin + DARK_SKY + coords + units
        Alamofire.request(url, method: .get, parameters: nil).responseJSON {
            [unowned self] response in
            if response.result.isSuccess {
                let weatherJSON = JSON(response.result.value!)
                self.todayModel.updateWith(weatherJSON)
                self.updateUI()
            } else {
                print(response.result.error?.localizedDescription ?? "Error")
            }
        }
    }
    
    func updateUI() {
        currentTempLabel.text = "\(todayModel.getCurrentTemp())°"
        maxTempLabel.text = "↑ \(todayModel.getMaxTemp())"
        minTempLabel.text = "↓ \(todayModel.getMinTemp())"
        summaryLabel.text = todayModel.getSummary()
        if todayModel.getSummary() == "" {
            summaryLabel.text = "Hourly forecast is currently unavailable"
        }
        cityLabel.text = todayModel.getCity()
        percipProbabilityLabel.text = "\(Int(todayModel.getPercipProbability() * 100))%"
        conditionImage.image = UIImage(named: todayModel.getIcon())
        dailySummaryLabel.text = "\(todayModel.getDailySummary())"
        let forecastObjects = todayModel.getForecastItems()
        
        for i in forecastObjects.indices {
            dailyTemps[i].text = "\(forecastObjects[i].temp)°"
            dailyPrecips[i].text = "\(Int(forecastObjects[i].precip * 100))%"
            dailyConditions[i].image = UIImage(named: forecastObjects[i].icon)
            dailyTimes[i].text = forecastObjects[i].time
        }
    }
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        extensionContext?.open(URL(string: "instaurl:")!, completionHandler: nil)
    }
    
    func updateCityFromLocation(location: CLLocation){
        CLGeocoder().reverseGeocodeLocation(location, completionHandler:
            {
                [unowned self] (placemarks, error) in
                if let error = error {
                    print("Reverse geocode failed: \(error.localizedDescription)")
                }
                guard let pm = placemarks, let possibleCity = pm.first, let city = possibleCity.locality else { return }
                self.todayModel.updateCity(to: city)
                self.updateUI()
        })
    }
    
    func widgetPerformUpdate(completionHandler: (@escaping (NCUpdateResult) -> Void)) {
        // Perform any setup necessary in order to update the view.
        // If an error is encountered, use NCUpdateResult.Failed
        // If there's no update required, use NCUpdateResult.NoData
        // If there's an update, use NCUpdateResult.NewData
        
        completionHandler(NCUpdateResult.newData)
    }
    
    func widgetActiveDisplayModeDidChange(_ activeDisplayMode: NCWidgetDisplayMode, withMaximumSize maxSize: CGSize) {
        if activeDisplayMode == .compact {
            preferredContentSize = CGSize(width: 0, height: 110)
            hide(views: dailyStack, divider)
        } else {
            preferredContentSize = CGSize(width: 0, height: 260)
            show(views: dailyStack, divider)
        }
    }
    
    func updateUmbrellas() {
        umbrellas.forEach { $0.alpha = 0.6 }
    }
    
    func hide(views: UIView...) {
        UIView.animate(withDuration: 0.4) {
            for view in views {
                view.alpha = 0
            }
        }
    }
    
    func show(views: UIView...) {
        UIView.animate(withDuration: 0.4) {
            for view in views {
                view.alpha = 1
            }
        }
    }
    
    func addShadow(_ views: UIView...) {
        for view in views {
            view.layer.shadowColor = UIColor.black.cgColor
            view.layer.shadowOffset = CGSize(width: 0, height: 0)
            view.layer.shadowOpacity = 0.5
            view.layer.shadowRadius = 1
            
        }
    }
    
    func locationManager(_ manager: CLLocationManager, didFailWithError error: Error) {
        nextHourLabel.text = ""
        cityLabel.text = "Location Unknown"
        summaryLabel.text = "Please activate location services for InstaWeather in the settings"
    }
}
