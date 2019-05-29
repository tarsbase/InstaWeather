//
//  MemoriesDemoGenerator.swift
//  InstaWeather
//
//  Created by Besher on 2019-05-21.
//  Copyright © 2019 Besher Al Maleh. All rights reserved.
//

import UIKit

enum DemoGenerator {
    /// Generates demo cards for Memories screen if not enough memories had been created
    static func generateDemoSnapshots(demoImages: [MemoriesSnapshot],
                                      backgroundImage: UIImageView,
                                      mainView: UIView,
                                      hideViews: @escaping () -> Void,
                                      unhideViews: @escaping () -> Void,
                                      completion: @escaping ([MemoriesSnapshot]) -> Void) {
        guard demoImages.isEmpty else { return }
        guard MemoriesCacheManager.loadAllMemories().count < 3 else { return }
        
        let concurrentQueue = DispatchQueue(label: "demos-queue", qos: .userInteractive, attributes: .concurrent, autoreleaseFrequency: .workItem, target: nil)
        
        concurrentQueue.async {
            var demosArray = [MemoriesSnapshot]()
            let totalDuration: TimeInterval = 0.07
            let numberOfDemos = ImageManager.potentialBackgrounds.count
            let interval = totalDuration / Double(numberOfDemos)
            
            let semaphore = DispatchSemaphore(value: 0)
            
            for (index, background) in ImageManager.potentialBackgrounds.dropFirst(6).enumerated() {
                concurrentQueue.asyncAfter(deadline: .now() + (Double(index) * interval)) {
                    
                    DispatchQueue.main.async {
                        let originalBackground = backgroundImage.image
                        backgroundImage.image = background
                        let demoLabel = self.generateDemoLabel(mainView: mainView)
                        if let demoSnap = self.getDemoImage(mainView: mainView,
                                                            hideViews: hideViews,
                                                            unhideViews: unhideViews) {
                            
                            let date = Calendar.current.date(byAdding: .day, value: -2, to: Date()) ?? Date()
                            let demo = MemoriesSnapshot(image: demoSnap, date: date)
                            demosArray.append(demo)
                        }
                        
                        demoLabel.removeFromSuperview()
                        backgroundImage.image = originalBackground
                        semaphore.signal()
                    }
                }
                _ = semaphore.wait(timeout: .distantFuture)
            }
            completion(demosArray)
        }
    }
    
    private static func getDemoImage(mainView: UIView, hideViews: () -> Void, unhideViews: () -> Void) -> UIImage? {
        hideViews()
        let image = mainView.imageRepresentation()
        unhideViews()
        return image
    }
    
    private static func generateDemoLabel(mainView: UIView) -> UILabel {
        let label = UILabel()
        label.textColor = .white
        label.text = "DEMO CARD"
        label.font = UIFont.systemFont(ofSize: 33, weight: .bold)
        label.sizeToFit()
        mainView.addSubview(label)
        label.center.x = mainView.center.x
        label.center.y = mainView.center.y - (mainView.bounds.height / 3)
        return label
    }
}
