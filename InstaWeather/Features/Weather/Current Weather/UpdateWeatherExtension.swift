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
        
        weatherDataModel = WeatherDataModel(scale: segmentedControl.selectedSegmentIndex)
        weatherDataFetcher.getWeatherData(latitude: latitude, longitude: longitude, location: location, city: city)
        
        if city == "" {
            locationManager.updateCityFromLocation(location: location)
        } else {
            weatherDataModel.city = city
        }
        
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
    
    func didReceiveCurrentWeatherData(data: JSON) {
        self.updateWeatherData(json: data)
    }
    
    func didReceiveForecastWeatherData(data: JSON) {
        self.updateMinMaxTemp(json: data)
        self.updateForecast(json: data)
    }
    
    // move this to model
    func updateWeatherData(json: JSON) {
        if let tempResult = json["main"]["temp"].double {
            weatherDataModel.temperature = kelvinToCelsius(tempResult)
            weatherDataModel.condition = json["weather"][0]["id"].intValue
            weatherDataModel.currentTime = json["dt"].intValue
            weatherDataModel.sunriseTime = json["sys"]["sunrise"].intValue
            weatherDataModel.sunsetTime = json["sys"]["sunset"].intValue
            let humidity = json["main"]["humidity"].intValue
            weatherDataModel.humidity = humidity
            let meterPerSecond = json["wind"]["speed"].doubleValue
            let kphSpeed = Int(meterPerSecond * 3.6)
            weatherDataModel.windSpeedKph = kphSpeed
            let windDirection = json["wind"]["deg"].doubleValue
            weatherDataModel.windDirectionInDegrees = windDirection
            
            
            weatherDataModel.weatherIconName = weatherDataModel.updateOpenWeatherIcon(condition: weatherDataModel.condition, objectTime: weatherDataModel.currentTime, objectSunrise: weatherDataModel.sunriseTime, objectSunset: weatherDataModel.sunsetTime)
            updateCurrentWeatherLabels()
        } else {
            let ac = UIAlertController(title: "Invalid city", message: "You have entered an invalid city name", preferredStyle: .alert)
            ac.addAction(UIAlertAction(title: "Ok", style: .default))
            present(ac, animated: true)
        }
    }
    
    func updateMinMaxTemp(json: JSON) {
        var minTemp = celsiusToKelvin(weatherDataModel.temperatureCelsius)
        var maxTemp = celsiusToKelvin(weatherDataModel.temperatureCelsius)
        for i in 0...7 {
            minTemp = min(minTemp, json["list"][i]["main"]["temp"].double ?? 0)
            maxTemp = max(maxTemp, json["list"][i]["main"]["temp"].double ?? 0)
        }
        weatherDataModel.minTemp = kelvinToCelsius(minTemp)
        weatherDataModel.maxTemp = kelvinToCelsius(maxTemp)
        updateMinMaxLabels()
    }
    
    func updateForecast(json: JSON) {
        for (_, value) in json["list"] {
            let date = value["dt_txt"].stringValue
            let condition = value["weather"][0]["id"].intValue
            let max = kelvinToCelsius(value["main"]["temp_max"].double ?? 0)
            let min = kelvinToCelsius(value["main"]["temp_min"].double ?? 0)
            let formatter = DateFormatter()
            formatter.dateFormat = "yyyy-MM-dd"
            print("Min is \(min) and max is \(max)")
            let forecastObject = ForecastObject(date: date, condition: condition, maxTemp: max, minTemp: min, formatter: formatter)

            weatherDataModel.forecast.append(forecastObject)
        }
        weatherDataModel.filterDays()
        
        weatherDataFetcher.loadAllPages()
        
        saveValues(forYahoo: false)
    }
    
    

    
    func updateCurrentWeatherLabels() {
        updateLabel(tempLabel, toValue: weatherDataModel.temperature, forType: .mainTemperature)
        conditionImage.image = ImageManager.loadImage(named: weatherDataModel.weatherIconName)
        updateBackgroundWithForecastImage()
        cityLabel.text = weatherDataModel.city
        let scale = segmentedControl.selectedSegmentIndex == 0 ? "km/h" : "mph"
        let windSpeed = weatherDataModel.windSpeed
        let windDirection = weatherDataModel.windDirection
        windLabel.text = "\(windDirection) \(windSpeed) \(scale)"
        updateLabel(humidityLabel, toValue: weatherDataModel.humidity, forType: .humidity)
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
        loadValues()
        let scale = segmentedControl.selectedSegmentIndex == 0 ? "km/h" : "mph"
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
    
    func saveValues(forYahoo: Bool) {
        let defaults = UserDefaults.standard
        if !forYahoo {
            defaults.set(weatherDataModel.weatherIconName, forKey: "conditionImage")
            defaults.set(weatherDataModel.defaultBackgroundName, forKey: "backgroundName")
            defaults.set(weatherDataModel.temperatureCelsius, forKey: "temperature")
            defaults.set(weatherDataModel.minTempCelsius, forKey: "minTemp")
            defaults.set(weatherDataModel.maxTempCelsius, forKey: "maxTemp")
            defaults.set(weatherDataModel.city, forKey: "city")
            weatherDataModel.lastUpdated = Date()
            defaults.set(weatherDataModel.lastUpdated, forKey: "lastUpdated")
        } else {
            defaults.set(weatherDataModel.feelsLikeCelsius, forKey: "feelsLike")
            defaults.set(weatherDataModel.humidity, forKey: "humidity")
            defaults.set(weatherDataModel.windSpeed, forKey: "windSpeed")
            defaults.set(weatherDataModel.windDirectionInDegrees, forKey: "windDirection")
        }
    }
    
    func loadValues() {
        let defaults = UserDefaults.standard
        weatherDataModel.windSpeed = defaults.integer(forKey: "windSpeed")
        weatherDataModel.windDirectionInDegrees = defaults.double(forKey: "windDirection")
        weatherDataModel.weatherIconName = defaults.string(forKey: "conditionImage") ?? "light_rain"
        weatherDataModel.defaultBackgroundName = defaults.string(forKey: "backgroundName") ?? "bglight_rain"
        weatherDataModel.temperature = defaults.integer(forKey: "temperature")
        weatherDataModel.minTemp = defaults.integer(forKey: "minTemp")
        weatherDataModel.maxTemp = defaults.integer(forKey: "maxTemp")
        weatherDataModel.feelsLike = defaults.integer(forKey: "feelsLike")
        weatherDataModel.humidity = defaults.integer(forKey: "humidity")
        weatherDataModel.city = defaults.string(forKey: "city") ?? "Montreal"
        if let date = defaults.object(forKey: "lastUpdated") as? Date {
            weatherDataModel.lastUpdated = date
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
        backgroundImage.image = weatherDataModel.getBackground(host: .mainScreen(.all))
        updateBlurAndBrightness()
    }
    
    func updateBlurAndBrightness() {
        imageMenu.hostType = hostType
        imageMenu.refreshData()
    }
    
    func celsiusToKelvin(_ temp: Int) -> Double {
        return Double(temp) + 273.15
    }
    
    func kelvinToCelsius(_ temp: Double) -> Int {
        return Int(temp - 273.15)
    }
}
