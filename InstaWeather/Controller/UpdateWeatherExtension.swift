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

extension WeatherViewController {
    
    func getWeatherData(url: String, parameters: [String: String]) {
        let oldModel = weatherDataModel
        weatherDataModel = WeatherDataModel()
        Alamofire.request(url, method: .get, parameters: parameters).responseJSON {
            [unowned self] response in
            if response.result.isSuccess {
                let weatherJSON = JSON(response.result.value!)
                if self.updateWeatherData(json: weatherJSON) { self.cityIsValid(parameters: parameters) }
                else { self.cityIsNotValid(restore: oldModel) }
            } else {
                let ac = UIAlertController(title: "Error", message: response.result.error?.localizedDescription, preferredStyle: .alert)
                ac.addAction(UIAlertAction(title: "Dismiss", style: .default))
                self.present(ac, animated: true)
                self.cityLabel.text = "Connection issues"
            }
        }
    }
    
    func cityIsValid(parameters: [String: String]) {
        weatherDataModel.toggleScale(to: segmentedControl.selectedSegmentIndex)
        getWeatherForecast(url: weatherDataModel.WEATHERFC_URL, parameters: parameters)
    }
    
    func cityIsNotValid(restore model: WeatherDataModel) {
        weatherDataModel = model
        recentPicksDataSource?.removeLastRecentPick()
    }
    
    func getWeatherForecast(url: String, parameters: [String: String]) {
        Alamofire.request(url, method: .get, parameters: parameters).responseJSON {
            [unowned self] response in
            if response.result.isSuccess {
                let weatherJSON = JSON(response.result.value!)
                self.updateMinMaxTemp(json: weatherJSON)
                self.updateForecast(json: weatherJSON)
            } else {
                let ac = UIAlertController(title: "Error", message: response.result.error?.localizedDescription, preferredStyle: .alert)
                ac.addAction(UIAlertAction(title: "Dismiss", style: .default))
                self.present(ac, animated: true)
                self.cityLabel.text = "Connection issues"
            }
        }
    }
    
    func updateWeatherData(json: JSON) -> Bool {
        if let tempResult = json["main"]["temp"].double {
            weatherDataModel.temperature = kelvinToCelsius(tempResult)
            weatherDataModel.city = json["name"].stringValue
            weatherDataModel.condition = json["weather"][0]["id"].intValue
            weatherDataModel.currentTime = json["dt"].intValue
            weatherDataModel.sunriseTime = json["sys"]["sunrise"].intValue
            weatherDataModel.sunsetTime = json["sys"]["sunset"].intValue
            weatherDataModel.weatherIconName = weatherDataModel.updateWeatherIcon(condition: weatherDataModel.condition, objectTime: weatherDataModel.currentTime, objectSunrise: weatherDataModel.sunriseTime, objectSunset: weatherDataModel.sunsetTime)
//            updateUIWithWeatherData()
            return true
        } else {
            let ac = UIAlertController(title: "Invalid city", message: "You have entered an invalid city name", preferredStyle: .alert)
            ac.addAction(UIAlertAction(title: "Ok", style: .default))
            present(ac, animated: true)
            return false
        }
    }
    
    func updateForecast(json: JSON) {
        var scaleIsCelsius = true
        if segmentedControl.selectedSegmentIndex == 1 { scaleIsCelsius = false }
        for (_, value) in json["list"] {
            let date = value["dt_txt"].stringValue
            let condition = value["weather"][0]["id"].intValue
            let max = kelvinToCelsius(value["main"]["temp_max"].double ?? 0)
            let min = kelvinToCelsius(value["main"]["temp_min"].double ?? 0)
            let formatter = DateFormatter()
            formatter.dateFormat = "yyyy-MM-dd"
            let forecastObject = ForecastObject(date: date, condition: condition, maxTemp: max, minTemp: min, scaleIsCelsius: scaleIsCelsius, formatter: formatter)

            weatherDataModel.forecast.append(forecastObject)
        }
        weatherDataModel.filterDays()
//        print(weatherDataModel.forecastSections.count)
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
        updateUIWithWeatherData()
    }
    
    func updateUIWithWeatherData() {
        cityLabel.text = weatherDataModel.city
        tempLabel.text = "\(weatherDataModel.temperature)°"
        minTempLabel.text = "↓\(weatherDataModel.minTemp)"
        maxTempLabel.text = "↑\(weatherDataModel.maxTemp)"
        conditionImage.image = UIImage(named: weatherDataModel.weatherIconName)
        backgroundImage.image = UIImage(named: weatherDataModel.backgroundName)
    }
    
    func userEnteredNewCity(city: String) {
        let params: [String: String] = ["q": city, "appid": APP_ID]
        getWeatherData(url: weatherDataModel.WEATHER_URL, parameters: params)
        if let parent = self.parent as? PageViewController {
            if let forecastVC = parent.orderedViewControllers.last as? ForecastViewController {
                forecastVC.parseForecast()
            }
        }
    }
    
    func celsiusToKelvin(_ temp: Int) -> Double {
        return Double(temp) + 273.15
    }
    
    func kelvinToCelsius(_ temp: Double) -> Int {
        return Int(temp - 273.15)
    }
}
