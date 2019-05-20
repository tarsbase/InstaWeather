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
        
        updateCurrentWeatherLabels(with: self.weatherDataModel)
        
        weatherDataFetcher.loadAllPages()
    }
    
    func updateCurrentWeatherLabels(with model: WeatherDataModel) {
        updateLabel(tempLabel, toValue: model.temperature, forType: .mainTemperature)
        conditionImage.image = ImageManager.loadImage(named: model.weatherIconName)
        updateBackgroundWithForecastImage()
        cityLabel.text = model.city
        let scale = segmentedControl.selectedSegmentIndex == 0 ? "km/h" : "mph"
        let windSpeed = model.windSpeed
        let windDirection = model.windDirection
        windLabel.text = "\(windDirection) \(windSpeed) \(scale)"
        updateLabel(humidityLabel, toValue: model.humidity, forType: .humidity)
        lastUpdateWasUpdated()
        
        
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.9) { [weak self] in
            _ = self?.captureSnapshotOnce
        }
    }
    
    func updateMinMaxLabels() {
        updateLabel(minTempLabel, toValue: weatherDataModel.minTemp, forType: .minTemp)
        updateLabel(maxTempLabel, toValue: weatherDataModel.maxTemp, forType: .maxTemp)
    }
    
    func updateYahooLabels() {
        let feelsLikeTemp = weatherDataModel.feelsLike
        let scale = segmentedControl.selectedSegmentIndex == 0 ? "km/h" : "mph"
        let windSpeed = weatherDataModel.windSpeed
        let windDirection = weatherDataModel.windDirection
        windLabel.text = "\(windDirection) \(windSpeed) \(scale)"
        updateLabel(feelsLikeLabel, toValue: feelsLikeTemp, forType: .feelsLike)
        updateLabel(humidityLabel, toValue: weatherDataModel.humidity, forType: .humidity)
    }
    
    func updateLabel(_ label: UILabel, toValue value: Int, forType type: LabelType) {
        let labelAnimator = LabelAnimator(label: label, endValue: value, labelType: type)
        labelAnimator.start()
    }
    
    func updateLabelsNoAnimation() {
    
        self.weatherDataModel = DataModelPersistor.loadDataModel()
        
        let scale = weatherDataModel.scaleIsCelsius == .celsius ? "km/h" : "mph"
        let windSpeed = weatherDataModel.windSpeed
        let windDirection = weatherDataModel.windDirection
        windLabel.text = "\(windDirection) \(windSpeed) \(scale)"
        conditionImage.image = ImageManager.loadImage(named: weatherDataModel.weatherIconName)
        updateBackgroundWithForecastImage()
        tempLabel.text = "\(weatherDataModel.temperature)°"
        minTempLabel.text = "↓\(weatherDataModel.minTemp)"
        maxTempLabel.text = "↑\(weatherDataModel.maxTemp)"
        feelsLikeLabel.text = "Feels like \(weatherDataModel.feelsLike)°"
        humidityLabel.text = "Humidity: \(weatherDataModel.humidity)%"
        cityLabel.text = weatherDataModel.city
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
