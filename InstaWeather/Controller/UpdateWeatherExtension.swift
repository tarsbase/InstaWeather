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
        
        Alamofire.request(url, method: .get, parameters: parameters).responseJSON {
            [unowned self] response in
            if response.result.isSuccess {
                let weatherJSON = JSON(response.result.value!)
                self.updateWeatherData(json: weatherJSON)
            } else {
                let ac = UIAlertController(title: "Error", message: response.result.error?.localizedDescription, preferredStyle: .alert)
                ac.addAction(UIAlertAction(title: "Dismiss", style: .default))
                self.present(ac, animated: true)
                self.cityLabel.text = "Connection issues"
            }
        }
        weatherDataModel = WeatherDataModel()
        getWeatherForecast(url: weatherDataModel.WEATHERFC_URL, parameters: parameters)
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
    
    func updateWeatherData(json: JSON) {
        if let tempResult = json["main"]["temp"].double {
            weatherDataModel.temperature = kelvinToCelsius(tempResult)
            weatherDataModel.city = json["name"].stringValue
            weatherDataModel.condition = json["weather"][0]["id"].intValue
            weatherDataModel.weatherIconName = weatherDataModel.updateWeatherIcon(condition: weatherDataModel.condition)
            updateUIWithWeatherData()
        } else {
            let ac = UIAlertController(title: "Invalid city", message: "You have entered an invalid city name", preferredStyle: .alert)
            ac.addAction(UIAlertAction(title: "Ok", style: .default))
            present(ac, animated: true)
        }
    }
    
    func updateForecast(json: JSON) {
        
        for (_, value) in json["list"] {
            let date = value["dt_txt"].stringValue
            let condition = value["weather"][0]["id"].intValue
            let max = kelvinToCelsius(value["main"]["temp_max"].double ?? 0)
            let min = kelvinToCelsius(value["main"]["temp_min"].double ?? 0)
            let forecastObject = ForecastObject(date: date, condition: condition, maxTemp: max, minTemp: min)
            weatherDataModel.forecast.append(forecastObject)
        }
        weatherDataModel.filterDays()
        
    }
    
    func updateMinMaxTemp(json: JSON) {
        var minTemp = celsiusToKelvin(weatherDataModel.temperature)
        var maxTemp = celsiusToKelvin(weatherDataModel.temperature)
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
        var temp = weatherDataModel.temperature
        var minTemp = weatherDataModel.minTemp
        var maxTemp = weatherDataModel.maxTemp
        if segmentedControl.selectedSegmentIndex == 1 {
            temp = celsiusToFahrenheit(temp)
            minTemp = celsiusToFahrenheit(minTemp)
            maxTemp = celsiusToFahrenheit(maxTemp)
        }
        tempLabel.text = "\(temp)°"
        minTempLabel.text = "↓\(minTemp)"
        maxTempLabel.text = "↑\(maxTemp)"
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
    
    func celsiusToFahrenheit(_ temp: Int) -> Int {
        return Int((Double(temp) * 1.8) + 32)
    }
    
}
