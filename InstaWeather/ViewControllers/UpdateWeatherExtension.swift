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

extension WeatherViewController {
    
    func getWeatherForCoordinates(latitude: String, longitude: String, location: CLLocation, city: String = "") {
        let params = ["lat": latitude, "lon": longitude, "appid": APP_ID]
        getWeatherData(parameters: params, location: location)
        if city == "" {
            updateCityFromLocation(location: location)
        } else {
            weatherDataModel.city = city
        }
    }
    
    func getWeatherData(parameters: [String: String], location: CLLocation, reconnecting: Bool = false) {
        weatherDataModel = WeatherDataModel()
        weatherDataModel.toggleScale(to: segmentedControl.selectedSegmentIndex)
        let lat = String(location.coordinate.latitude)
        let lon = String(location.coordinate.longitude)
        let loc: String = "(" + lat + "," + lon + ")"
        
        Alamofire.request(getYahooURL(forLocation: loc), method: .get, parameters: nil).responseJSON {
            [unowned self] response in
            if response.result.isSuccess {
                self.deactivateTimer()
                let json = JSON(response.result.value!)
                self.updateYahooData(with:json)
                
                self.cityIsValid(parameters: parameters)
                
            } else if !reconnecting {
                
                let ac = UIAlertController(title: "Error", message: response.result.error?.localizedDescription, preferredStyle: .alert)
                ac.addAction(UIAlertAction(title: "Dismiss", style: .default))
                self.present(ac, animated: true)
                self.deactivateTimer()
                self.reconnectTimer = Timer.scheduledTimer(withTimeInterval: 5, repeats: true, block: { [unowned self] (timer) in
                    self.getWeatherData(parameters: parameters, location: location, reconnecting: true)
                })
                self.reconnectTimer?.tolerance = 0.5
                if let timer = self.reconnectTimer {
                    RunLoop.current.add(timer, forMode: RunLoop.Mode.common)
                }
                
                
                
                print(response.result.error?.localizedDescription ?? "Error")
            }
        }
        
        
        
//        Alamofire.request(url, method: .get, parameters: parameters).responseJSON {
//            [unowned self] response in
//            if response.result.isSuccess {
//                self.deactivateTimer()
//                let weatherJSON = JSON(response.result.value!)
//                if self.updateWeatherData(json: weatherJSON) {
//                    self.cityIsValid(parameters: parameters)
//                }
//                else { self.cityIsNotValid(restore: oldModel) }
//            } else if !reconnecting {
//                let ac = UIAlertController(title: "Error", message: response.result.error?.localizedDescription, preferredStyle: .alert)
//                ac.addAction(UIAlertAction(title: "Dismiss", style: .default))
//                self.present(ac, animated: true)
//                self.deactivateTimer()
//                self.reconnectTimer = Timer.scheduledTimer(withTimeInterval: 5, repeats: true, block: { [unowned self] (timer) in
//                    self.getWeatherData(url: url, parameters: parameters, location: location, reconnecting: true)
//                })
//                self.reconnectTimer?.tolerance = 0.5
//                if let timer = self.reconnectTimer {
//                    RunLoop.current.add(timer, forMode: .commonModes)
//                }
//            }
//        }

    }
    
    func cityIsValid(parameters: [String: String]) {
        getWeatherForecast(url: weatherDataModel.forecastURL, parameters: parameters)
        if let city = parameters["q"] {
            UserDefaults.standard.set(city, forKey: "cityChosen")
        }
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
//                self.updateMinMaxTemp(json: weatherJSON)
                self.updateForecast(json: weatherJSON)
            } else {
                let ac = UIAlertController(title: "Error", message: response.result.error?.localizedDescription, preferredStyle: .alert)
                ac.addAction(UIAlertAction(title: "Dismiss", style: .default))
                self.present(ac, animated: true)
            }
        }
        
//        let lat = String(weatherDataModel.latitude)
//        let lon = String(weatherDataModel.longitude)
//
//        let location = "(" + lat + "," + lon + ")"
//
//        Alamofire.request(getYahooURL(forLocation: location), method: .get, parameters: nil).responseJSON {
//            [unowned self] response in
//            if response.result.isSuccess {
//                let json = JSON(response.result.value!)
//                self.updateYahooData(with:json)
//            } else {
//                print(response.result.error?.localizedDescription ?? "Error")
//            }
//        }
        
        
    }
    
    func updateWeatherData(json: JSON) -> Bool {
        if let tempResult = json["main"]["temp"].double {
            weatherDataModel.temperature = kelvinToCelsius(tempResult)
//            weatherDataModel.city = json["name"].stringValue
            weatherDataModel.condition = json["weather"][0]["id"].intValue
            weatherDataModel.currentTime = json["dt"].intValue
            weatherDataModel.sunriseTime = json["sys"]["sunrise"].intValue
            weatherDataModel.sunsetTime = json["sys"]["sunset"].intValue
            weatherDataModel.latitude = json["coord"]["lat"].doubleValue
            weatherDataModel.longitude = json["coord"]["lon"].doubleValue
//            weatherDataModel.weatherIconName = weatherDataModel.updateOpenWeatherIcon(condition: weatherDataModel.condition, objectTime: weatherDataModel.currentTime, objectSunrise: weatherDataModel.sunriseTime, objectSunset: weatherDataModel.sunsetTime)
//            updateUIWithWeatherData()
            return true
        } else {
            let ac = UIAlertController(title: "Invalid city", message: "You have entered an invalid city name", preferredStyle: .alert)
            ac.addAction(UIAlertAction(title: "Ok", style: .default))
            present(ac, animated: true)
            return false
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
        updateUIWithWeatherData()
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
        
        if !self.preloadedForecastTable { self.preloadForecastTable?() }
        self.preloadedForecastTable = true
        
        saveValues(forYahoo: false)
    }
    
    

    
    func updateUIWithWeatherData() {
        updateLabel(tempLabel, toValue: weatherDataModel.temperature, forType: .mainTemperature)
        updateLabel(minTempLabel, toValue: weatherDataModel.minTemp, forType: .minTemp)
        updateLabel(maxTempLabel, toValue: weatherDataModel.maxTemp, forType: .maxTemp)
        conditionImage.image = UIImage(named: weatherDataModel.weatherIconName)
        backgroundImage.image = UIImage(named: weatherDataModel.backgroundName)
        cityLabel.text = weatherDataModel.city
        lastUpdateWasUpdated()
    }
    
    func updateYahooData(with json: JSON) {
        
        // TODO: temp, min, max, condition,
        
        weatherDataModel.temperature = json["query"]["results"]["channel"]["item"]["condition"]["temp"].intValue
        
        weatherDataModel.minTemp = json["query"]["results"]["channel"]["item"]["forecast"][0]["low"].intValue
        weatherDataModel.maxTemp = json["query"]["results"]["channel"]["item"]["forecast"][0]["high"].intValue
        
        let condition = json["query"]["results"]["channel"]["item"]["condition"]["code"].intValue
        weatherDataModel.weatherIconName = weatherDataModel.updateYahooWeatherIcon(condition: condition)
        
        weatherDataModel.feelsLike = json["query"]["results"]["channel"]["wind"]["chill"].intValue
        weatherDataModel.windSpeed = json["query"]["results"]["channel"]["wind"]["speed"].intValue
        weatherDataModel.windDirection = json["query"]["results"]["channel"]["wind"]["direction"].stringValue
        weatherDataModel.humidity = json["query"]["results"]["channel"]["atmosphere"]["humidity"].intValue
        saveValues(forYahoo: true)
        
        
        updateUIWithWeatherData()
        self.updateYahooLabels()
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
        let animationObject = CoreAnimationObject(label: label, endValue: value, labelType: type)
        animationObject.start()
    }
    
    func updateLabelsNoAnimation() {
        loadValues()
        let scale = segmentedControl.selectedSegmentIndex == 0 ? "km/h" : "mph"
        let windSpeed = weatherDataModel.windSpeed
        let windDirection = weatherDataModel.windDirection
        windLabel.text = "\(windDirection) \(windSpeed) \(scale)"
        conditionImage.image = UIImage(named: weatherDataModel.weatherIconName)
        backgroundImage.image = UIImage(named: weatherDataModel.backgroundName)
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
            defaults.set(weatherDataModel.backgroundName, forKey: "backgroundName")
            defaults.set(weatherDataModel.temperatureFahrenheit, forKey: "temperature")
            defaults.set(weatherDataModel.minTempFahrenheit, forKey: "minTemp")
            defaults.set(weatherDataModel.maxTempFahrenheit, forKey: "maxTemp")
            defaults.set(weatherDataModel.city, forKey: "city")
            defaults.set(weatherDataModel.lastUpdated, forKey: "lastUpdated")
        } else {
            defaults.set(weatherDataModel.feelsLikeFahrenheit, forKey: "feelsLike")
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
        weatherDataModel.backgroundName = defaults.string(forKey: "backgroundName") ?? "bglight_rain"
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
        if let loadObject = UserDefaults.standard.string(forKey: "cityChosen") {
            performMapSearch(for: loadObject)
        } else {
            locationManager.startUpdatingLocation()
        }
    }
    
    func celsiusToKelvin(_ temp: Int) -> Double {
        return Double(temp) + 273.15
    }
    
    func kelvinToCelsius(_ temp: Double) -> Int {
        return Int(temp - 273.15)
    }
}
