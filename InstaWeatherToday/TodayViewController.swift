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
    lazy var labelArray: [UIView] = {
        let array: [UIView] = [conditionImage, minTempLabel, maxTempLabel, currentTempLabel, cityLabel, summaryLabel, nextHourLabel]
        for label in array {
//            label.alpha = 0
        }
        return array
    }()
    lazy var scale: String = {
        var scale = ""
        if let defaults = UserDefaults(suiteName: "group.com.besher.InstaWeather") {
            if let loadObject = defaults.object(forKey: "tempScale") as? Int {
                if loadObject == 0 {
                    scale = "ca"
                } else {
                    scale = "us"
                }
            }
        }
        return scale
    }()
    
    
    
    let locationManager = CLLocationManager()
    var todayModel = TodayDataModel()
    
    
    
    override func viewWillAppear(_ animated: Bool) {
        // TODO: Use cached data
        
        
        // TODO : Add fade in animation
        for case let label as UIView in labelArray {
//            UIView.animate(withDuration: 1, animations: {
//                label.alpha = 1
//                })
        }
        
        extensionContext?.open(URL(string: "INSTAWEATHER_URL:")!, completionHandler: nil)
        
        assignDelegate()
        locationManager.desiredAccuracy = kCLLocationAccuracyHundredMeters
        locationManager.requestWhenInUseAuthorization()
        updateData()
    }
    
    // TODO : save weather data for next ViewDidLoad temporarily before connection
    
    override func viewDidLoad() {
        super.viewDidLoad()

        conditionImage.image = conditionImage.image?.withRenderingMode(.alwaysTemplate)
        
        
        // Do any additional setup after loading the view from its nib.
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    func updateTodayModelWith(longitude: String, latitude: String) {
        let urlBegin = "https://api.darksky.net/forecast/"
        let coords = latitude + "," + longitude
        let units = "?units=\(scale)" // TODO: Change according to saved settings in main app
        let url = urlBegin + DARK_SKY + coords + units
        
        Alamofire.request(url, method: .get, parameters: nil).responseJSON {
            [unowned self] response in
            if response.result.isSuccess {
                let weatherJSON = JSON(response.result.value!)
                self.updateLabelsFrom(weatherJSON)
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
//            getWeatherData(url: weatherDataModel.weatherURL, parameters: params)
        }
    }
    
    func updateCityFromLocation(location: CLLocation){
        CLGeocoder().reverseGeocodeLocation(location, completionHandler:
            {
                [unowned self] (placemarks, error) in
                if let error = error {
                    print("Reverse geodcode failed: \(error.localizedDescription)")
                }
                guard let pm = placemarks, let possibleCity = pm.first, let city = possibleCity.locality else { return }
                self.cityLabel.text = city
        })
    }
    
    func updateLabelsFrom(_ json: JSON) {
        // TODO: save data
        let currentTemp = json["currently"]["temperature"].intValue
        let maxTemp = json["daily"]["data"][0]["temperatureHigh"].intValue
        let minTemp = json["daily"]["data"][0]["temperatureLow"].intValue
        let summary = json["hourly"]["data"][0]["summary"].stringValue
        
        currentTempLabel.text = "\(currentTemp)°"
        maxTempLabel.text = "↑ \(maxTemp)"
        minTempLabel.text = "↓ \(minTemp)"
        summaryLabel.text = summary
    }
    
    
    
    func widgetPerformUpdate(completionHandler: (@escaping (NCUpdateResult) -> Void)) {
        // Perform any setup necessary in order to update the view.
        
        // If an error is encountered, use NCUpdateResult.Failed
        // If there's no update required, use NCUpdateResult.NoData
        // If there's an update, use NCUpdateResult.NewData
        
        completionHandler(NCUpdateResult.newData)
    }
}
