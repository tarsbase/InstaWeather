//
//  ForecastViewController.swift
//  InstaWeather
//
//  Created by Besher on 2018-01-29.
//  Copyright © 2018 Besher Al Maleh. All rights reserved.
//

import UIKit

class ForecastViewController: ParallaxViewController {
    @IBOutlet weak var stackBottomConstraint: NSLayoutConstraint!
    @IBOutlet weak var mainStack: UIStackView!
    @IBOutlet weak var backgroundContainer: UIView!
    @IBOutlet weak var backgroundImage: UIImageView!
    @IBOutlet weak var changeImageButton: CustomImageButton!
    
    var subStacks = [UIStackView]()
    var model: WeatherDataModel?
    var preloading = true // ensures no animation during preloading
    
    lazy var backgroundBlur: UIVisualEffectView = setupBackgroundBlur()
    lazy var backgroundBrightness: UIView = setupBackgroundBrightness()
    lazy var blurAnimator: UIViewPropertyAnimator = setupBlurAnimator()
    lazy var imageMenu: ImageMenu = createImageMenuFor(host: .weeklyForecast(.clear))
    var imageMenuIsVisible = false {
        didSet { toggleImageMenu(visible: imageMenuIsVisible) }
    }
    weak var statusBarUpdater: StatusBarUpdater?
    
    override var preferredStatusBarStyle: UIStatusBarStyle {
        return .lightContent
    }
    
    override func viewWillTransition(to size: CGSize, with coordinator: UIViewControllerTransitionCoordinator) {
        super.viewWillTransition(to: size, with: coordinator)
        recreateMenus()
    }
    
    override var parallaxImage: UIImageView? {
        get { return backgroundImage } set { }
    }
    
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
        
        loadBackgroundImage()
        ImageMenu.imageMenusArray.append(imageMenu)
        backgroundContainer.clipsToBounds = true
        CustomImageButton.buttonsArray.insert(changeImageButton)
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        if let parent = self.parent as? PageViewController {
            for case let weatherVC as WeatherViewController in parent.orderedViewControllers {
                model = weatherVC.weatherDataModel
            }
        }
        parseForecast()
        
        if stackBottomConstraint.constant != 500 {
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
                var counter = 0
                func animateRow() {
                    guard counter < self.subStacks.count else { return }
                    for (index, cell) in self.subStacks.enumerated() {
                        if counter == index {
                            counter += 1
                            UIView.animate(withDuration: 0.17, delay: 0, options: .curveEaseInOut, animations: {
                                cell.transform = CGAffineTransform(translationX: -12, y: 0)
                            }, completion: {
                                boolean in
                                UIView.animate(withDuration: 0.17) {
                                    cell.transform = CGAffineTransform.identity
                                }
                            })
                            DispatchQueue.main.asyncAfter(deadline: .now() + 0.06) {
                                animateRow()
                            }
                            break
                        }
                    }
                }
                animateRow()
            }
        }
    }
    
    override func viewDidAppear(_ animated: Bool) {
        
        if !preloading {
            var tag = 0
            func animateStack() {
                guard tag < 5 else { return }
                for stack in subStacks {
                    if stack.tag == tag {
                        tag += 1
                        UIView.animate(withDuration: 0.25, delay: 0, options: .curveEaseOut, animations: {
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
        }
        super.viewDidAppear(animated)
        recreateMenusIfNotVisible()
    }
    
    override func viewDidDisappear(_ animated: Bool) {
        preloading = false
        super.viewDidDisappear(animated)
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
            temp = "↑ \(maxTemp) ↓ \(minTemp)"
        }
        populateStack(tag: tag, day: dayOfWeek, icon: dayObject.condition, temperature: temp)
    }
    
    func populateStack(tag: Int, day: String, icon: Int, temperature: String) {
        
        for stack in subStacks {
            if stack.tag == tag {
                for case let imageView as UIImageView in stack.arrangedSubviews {
                    let iconName = model?.updateOpenWeatherIcon(condition: icon, objectTime: 0) ?? ""
                    imageView.image = ImageManager.loadImage(named: iconName)
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

// MARK: - Image manager
extension ForecastViewController: ImageMenuDelegate {
    
    func loadBackgroundImage() {
        if AppSettings.weeklyForecastBackgrounds.allWeather.customBackground {
            loadCustomImage()
        } else {
            resetBackgroundImage()
        }
    }
    
    func resetBackgroundImage() {
        backgroundImage.image = ImageManager.loadImage(named: "bgselect1")
    }
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        handleTouch(by: touches)
    }
    
    @IBAction func changeImage(_ sender: Any) {
        self.imageMenuIsVisible = true
    }
    
    func pickedNewTextColor(_ color: UIColor) {
        
    }
    
    func toggleShadows(on: Bool) {
        
    }
}
