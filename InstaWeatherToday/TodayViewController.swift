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
    
    let locationManager = CLLocationManager()
    var todayModel = TodayDataModel()
    
    override func viewWillAppear(_ animated: Bool) {
        assignDelegate()
        locationManager.desiredAccuracy = kCLLocationAccuracyHundredMeters
        locationManager.requestWhenInUseAuthorization()
        updateData()
    }
    
    // TODO : save weather data for next ViewDidLoad temporarily before connection
    
    override func viewDidLoad() {
        super.viewDidLoad()

        conditionImage.image = conditionImage.image?.withRenderingMode(.alwaysTemplate)
        conditionImage.tintColor = .darkGray
        
        let urlBegin = "https://api.darksky.net/forecast/"
        let coords = "45.5329436,-73.5742773"
        let url = urlBegin + DARK_SKY + coords
        print(url)
        
        // Do any additional setup after loading the view from its nib.
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    func updateTodayModel() {
        var test = "five"
        print(test)
        let urlBegin = "https://api.darksky.net/forecast/"
        let coords = "45.5329436,-73.5742773"
        let url = urlBegin + DARK_SKY + coords
        print(url)
        
        Alamofire.request(url, method: .get, parameters: nil).responseJSON {
            [unowned self] response in
            if response.result.isSuccess {
                let weatherJSON = JSON(response.result.value!)
                print("SUCCESS")
                print(weatherJSON)
                print(" ")
            } else {
                print(response.result.error?.localizedDescription)
                
                
                print("ERROR")
            }
        }
    }
    
    func widgetPerformUpdate(completionHandler: (@escaping (NCUpdateResult) -> Void)) {
        // Perform any setup necessary in order to update the view.
        
        // If an error is encountered, use NCUpdateResult.Failed
        // If there's no update required, use NCUpdateResult.NoData
        // If there's an update, use NCUpdateResult.NewData
        
        completionHandler(NCUpdateResult.newData)
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
            print("SUCCESS AT RETRIEVING LOCATION!!!!")
            let latitude = String(location.coordinate.latitude)
            let longitude = String(location.coordinate.longitude)
            let params = ["lat": latitude, "lon": longitude, "appid": APP_ID]
//            getWeatherData(url: weatherDataModel.weatherURL, parameters: params)
        }
    }
    
    func locationManager(_ manager: CLLocationManager, didFailWithError error: Error) {
        let ac = UIAlertController(title: "Failed to retrieve location", message: "Your location is unkown", preferredStyle: .alert)
        ac.addAction(UIAlertAction(title: "Ok", style: .default))
        present(ac, animated: true)
//        cityLabel.text = "Location unavailable"
    }
    
}
