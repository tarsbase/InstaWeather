//
//  coreAnimationObject.swift
//  InstaWeather
//
//  Created by Besher on 2018-06-25.
//  Copyright © 2018 Besher Al Maleh. All rights reserved.
//

import UIKit

enum LabelType {
    case mainTemperature
    case feelsLike
    case minTemp
    case maxTemp
    case humidity
}

class LabelAnimator: NSObject {
    
    let label: UILabel
    var startValue: Int = 0
    let endValue: Int
    let animationDuration: Double = 0.8
    let animationStartDate: Date
    var displayLink: CADisplayLink?
    let labelType: LabelType
    
    init(label: UILabel, endValue: Int, labelType: LabelType) {
        self.label = label
        self.endValue = endValue
        self.animationStartDate = Date()
        self.labelType = labelType
        super.init()
        if let start = label.text {
            self.startValue = getOldValue(from: start)
        }
    }
    
    func start() {
        displayLink = CADisplayLink(target: self, selector: #selector(handleUpdate))
        displayLink?.add(to: .main, forMode: RunLoop.Mode.default)
    }
    
    @objc private func handleUpdate() {
        let now = Date()
        let elapsedTime = now.timeIntervalSince(animationStartDate)
        
        if elapsedTime > animationDuration {
            DispatchQueue.main.asyncAfter(deadline: .now() + animationDuration / 12) {
                [weak self] in
                self?.label.text = self?.getLabelText(forValue: String(self?.endValue ?? 0 ))
                self?.displayLink?.invalidate()
                self?.displayLink = nil
            }
        } else {
            var percentage = elapsedTime / animationDuration
            percentage = 1 - percentage
            percentage = 1 - (percentage * percentage)
            let value = startValue + Int(percentage * Double((endValue - startValue)))
            if (value != endValue) {
                label.text = getLabelText(forValue: String(value))
            }
        }
    }
    
    func getOldValue(from start: String) -> Int {
        let filtered = start.compactMap { Int(String($0)) }
        let joined = filtered.reduce(0) { $0 * 10 + $1 }
        return joined
    }
    
    func getLabelText(forValue value: String) -> String {
        switch labelType {
        case .mainTemperature: return "\(value)°"
        case .minTemp: return "↓\(value)"
        case .maxTemp: return "↑\(value)"
        case .feelsLike: return "Feels like \(value)°"
        case .humidity: return "Humidity: \(value)%"
        }
    }
    

}
