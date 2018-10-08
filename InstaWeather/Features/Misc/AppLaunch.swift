//
//  AppLaunch.swift
//  InstaWeather
//
//  Created by Besher on 2018-10-02.
//  Copyright © 2018 Besher Al Maleh. All rights reserved.
//

import Foundation

struct AppLaunch: Codable {
    let date: Date
    
    init() {
        self.date = Date()
    }
    
    static func decodeFrom(_ data: Data) -> AppLaunch? {
        let decoder = JSONDecoder()
        var decoded: AppLaunch? = nil
        do {
            decoded = try decoder.decode(AppLaunch.self, from: data)
        } catch let error {
            print(error.localizedDescription)
        }
        return decoded
    }
    
    static func encodeFrom(_ userStats: AppLaunch) -> Data {
        let encoder = JSONEncoder()
        var encoded = Data()
        do {
            encoded = try encoder.encode(userStats)
        } catch let error {
            print(error.localizedDescription)
        }
        return encoded
    }
}
