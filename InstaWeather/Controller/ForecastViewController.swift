//
//  ForecastViewController.swift
//  InstaWeather
//
//  Created by Besher on 2018-01-29.
//  Copyright © 2018 Besher Al Maleh. All rights reserved.
//

import UIKit

class ForecastViewController: UIViewController {
    override var preferredStatusBarStyle: UIStatusBarStyle {
        return .lightContent
    }
    @IBOutlet weak var mainStack: UIStackView!
    var subStacks = [UIStackView]()
    var model: WeatherDataModel?
    
    override func viewDidLoad() {
       super.viewDidLoad()
        for case let stack as UIStackView in mainStack.arrangedSubviews {
            subStacks.append(stack)
        }
        for stack in subStacks {
            for view in stack.arrangedSubviews where view.tag == 1 {
                addShadow(view)
            }
        }
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        if let parent = self.parent as? PageViewController {
            if let weatherVC = parent.orderedViewControllers.first as? WeatherViewController {
                model = weatherVC.weatherDataModel
            }
        }
        parseForecast()
    }
    
    func parseForecast() {
        parseDay(model?.tomorrowObject, model?.twoDaysObject, model?.threeDaysObject, model?.fourDaysObject, model?.fiveDaysObject)
    }

    func parseDay(_ dayObjects: ForecastObject?...) {
        var tag = 0
        for dayObject in dayObjects {
            guard let day = dayObject?.dayOfWeek, let icon = dayObject?.condition, let minTemp = dayObject?.minTemp, let maxTemp = dayObject?.maxTemp else { return }
            var dayOfWeek = ""
            switch day {
            case 1: dayOfWeek = "SUN"
            case 2: dayOfWeek = "MON"
            case 3: dayOfWeek = "TUE"
            case 4: dayOfWeek = "WED"
            case 5: dayOfWeek = "THU"
            case 6: dayOfWeek = "FRI"
            default: dayOfWeek = "SAT"
            }
            var temp = ""
            if minTemp == 99 {
                temp = "N/A"
            } else {
                temp = "↓ \(minTemp) ↑ \(maxTemp)"
            }
            populateStack(tag: tag, day: dayOfWeek, icon: icon, temperature: temp)
            tag += 1
        }
    }
    
    func populateStack(tag: Int, day: String, icon: Int, temperature: String) {
        
        for stack in subStacks {
            if stack.tag == tag {
                for case let imageView as UIImageView in stack.arrangedSubviews {
                    let iconName = model?.updateWeatherIcon(condition: icon) ?? ""
                    imageView.image = UIImage(named: iconName)
                }
                for case let label as UILabel in stack.arrangedSubviews {
                    if label.tag == 0 {
                        label.text = day
                    } else {
                        label.text = temperature
                    }
                }
            }
        }
    }
    
    func addShadow(_ views: UIView...) {
        for view in views {
            view.layer.shadowColor = UIColor.black.cgColor
            view.layer.shadowOffset = CGSize(width: 0, height: 2)
            view.layer.shadowOpacity = 0.5
            view.layer.shadowRadius = 1.0
        }
    }

}
