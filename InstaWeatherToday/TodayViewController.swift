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
    @IBOutlet weak var nextHourLabel: UILabel!
    @IBOutlet weak var umbrellaLabel: UIImageView!
    @IBOutlet weak var percipProbabilityLabel: UILabel!
    lazy var scale: String = {
        var scale = ""
        if let loadObject = defaults?.object(forKey: "tempScale") as? Int {
            if loadObject == 0 {
                scale = "ca"
            } else {
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
        umbrellaLabel.image = umbrellaLabel.image?.withRenderingMode(.alwaysTemplate)
        umbrellaLabel.tintColor = .black
        umbrellaLabel.alpha = 0.6
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        extensionContext?.widgetLargestAvailableDisplayMode = .expanded
        todayModel.loadSavedData()
        updateUI()
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
                self.updateModelWith(weatherJSON)
                self.updateUI()
            } else {
                print(response.result.error?.localizedDescription ?? "Error")
            }
        }
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
    
    func updateModelWith(_ json: JSON) {
        let currentTemp = json["currently"]["temperature"].intValue
        let maxTemp = json["daily"]["data"][0]["apparentTemperatureHigh"].intValue
        let minTemp = json["daily"]["data"][0]["apparentTemperatureLow"].intValue
        let summary = json["minutely"]["summary"].stringValue
        let icon = json["minutely"]["icon"].stringValue
        let percipProbability = json["daily"]["data"][0]["precipProbability"].doubleValue
        todayModel.updateTemperature(currentTemp: currentTemp, maxTemp: maxTemp, minTemp: minTemp, summary: summary, icon: icon, percipProbability: percipProbability)
    }
    
    func updateUI() {
        currentTempLabel.text = "\(todayModel.getCurrentTemp())°"
        maxTempLabel.text = "↑ \(todayModel.getMaxTemp())"
        minTempLabel.text = "↓ \(todayModel.getMinTemp())"
        summaryLabel.text = todayModel.getSummary()
        cityLabel.text = todayModel.getCity()
        percipProbabilityLabel.text = "\(Int(todayModel.getPercipProbability() * 100))%"
        conditionImage.image = UIImage(named: todayModel.getIcon())
    }
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        extensionContext?.open(URL(string: "instaurl:")!, completionHandler: nil)
    }
    
    func updateCityFromLocation(location: CLLocation){
        CLGeocoder().reverseGeocodeLocation(location, completionHandler:
            {
                [unowned self] (placemarks, error) in
                if let error = error {
                    print("Reverse geodcode failed: \(error.localizedDescription)")
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
        } else {
            preferredContentSize = CGSize(width: 0, height: 220)
        }
        
    }
}
