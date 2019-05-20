//
//  LocationManager.swift
//  InstaWeather
//
//  Created by Besher on 2019-05-19.
//  Copyright © 2019 Besher Al Maleh. All rights reserved.
//

import Foundation
import CoreLocation
import MapKit

class LocationManager: NSObject, CLLocationManagerDelegate {
    
    private weak var delegate: LocationManagerDelegate?
    private let locationManager: CLLocationManager
    
    init(withDelegate delegate: LocationManagerDelegate) {
        self.locationManager = CLLocationManager()
        self.delegate = delegate
        super.init()
        locationManager.desiredAccuracy = kCLLocationAccuracyHundredMeters
        locationManager.requestWhenInUseAuthorization()
    }
    
    func startUpdatingLocation() {
        locationManager.delegate = self
        locationManager.startUpdatingLocation()
        print("Started updating location")
    }
    
    func stopUpdatingLocation() {
        locationManager.delegate = nil
        locationManager.stopUpdatingLocation()
        print("Stopped updating location")
    }
    
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        let location = locations[locations.count - 1]
        print("Updated location. New location is: \(location)")
        if location.horizontalAccuracy > 0 {
            stopUpdatingLocation()
            let latitude = String(location.coordinate.latitude)
            let longitude = String(location.coordinate.longitude)
            delegate?.didReceiveUpdatedLocation(latitude: latitude, longitude: longitude, location: location, withCity: false)
        }
    }
    
    func locationManager(_ manager: CLLocationManager, didFailWithError error: Error) {
        let ac = UIAlertController(title: "Failed to retrieve location", message: "Your location is unkown", preferredStyle: .alert)
        ac.addAction(UIAlertAction(title: "Ok", style: .default))
        delegate?.showAlert(controller: ac)
        delegate?.updateLabel(to: "Location unavailable")
    }
    
    func updateCityFromLocation(location: CLLocation, completion: @escaping ((String) -> Void)){
        CLGeocoder().reverseGeocodeLocation(location, completionHandler:
            {
                (placemarks, error) in
                guard let pm = placemarks, let possibleCity = pm.first, let city = possibleCity.locality else {
                    completion("")
                    return }
                if let error = error {
                    print("Reverse geocode failed: \(error.localizedDescription)")
                }
                completion(city)
        })
    }

    func performMapSearch(for city: String) {
        let request = MKLocalSearch.Request()
        request.naturalLanguageQuery = city
        let search = MKLocalSearch(request: request)
        search.start { [weak self] (response, error) in
            guard let response = response else { return }
            if let coordinates = response.mapItems.first?.placemark.coordinate {
                let latitude = coordinates.latitude
                let longitude = coordinates.longitude
                self?.delegate?.didReceiveUpdatedLocation(latitude: String(latitude), longitude: String(longitude), location: CLLocation(latitude: latitude, longitude: longitude), withCity: true)
            }
        }
    }
}
