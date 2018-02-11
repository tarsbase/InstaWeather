//
//  Rain_CheckTests.swift
//  Rain CheckTests
//
//  Created by Besher on 2018-01-27.
//  Copyright © 2018 Besher Al Maleh. All rights reserved.
//

import XCTest
@testable import InstaWeather

class InstaWeatherTests: XCTestCase {
    
    override func setUp() {
        super.setUp()
    }
    
    override func tearDown() {
        super.tearDown()
    }
    
    func testGetFahrenheit() {
        var model = WeatherDataModel()
        model.toggleScale(to: 1)
        XCTAssertEqual(model.temperature, 32, "Scale is not fahrenheit")
    }
    
    func testGetCelsius() {
        var model = WeatherDataModel()
        model.toggleScale(to: 0)
        XCTAssertEqual(model.temperature, 0, "Scale is not Celsius")
    }
    
    func testPerformanceEmptyModel() {
        measure {
            _ = WeatherDataModel()
        }
    }
    
    func testPerformanceForecastObject() {
        measure {
            for i in 1...40 {
                let formatter = DateFormatter()
                formatter.dateFormat = "yyyy-MM-dd"
                _ = ForecastObject(date: "2018-02-12 00:00:00", condition: 500, maxTemp: i + 6, minTemp: i, scaleIsCelsius: true, formatter: formatter)
            }
        }
    }
    
    
}
