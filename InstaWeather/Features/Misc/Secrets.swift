//
//  Secrets.swift
//  Rain Check
//
//  Created by Besher on 2018-01-27.
//  Copyright © 2018 Besher Al Maleh. All rights reserved.
//


var APP_ID: String {
    return _APP_ID
}

let _APP_ID = "01550baf61bfab061aa9f179bf797c73"

let DARK_SKY = "f015459cb4b41a61bd92bd4e63c94ab6/"

func getYahooURL(forLocation location: String) -> String {
    return "https://query.yahooapis.com/v1/public/yql?q=select%20*%20from%20weather.forecast%20where%20woeid%20in%20(select%20woeid%20from%20geo.places(1)%20where%20text%3D%22" + location + "%22)&format=json&env=store%3A%2F%2Fdatatables.org%2Falltableswithkeys"
}

