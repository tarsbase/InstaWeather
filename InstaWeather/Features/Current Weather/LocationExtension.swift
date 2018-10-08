//
//  LocationExtension.swift
//  Rain Check
//
//  Created by Besher on 2018-01-27.
//  Copyright © 2018 Besher Al Maleh. All rights reserved.
//

import UIKit
import CoreLocation
import MapKit

extension WeatherViewController: CLLocationManagerDelegate {
    
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        let location = locations[locations.count - 1]
        if location.horizontalAccuracy > 0 {
            locationManager.stopUpdatingLocation()
            locationManager.delegate = nil // prevents multiple refreshes
            let latitude = String(location.coordinate.latitude)
            let longitude = String(location.coordinate.longitude)
            getWeatherForCoordinates(latitude: latitude, longitude: longitude, location: location)
            DispatchQueue.main.asyncAfter(deadline: .now() + 3) { [weak self] in
                if self?.presentedViewController == nil {
                    self?.launchAds()
                }
            }
        }
    }
    
    func locationManager(_ manager: CLLocationManager, didFailWithError error: Error) {
        let ac = UIAlertController(title: "Failed to retrieve location", message: "Your location is unkown", preferredStyle: .alert)
        ac.addAction(UIAlertAction(title: "Ok", style: .default))
        present(ac, animated: true)
        cityLabel.text = "Location unavailable"
    }
    
    func updateCityFromLocation(location: CLLocation){
        CLGeocoder().reverseGeocodeLocation(location, completionHandler:
            {
                [unowned self] (placemarks, error) in
                if let error = error {
                    print("Reverse geocode failed: \(error.localizedDescription)")
                }
                guard let pm = placemarks, let possibleCity = pm.first, let city = possibleCity.locality else { return }
                self.weatherDataModel.city = city
                self.cityLabel.text = self.weatherDataModel.city
        })
    }
    
    func performMapSearch(for result: String) {
        let request = MKLocalSearch.Request()
        request.naturalLanguageQuery = result
        let search = MKLocalSearch(request: request)
        search.start { [unowned self](response, error) in
            guard let response = response else { return }
            if let coordinates = response.mapItems.first?.placemark.coordinate {
                let latitude = coordinates.latitude
                let longitude = coordinates.longitude
                self.getWeatherForCoordinates(latitude: String(latitude), longitude: String(longitude), location: CLLocation(latitude: latitude, longitude: longitude), city: self.weatherDataModel.city)
            }
        }
    }
    
}
