//
//  ForecastViewController.swift
//  InstaWeather
//
//  Created by Besher on 2018-01-29.
//  Copyright © 2018 Besher Al Maleh. All rights reserved.
//

import UIKit

class ForecastViewController: UIViewController {
    @IBOutlet weak var stackBottomConstraint: NSLayoutConstraint!
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
        for stack in subStacks {
                stack.isHidden = true
        }
        stackBottomConstraint.constant = 500
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        if let parent = self.parent as? PageViewController {
            for case let weatherVC as WeatherViewController in parent.orderedViewControllers {
                model = weatherVC.weatherDataModel
            }
        }
        parseForecast()
    }
    
    override func viewDidAppear(_ animated: Bool) {
        var tag = 0
        func animateStack() {
            guard tag < 5 else { return }
            for stack in subStacks {
                if stack.tag == tag {
                    tag += 1
                    UIView.animate(withDuration: 0.3, delay: 0, options: .curveEaseOut, animations: {
                        [weak self] in
                        stack.isHidden = false
                        if ((self?.stackBottomConstraint.constant)! - 100) > 24 { self?.stackBottomConstraint.constant -= 100 } else {
                            self?.stackBottomConstraint.constant = 24
                        }
                        self?.view.layoutIfNeeded()
                        }, completion: {
                            boolean in
                            animateStack()
                    })
                    break
                }
            }
        }
        animateStack()
        
        super.viewDidAppear(animated)
    }
    
    func parseForecast() {
        var tag = 0
        guard let weekdayObjects = model?.weekdayObjects, var currentModel = model else { return }
        for (index, dayObject) in weekdayObjects.enumerated() {
            parseDay(dayObject, tag: tag, model: &currentModel, index: index)
            tag += 1
        }
    }

    func parseDay(_ object: ForecastObject, tag: Int, model: inout WeatherDataModel, index: Int) {
        let dayObject = object
        var dayOfWeek = ""
        switch dayObject.dayOfWeek {
        case 1: dayOfWeek = "SUN"
        case 2: dayOfWeek = "MON"
        case 3: dayOfWeek = "TUE"
        case 4: dayOfWeek = "WED"
        case 5: dayOfWeek = "THU"
        case 6: dayOfWeek = "FRI"
        default: dayOfWeek = "SAT"
        }
        var temp = ""
        
        let minTemp = model.minTempForObject(index)
        let maxTemp = model.maxTempForObject(index)
        
        
        if minTemp == 99 {
            temp = "N/A"
        } else {
            temp = "↓ \(minTemp) ↑ \(maxTemp)"
        }
        populateStack(tag: tag, day: dayOfWeek, icon: dayObject.condition, temperature: temp)
    }
    
    func populateStack(tag: Int, day: String, icon: Int, temperature: String) {
        
        for stack in subStacks {
            if stack.tag == tag {
                for case let imageView as UIImageView in stack.arrangedSubviews {
                    let iconName = model?.updateWeatherIcon(condition: icon, objectTime: 0) ?? ""
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
