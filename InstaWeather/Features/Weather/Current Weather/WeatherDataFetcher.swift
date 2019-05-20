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
    func didReceiveCurrentWeatherData(data: JSON)
    func didReceiveForecastWeatherData(data: JSON)
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
        
        Alamofire.request(weatherURL, method: .get, parameters: params).responseJSON {
            [weak self] response in
            guard let self = self else { return }
            if response.result.isSuccess {
                self.deactivateTimer()
                let json = JSON(response.result.value!)
                self.delegate?.didReceiveCurrentWeatherData(data: json)
                self.saveCityAndGetForecast(parameters: params)
            } else if !reconnecting {
                
                let ac = UIAlertController(title: "Error", message: response.result.error?.localizedDescription, preferredStyle: .alert)
                ac.addAction(UIAlertAction(title: "Dismiss", style: .default))
                self.alertPresenter?.showAlert(controller: ac)
                print(response.result.error?.localizedDescription ?? "Error")
                
                self.deactivateTimer()
                // try again in 5 seconds
                let timer = Timer.scheduledTimer(withTimeInterval: 5, repeats: true, block: { [weak self] (timer) in
                    self?.getWeatherData(latitude: latitude, longitude: longitude, location: location, city: city, reconnecting: true)
                })
                timer.tolerance = 0.5
                RunLoop.current.add(timer, forMode: RunLoop.Mode.common)
                self.reconnectTimer = timer
            }
        }
    }

    func saveCityAndGetForecast(parameters: [String: String]) {
        getWeatherForecast(parameters: parameters)
        if let city = parameters["q"] {
            UserDefaults.standard.set(city, forKey: "cityChosen")
        }
    }

    func getWeatherForecast(parameters: [String: String]) {
        let forecastURL = LiveInstance.forecastURL
        Alamofire.request(forecastURL, method: .get, parameters: parameters).responseJSON {
            [weak self] response in
            if response.result.isSuccess {
                let weatherJSON = JSON(response.result.value!)
                self?.delegate?.didReceiveForecastWeatherData(data: weatherJSON)
            } else {
                let ac = UIAlertController(title: "Error", message: response.result.error?.localizedDescription, preferredStyle: .alert)
                ac.addAction(UIAlertAction(title: "Dismiss", style: .default))
                self?.alertPresenter?.showAlert(controller: ac)
            }
        }
    }
}
