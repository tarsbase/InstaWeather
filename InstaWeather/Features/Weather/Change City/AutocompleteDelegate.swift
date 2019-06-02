//
//  AutocompleteDelegate.swift
//  InstaWeather
//
//  Created by Besher on 2019-06-02.
//  Copyright © 2019 Besher Al Maleh. All rights reserved.
//

import UIKit
import CoreLocation
import MapKit
import SVProgressHUD

protocol AutocompleteDelegate: RecentPicksDelegate {
    var recentPicks: [String] { get set }
    var cityField: UITextField! { get set }
    var weatherDelegate: WeatherRequestor? { get }
    func toggleAutoComplete(visible: Bool)
}

extension AutocompleteDelegate where Self: UIViewController {
    func filterCityAndCheckWeather(for result: String) {
        UserDefaults.standard.set(result, forKey: "cityChosen")
        let indexOfComma = result.index(of: ",")
        var city = result
        
        if let index = indexOfComma {
            city = String(result[result.startIndex..<index])
        }
        
        let request = MKLocalSearch.Request()
        request.naturalLanguageQuery = result
        let search = MKLocalSearch(request: request)
        
        search.start { [weak self] (response, error) in
            guard let self = self, let response = response, result.count > 1 else {
                return }
            if let coordinates = response.mapItems.first?.placemark.coordinate {
                let location = CLLocation(latitude: coordinates.latitude, longitude: coordinates.longitude)
                let latitude = String(coordinates.latitude)
                let longitude = String(coordinates.longitude)
                SVProgressHUD.show()
                self.weatherDelegate?.getWeatherForCoordinates(latitude: latitude, longitude: longitude, location: location, city: city)
                
                let name = result.lowercased().capitalized
                if self.recentPicks.contains(name) == false {
                    self.recentPicks.insert(name, at: 0)
                } else {
                    if let index = self.recentPicks.index(of: name) {
                        self.recentPicks.insert(self.recentPicks.remove(at: index), at: 0)
                    }
                }
                self.dismiss(animated: true)
            }
        }
    }
}
