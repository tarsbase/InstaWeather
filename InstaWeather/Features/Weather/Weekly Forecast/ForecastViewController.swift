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
    @IBOutlet weak var exportButton: CustomImageButton!
    
    var socialExport: SocialExport?
    var preloading = true // ensures no animation during preloading
    
    lazy var backgroundBlur: UIVisualEffectView = setupBackgroundBlur()
    lazy var backgroundBrightness: UIView = setupBackgroundBrightness()
    lazy var blurAnimator: UIViewPropertyAnimator = setupBlurAnimator()
    lazy var imageMenu: ImageMenu = createImageMenuFor(host: .weeklyForecast(.all))
    
    var stackWasAnimated: Bool {
        return stackBottomConstraint.constant != 500
    }
    
    var subStacks: [UIStackView] {
        return mainStack.arrangedSubviews.compactMap { $0 as? UIStackView }
    }
    
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
        initialSetup()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        parseForecast()
        performWavyAnimation()
    }
    
    override func viewDidAppear(_ animated: Bool) {
        animateStackView()
        super.viewDidAppear(animated)
        recreateMenusIfNotVisible()
    }
    
    override func viewDidDisappear(_ animated: Bool) {
        preloading = false
        super.viewDidDisappear(animated)
    }
    
    func initialSetup() {
        addAllShadows()
        subStacks.forEach { $0.isHidden = true }
        stackBottomConstraint.constant = 500
        loadBackgroundImage()
        backgroundContainer.clipsToBounds = true
    }
    
    func parseForecast() {
        let weeklyForecast = weatherDataModel.getWeeklyForecast()
        for forecast in weeklyForecast {
            populateStack(tag: forecast.tag, day: forecast.day, icon: forecast.icon, temperature: forecast.temperature)
        }
    }
    
    func populateStack(tag: Int, day: String, icon: Int, temperature: String) {
        for stack in subStacks {
            if stack.tag == tag {
                for case let imageView as UIImageView in stack.arrangedSubviews {
                    let iconName = weatherDataModel.updateOpenWeatherIcon(condition: icon, objectTime: 0)
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
}

// MARK: - Animations
extension ForecastViewController {
    
    func performWavyAnimation() {
        guard stackWasAnimated else { return }
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) { [weak self] in
            guard let self = self else { return }
            let interval = 0.055
            let translation = CGPoint(x: -12, y: 0)
            let duration = 0.17
            
            for (index, stack) in self.subStacks.enumerated() {
                let delay = interval * Double(index)
                DispatchQueue.main.asyncAfter(deadline: .now() + delay) {
                    stack.animate(.translate(by: translation, duration: duration),
                                  .reset(duration: duration))
                }
            }
        }
    }
    
    func animateStackView() {
        guard preloading == false else { return }
        let interval = 0.25
        let duration = 0.25
        for (index, stack) in subStacks.enumerated() {
            let delay = interval * Double(index)
            DispatchQueue.main.asyncAfter(deadline: .now() + delay) { [weak self] in
                guard let self = self else { return }
                stack.animate(.animate(handler: {
                    stack.isHidden = false
                    self.stackBottomConstraint.constant = self.stackBottomConstraint.constant > 124 ?
                        self.stackBottomConstraint.constant - 100 : 24
                    self.view.layoutIfNeeded()
                }, duration: duration)
                )
            }
        }
    }
}

// MARK: - Image manager
extension ForecastViewController: ImageMenuDelegate {
    
    var viewsToColor: [UIView] {
        return [changeImageButton, mainStack]
    }
    
    func loadBackgroundImage() {
        let hostType: PickerHostType = .weeklyForecast(.all)
        if let savedBackground = ImageManager.getBackgroundImage(for: hostType) {
            if ImageManager.customBackgroundFor(host: hostType) {
                backgroundImage.image = savedBackground
                return
            }
        }
        resetBackgroundImage()
    }
    
    func resetBackgroundImage() {
        backgroundImage.image = ImageManager.loadImage(named: "bgselect1")
    }
    
    @IBAction func changeImage(_ sender: Any) {
        imageMenu.isVisible = true
    }
    
    func pickedNewTextColor(_ color: UIColor) {
        for case let subStack as UIStackView in mainStack.arrangedSubviews {
            let subviews = subStack.arrangedSubviews
            subviews.forEach { $0.tintColor = color }
            subviews.compactMap { $0 as? UILabel }.forEach { $0.textColor = color }
            subviews.compactMap { $0 as? UIButton }.forEach { $0.setTitleColor(color, for: .normal) }
            changeImageButton.tintColor = color
            exportButton.tintColor = color
        }
    }
    
    func addAllShadows() {
        addShadow(opacity: 0.3, changeImageButton, exportButton)
        for stack in subStacks {
            for view in stack.arrangedSubviews where view.tag == 1 {
                addShadow(view)
            }
        }
    }
    
    func removeAllShadows() {
        changeImageButton.layer.shadowOpacity = 0
        exportButton.layer.shadowOpacity = 0
        for stack in subStacks {
            for view in stack.arrangedSubviews where view.tag == 1 {
                view.layer.shadowOpacity = 0
            }
        }
    }
}

extension ForecastViewController: ExportHost {
    
    var viewsExcludedFromScreenshot: [UIView] {
        return [changeImageButton, exportButton]
    }
    
    @IBAction func exportButtonPressed(_ sender: UIButton) {
        exportBy(sender, anchorSide: .bottom)
    }
}
