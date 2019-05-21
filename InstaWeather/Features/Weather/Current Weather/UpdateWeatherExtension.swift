//
//  UpdateWeatherExtension.swift
//  Rain Check
//
//  Created by Besher on 2018-01-27.
//  Copyright © 2018 Besher Al Maleh. All rights reserved.
//

import Foundation
import Alamofire
import SwiftyJSON
import CoreLocation

extension WeatherViewController: WeatherDataFetcherDelegate {
    
    func getWeatherForCoordinates(latitude: String, longitude: String, location: CLLocation, city: String = "") {
        
        weatherDataFetcher.getWeatherData(latitude: latitude, longitude: longitude, location: location, city: city)
        
        // TODO move to separate object
        DispatchQueue.main.asyncAfter(deadline: .now() + 1) { [weak self] in
            self?.generateDemoSnapshots()
        }
        
        // TODO move to separate object
        // display ad
        DispatchQueue.main.asyncAfter(deadline: .now() + 3) { [weak self] in
            self?.launchAds()
            self?.requestReviewAfterLaunchCount()
        }
    }
    
    func didReceiveWeatherData(data: (city: String, currentWeather: JSON, forecastWeather: JSON)) {
        
        
        let scale = segmentedControl.selectedSegmentIndex
        self.weatherDataModel = WeatherDataModel(city: data.city, scale: scale,
                                                 currentWeather: data.currentWeather,
                                                 forecastWeather: data.forecastWeather)
        
        updateWeatherLabels(with: self.weatherDataModel)
        
        weatherDataFetcher.loadAllPages()
    }
    
    func updateLabel(_ label: UILabel, toValue value: Int, forType type: LabelType, instant: Bool = false) {
        LabelAnimator(label: label, endValue: value, labelType: type, instant: instant)
    }
    
    func updateWeatherLabels(with model: WeatherDataModel, instant: Bool = false) {
        conditionImage.image = ImageManager.loadImage(named: model.weatherIconName)
        updateBackgroundWithForecastImage()
        cityLabel.text = model.city
        let scale = model.tempScale == .celsius ? "km/h" : "mph"
        let windSpeed = model.windSpeed
        let windDirection = model.windDirection
        windLabel.text = "\(windDirection) \(windSpeed) \(scale)"
        lastUpdateWasUpdated()
        
        updateLabel(tempLabel, toValue: model.temperature, forType: .mainTemperature, instant: instant)
        updateLabel(humidityLabel, toValue: model.humidity, forType: .humidity, instant: instant)
        updateLabel(minTempLabel, toValue: weatherDataModel.minTemp, forType: .minTemp, instant: instant)
        updateLabel(maxTempLabel, toValue: weatherDataModel.maxTemp, forType: .maxTemp, instant: instant)
        
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.9) { [weak self] in
            _ = self?.captureSnapshotForMemories
        }
    }
    
    func updateWeatherLabelsInstantly() {
    
        self.weatherDataModel = DataModelPersistor.loadDataModel()
        updateWeatherLabels(with: self.weatherDataModel, instant: true)
        if let date = weatherDataModel.lastUpdated {
            updateLastLabel(withDate: date)
        }
    }
    
    func loadLastLocation() {
        // load weather for last user location, otherwise get current location
        if let city = UserDefaults.standard.string(forKey: "cityChosen") {
            locationManager.performMapSearch(for: city)
        } else {
            locationManager.startUpdatingLocation()
        }
    }
    
    func updateBackgroundWithForecastImage() {
        backgroundImage.image = weatherDataModel.getBackground()
        updateBlurAndBrightness()
    }
    
    func updateBlurAndBrightness() {
        imageMenu.hostType = hostType
        imageMenu.refreshData()
    }
}
