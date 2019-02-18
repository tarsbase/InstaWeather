//
//  MemoriesSnapshot.swift
//  InstaWeather
//
//  Created by Besher on 2019-02-16.
//  Copyright © 2019 Besher Al Maleh. All rights reserved.
//

import UIKit

class MemoriesSnapshot {
    
    var image: UIImage?
    let date: Date
    
    
    init(image: UIImage) {
        self.date = Date()
        self.image = image
    }
    
    init(image: UIImage, date: Date) {
        self.date = date
        self.image = image
    }
    
    static func addNewSnapshot(_ image: UIImage) {
        // we snap one memory per calendar day
        let lastDate = MemoriesCacheManager.getDateForLastMemory()
        let calendar = Calendar.current
        if let memoryNextDay = calendar.date(byAdding: .day, value: 1, to: lastDate) {
            let memoryNextDayStart = calendar.startOfDay(for: memoryNextDay)
            let currentTime = Date()
            if currentTime >= memoryNextDayStart {
                let newSnapshot = MemoriesSnapshot(image: image)
                MemoriesCacheManager.saveMemoryToCoreData(newSnapshot)
            } else {
                print("Too early to record another memory")
            }
        }
    }
}
