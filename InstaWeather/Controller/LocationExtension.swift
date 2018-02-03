//
//  LocationExtension.swift
//  Rain Check
//
//  Created by Besher on 2018-01-27.
//  Copyright © 2018 Besher Al Maleh. All rights reserved.
//

import UIKit
import CoreLocation

extension WeatherViewController: CLLocationManagerDelegate {
    
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        let location = locations[locations.count - 1]
        if location.horizontalAccuracy > 0 {
            locationManager.stopUpdatingLocation()
            locationManager.delegate = nil // prevents multiple refreshes
            let latitude = String(location.coordinate.latitude)
            let longitude = String(location.coordinate.longitude)
            let params = ["lat": latitude, "lon": longitude, "appid": APP_ID]
            getWeatherData(url: weatherDataModel.WEATHER_URL, parameters: params)
        }
    }
    
    
    func locationManager(_ manager: CLLocationManager, didFailWithError error: Error) {
        let ac = UIAlertController(title: "Failed to retrieve location", message: "Your location is unkown", preferredStyle: .alert)
        ac.addAction(UIAlertAction(title: "Ok", style: .default))
        present(ac, animated: true)
        cityLabel.text = "Location unavailable"
    }
    
    
    
}
