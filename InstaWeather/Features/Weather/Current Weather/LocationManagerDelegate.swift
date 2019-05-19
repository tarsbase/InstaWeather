//
//  LocationManagerDelegate.swift
//  InstaWeather
//
//  Created by Besher on 2019-05-19.
//  Copyright © 2019 Besher Al Maleh. All rights reserved.
//

import UIKit
import CoreLocation


protocol LocationManagerDelegate: AnyObject {
    func showAlert(controller: UIAlertController)
    func updateLabel(to string: String)
    func didReceiveUpdatedLocation(latitude: String, longitude: String, location: CLLocation, withCity: Bool)
    func didReverseGeocode(to city: String)
}

extension LocationManagerDelegate where Self: UIViewController {
    func showAlert(controller: UIAlertController) {
        present(controller, animated: true)
    }
}
