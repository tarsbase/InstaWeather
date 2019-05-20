//
//  WeatherUpdater.swift
//  InstaWeather
//
//  Created by Besher on 2019-05-19.
//  Copyright © 2019 Besher Al Maleh. All rights reserved.
//

import Foundation
import Alamofire
import SwiftyJSON
import CoreLocation

protocol WeatherDataFetcherDelegate: AnyObject {
    func didReceiveWeatherData(data: (city: String, currentWeather: JSON, forecastWeather: JSON))
}

class WeatherDataFetcher {
    
    private var loadAllWeatherPages: (() -> Void)?
    private var pagesAreLoaded = false
    
    var reconnectTimer: Timer?
    weak var locationManager: LocationManager?
    weak var alertPresenter: AlertPresenter?
    weak var delegate: WeatherDataFetcherDelegate?
    
    init(manager: LocationManager, alertPresenter: AlertPresenter, delegate: WeatherDataFetcherDelegate) {
        if let delegate = UIApplication.shared.delegate as? AppDelegate {
            delegate.weatherUpdater = self
        }
        self.locationManager = manager
        self.alertPresenter = alertPresenter
        self.delegate = delegate
    }
    
    func setup(loadPages: (() -> Void)?) {
        self.loadAllWeatherPages = loadPages
    }
    
    func loadAllPages() {
        if pagesAreLoaded == false {
            pagesAreLoaded = true
            loadAllWeatherPages?()
        }
    }
    
    func deactivateTimer() {
        reconnectTimer?.invalidate()
        reconnectTimer = nil
        print("Sunsetting the timer")
    }
    
}


// Get weather data
extension WeatherDataFetcher {
    
    func getWeatherData(latitude: String, longitude: String, location: CLLocation, city: String = "", reconnecting: Bool = false) {
        
        let params = ["lat": latitude, "lon": longitude, "appid": APP_ID]
        
        let weatherURL = LiveInstance.weatherURL
        var weatherJSON = (city: city, currentWeather: JSON(), forecastWeather: JSON())
        let dispatchGroup = DispatchGroup()
        var requestFailure = false
        
        // get current weather
        dispatchGroup.enter()
        Alamofire.request(weatherURL, method: .get, parameters: params).responseJSON {
            [weak self] response in
            guard let self = self else { return }
            if response.result.isSuccess {
                self.deactivateTimer()
                let json = JSON(response.result.value!)
                weatherJSON.currentWeather = json
            } else if !reconnecting {
                requestFailure = true
                self.alertPresenter?.updateLabel(to: "Weather Unavailable")
                print(response.result.error?.localizedDescription ?? "Error")
                
                // try again in 5 seconds
                self.deactivateTimer()
                let timer = Timer.scheduledTimer(withTimeInterval: 5, repeats: true, block: { [weak self] (timer) in
                    self?.getWeatherData(latitude: latitude, longitude: longitude, location: location, city: city, reconnecting: true)
                })
                timer.tolerance = 0.5
                RunLoop.current.add(timer, forMode: RunLoop.Mode.common)
                self.reconnectTimer = timer
            }
            dispatchGroup.leave()
        }
        
        // get forecast weather
        dispatchGroup.enter()
        if let city = params["q"] {
            UserDefaults.standard.set(city, forKey: "cityChosen")
        }
        let forecastURL = LiveInstance.forecastURL
        Alamofire.request(forecastURL, method: .get, parameters: params).responseJSON {
            [weak self] response in
            guard let self = self else { return }
            if response.result.isSuccess {
                let forecast = JSON(response.result.value!)
                weatherJSON.forecastWeather = forecast
            } else {
                requestFailure = true
                self.alertPresenter?.updateLabel(to: "Weather Unavailable")
                print(response.result.error?.localizedDescription ?? "Error")
            }
            dispatchGroup.leave()
        }
        
        // get city
        dispatchGroup.enter()
        if weatherJSON.city == "" {
            locationManager?.updateCityFromLocation(location: location) { city in
                weatherJSON.city = city
                dispatchGroup.leave()
            }
        } else {
            dispatchGroup.leave()
        }
        
        dispatchGroup.notify(queue: DispatchQueue.main) { [weak self] in
            if requestFailure == false {
                self?.delegate?.didReceiveWeatherData(data: weatherJSON)
            }
        }
    }
}
