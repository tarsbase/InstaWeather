//
//  ViewController.swift
//  Rain Check
//
//  Created by Besher on 2018-01-27.
//  Copyright © 2018 Besher Al Maleh. All rights reserved.
//

import UIKit
import CoreLocation
import Alamofire
import SwiftyJSON

class WeatherViewController: UIViewController, ChangeCityDelegate {
    @IBOutlet weak var tempLabel: UILabel!
    @IBOutlet weak var cityLabel: UILabel!
    @IBOutlet weak var conditionImage: UIImageView!
    
    let WEATHER_URL = "http://api.openweathermap.org/data/2.5/weather"
    let locationManager = CLLocationManager()
    var weatherDataModel = WeatherDataModel()
    
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
    }
    
    func updateWeatherData(json: JSON) {
        if let tempResult = json["main"]["temp"].double {
            
            weatherDataModel.temperature = Int(tempResult - 273.15)
            weatherDataModel.city = json["name"].stringValue
            weatherDataModel.condition = json["weather"][0]["id"].intValue
            weatherDataModel.weatherIconName = weatherDataModel.updateWeatherIcon(condition: weatherDataModel.condition)
            updateUIWithWeatherData()
        } else {
            cityLabel.text = "Weather unavailable"
            let ac = UIAlertController(title: "Weather unavailable", message: "Cannot retrieve weather data", preferredStyle: .alert)
            ac.addAction(UIAlertAction(title: "Ok", style: .default))
            present(ac, animated: true)
        }
    }
    
    func updateUIWithWeatherData() {
        cityLabel.text = weatherDataModel.city
        tempLabel.text = "\(weatherDataModel.temperature)°"
        conditionImage.image = UIImage(named: weatherDataModel.weatherIconName)
    }
    
    func userEnteredNewCity(city: String) {
        let params: [String: String] = ["q": city, "appid": APP_ID]
        getWeatherData(url: WEATHER_URL, parameters: params)
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "changeCity" {
            if let destination = segue.destination as? ChangeCityViewController {
                destination.delegate = self
            }
        }
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        
    }
    
}

