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
    var weatherDataModel = WeatherDataModel()
    
    override func viewWillAppear(_ animated: Bool) {
        assignDelegate()
        locationManager.desiredAccuracy = kCLLocationAccuracyHundredMeters
        locationManager.requestWhenInUseAuthorization()
        updateData()
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()

        conditionImage.image = conditionImage.image?.withRenderingMode(.alwaysTemplate)
        conditionImage.tintColor = .darkGray
        
        
        
        // Do any additional setup after loading the view from its nib.
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
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
    
}
