//
//  Rain_CheckUITests.swift
//  Rain CheckUITests
//
//  Created by Besher on 2018-01-27.
//  Copyright © 2018 Besher Al Maleh. All rights reserved.
//

import XCTest

class InstaWeatherUITests: XCTestCase {
        
    override func setUp() {
        super.setUp()
        
        // Put setup code here. This method is called before the invocation of each test method in the class.
        
        // In UI tests it is usually best to stop immediately when a failure occurs.
        continueAfterFailure = false
        // UI tests must launch the application that they test. Doing this in setup will make sure it happens for each test method.
        XCUIApplication().launch()

        // In UI tests it’s important to set the initial state - such as interface orientation - required for your tests before they run. The setUp method is a good place to do this.
    }
    
    override func tearDown() {
        // Put teardown code here. This method is called after the invocation of each test method in the class.
        super.tearDown()
    }
    
    func testInitialState() {
        let element = XCUIApplication().otherElements.containing(.pageIndicator, identifier:"page 2 of 3").children(matching: .other).element.children(matching: .other).element.children(matching: .other).element
        element.swipeRight()
        let table = XCUIApplication().tables
        XCTAssertTrue(table.otherElements.cells.count >= 5, "There should be at least 5 sections, for five days of forecast")
    }
    
    func testForecastTableCells() {
        let element = XCUIApplication().otherElements.containing(.pageIndicator, identifier:"page 2 of 3").children(matching: .other).element.children(matching: .other).element.children(matching: .other).element
        element.swipeRight()
        let table = XCUIApplication().tables
        XCTAssertTrue(table.cells.count >= 38, "There should be at least 38 cells")
    }
    
}
