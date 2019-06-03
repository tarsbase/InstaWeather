//
//  MemoriesDemoGenerator.swift
//  InstaWeather
//
//  Created by Besher on 2019-05-21.
//  Copyright © 2019 Besher Al Maleh. All rights reserved.
//

import UIKit

enum SnapshotGenerator {
    
    /// Generates demo cards for Memories screen if not enough memories had been created
    static func generateDemoSnapshots(by main: UIViewController,
                                      with model: WeatherDataModel,
                                      completion: @escaping ([MemoriesSnapshot]) -> Void) {
    
        guard MemoriesCacheManager.loadAllMemories().count < 3 else { return }
        
        // prepare mock viewcontroller for demos
        let viewcontroller = generateMockViewcontroller(by: main, with: model)
        
        generateDemoGallery(for: viewcontroller) { snapshots in
            DispatchQueue.main.async {
                completion(snapshots)
                viewcontroller.remove()
            }
        }
    }
    
    /// Adds an additional Memories card
    static func generateMemorySnapshot(by main: UIViewController, with model: WeatherDataModel) -> UIImage? {
        let viewcontroller = generateMockViewcontroller(by: main, with: model)
        viewcontroller.hideViews(viewcontroller.viewsExcludedFromScreenshot)
        let image = viewcontroller.view.imageRepresentation()
        viewcontroller.remove()
        return image
    }
    
    private static func generateMockViewcontroller(by main: UIViewController, with model: WeatherDataModel) -> WeatherViewController {
        let storyboard = UIStoryboard(name: "Main", bundle: Bundle.main)
        guard let viewcontroller = storyboard.instantiateViewController(withIdentifier: "second")
            as? WeatherViewController else { fatalError("Cannot generate mock weatherViewController") }
        
        viewcontroller.isDemoMode = true
        main.add(viewcontroller, parent: main.view, hidden: true)
        viewcontroller.updateWeatherLabelsInstantly(with: model)
        viewcontroller.updateBackgroundWithForecastImage(with: model)
        return viewcontroller
    }
    
    private static func generateDemoGallery(for vc: WeatherViewController, completion: @escaping ([MemoriesSnapshot]) -> Void) {
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
                        let originalBackground = vc.backgroundImage.image
                        vc.backgroundImage.image = background
                        let demoLabel = self.generateDemoLabel(mainView: vc.view)
                        if let demoSnap = self.getDemoImage(mainView: vc.view,
                                                            hideViews: { vc.hideViews(vc.viewsExcludedFromScreenshot) },
                                                            unhideViews: { vc.unHideViews(vc.viewsExcludedFromScreenshot) }) {
                            
                            let date = Calendar.current.date(byAdding: .day, value: -2, to: Date()) ?? Date()
                            let demo = MemoriesSnapshot(image: demoSnap, date: date)
                            demosArray.append(demo)
                        }
                        
                        demoLabel.removeFromSuperview()
                        vc.backgroundImage.image = originalBackground
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
