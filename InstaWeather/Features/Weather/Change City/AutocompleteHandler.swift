//
//  AutocompleteHandler.swift
//  InstaWeather
//
//  Created by Besher on 2019-05-28.
//  Copyright © 2019 Besher Al Maleh. All rights reserved.
//

import Foundation
import SVProgressHUD
import MapKit

class AutocompleteHandler: NSObject {
    
    static func checkWeather(for result: String, delegate: ChangeCityDelegate?, picks: [String], dismiss: @escaping ([String]?) -> Void) {
        var recentPicks = picks
        SVProgressHUD.show()
        UserDefaults.standard.set(result, forKey: "cityChosen")
        let indexOfComma = result.index(of: ",")
        var city = result
        
        if let index = indexOfComma {
            city = String(result[result.startIndex..<index])
        }
        
        let request = MKLocalSearch.Request()
        request.naturalLanguageQuery = result
        let search = MKLocalSearch(request: request)
        search.start { (response, error) in
            guard let response = response, result.count > 1 else {
                dismiss(nil)
                return }
            if let coordinates = response.mapItems.first?.placemark.coordinate {
                let latitude = coordinates.latitude
                let longitude = coordinates.longitude
                delegate?.getWeatherForCoordinates(latitude: String(latitude), longitude: String(longitude), location: CLLocation(latitude: latitude, longitude: longitude), city: city)
                let name = result.lowercased().capitalized
                if !recentPicks.contains(name) {
                    recentPicks.insert(name, at: 0)
                } else {
                    if let index = recentPicks.index(of: name) {
                        recentPicks.insert(recentPicks.remove(at: index), at: 0)
                    }
                }
                dismiss(recentPicks)
            }
        }
    }
}
