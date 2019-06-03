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
        guard isDemoMode == false else { return }
        weatherDataFetcher.getWeatherData(latitude: latitude, longitude: longitude, location: location, city: city)
    }
    
    func didReceiveWeatherData(data: (city: String, currentWeather: JSON, forecastWeather: JSON)) {
        
        let scale = segmentedControl.selectedSegmentIndex
        self.weatherDataModel = WeatherDataModel(city: data.city, scale: scale,
                                                 currentWeather: data.currentWeather,
                                                 forecastWeather: data.forecastWeather)
        
        updateWeatherLabels(with: self.weatherDataModel, dataType: .live)
        dataWasRefreshed()
    }
    
    func dataWasRefreshed() {
        weatherDataFetcher.loadAllPages()
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.9) { [weak self] in
            MemoriesSnapshot.addNewSnapshot(self?.getExportImage())
            // we generate demo if not enough snapshots have been captured yet
            self?.generateDemoSnapshots()
            self?.launchAdsAfter(delay: 2)
            self?.requestReviewIfReadyAfter(delay: 2)
        }
    }
    
    func updateLabel(_ label: UILabel, toValue value: Int, forLabelType labelType: LabelType, dataType: WeatherDataType) {
        LabelAnimator(label: label, endValue: value, labelType: labelType, dataType: dataType)
    }
    
    func updateWeatherLabels(with model: WeatherDataModel, dataType: WeatherDataType) {
        conditionImage.image = ImageManager.loadImage(named: model.weatherIconName)
        updateBackgroundWithForecastImage(with: model)
        cityLabel.text = model.city
        let scale = model.temperatureScale == .celsius ? "km/h" : "mph"
        let windSpeed = model.windSpeed
        let windDirection = model.windDirection
        windLabel.text = "\(windDirection) \(windSpeed) \(scale)"
        
        updateLabel(tempLabel, toValue: model.temperature, forLabelType: .mainTemperature, dataType: dataType)
        updateLabel(humidityLabel, toValue: model.humidity, forLabelType: .humidity, dataType: dataType)
        updateLabel(minTempLabel, toValue: model.minTemp, forLabelType: .minTemp, dataType: dataType)
        updateLabel(maxTempLabel, toValue: model.maxTemp, forLabelType: .maxTemp, dataType: dataType)
        
        // we only refresh last updated label for live data
        if (dataType == .live) {
            self.weatherDataModel = lastUpdated.update(model: model)
        }
    }
    
    func updateWeatherLabelsInstantly(with model: WeatherDataModel = DataPersistor.loadDataModel()) {
        self.weatherDataModel = model
        updateWeatherLabels(with: model, dataType: .fromDisk)
        if let date = model.lastUpdated {
            lastUpdated.updateLabel(withDate: date)
        }
    }
    
    func loadLastLocation() {
        // load weather for last user location, otherwise get current location
        if let city = UserDefaults.standard.string(forKey: "cityChosen") {
            locationManager.performMapSearch(for: city)
        } else {
            updateCurrentLocation()
        }
    }
    
    func updateCurrentLocation() {
        guard isDemoMode == false else { return }
        locationManager.startUpdatingLocation()
    }
    
    func updateBackgroundWithForecastImage(with model: WeatherDataModel) {
        backgroundImage.image = model.getBackground()
        updateBlurAndBrightness()
    }
    
    func updateBlurAndBrightness() {
        imageMenu.hostType = hostType
        imageMenu.refreshData()
    }
}
