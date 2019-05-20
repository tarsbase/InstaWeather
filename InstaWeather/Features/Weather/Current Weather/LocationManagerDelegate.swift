//
//  LocationManagerDelegate.swift
//  InstaWeather
//
//  Created by Besher on 2019-05-19.
//  Copyright © 2019 Besher Al Maleh. All rights reserved.
//

import UIKit
import CoreLocation

protocol AlertPresenter: AnyObject {
    func showAlert(controller: UIAlertController)
}

extension AlertPresenter where Self: UIViewController {
    func showAlert(controller: UIAlertController) {
        present(controller, animated: true)
    }
}

protocol LocationManagerDelegate: AlertPresenter {
    func updateLabel(to string: String)
    func didReceiveUpdatedLocation(latitude: String, longitude: String, location: CLLocation, withCity: Bool)
    func didReverseGeocode(to city: String)
}
