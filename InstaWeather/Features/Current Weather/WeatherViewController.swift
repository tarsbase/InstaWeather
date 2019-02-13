//
//  ViewController.swift
//  Rain Check
//
//  Created by Besher on 2018-01-27.
//  Copyright © 2018 Besher Al Maleh. All rights reserved.
//

import UIKit
import CoreLocation
import StoreKit

class WeatherViewController: ParallaxViewController, ChangeCityDelegate, AdHosting {

    @IBOutlet weak var segmentedControl: UISegmentedControl!
    @IBOutlet weak var changeCityButton: UIButton!
    @IBOutlet weak var backgroundImage: UIImageView!
    @IBOutlet weak var tempLabel: UILabel!
    @IBOutlet weak var cityLabel: UILabel!
    @IBOutlet weak var conditionImage: UIImageView!
    @IBOutlet weak var maxTempLabel: UILabel!
    @IBOutlet weak var minTempLabel: UILabel!
    @IBOutlet weak var feelsLikeLabel: UILabel!
    @IBOutlet weak var windLabel: UILabel!
    @IBOutlet weak var humidityLabel: UILabel!
    @IBOutlet weak var windIcon: UIImageView!
    @IBOutlet weak var lastUpdated: UILabel!
    @IBOutlet weak var changeImageButton: CustomImageButton!
    @IBOutlet weak var backgroundContainer: UIView!
    
    let locationManager = CLLocationManager()
    var weatherDataModel = WeatherDataModel()
    var preloadForecastTable: (() -> Void)?
    var preloadedForecastTable = false
    var recentPicksDataSource: RecentPicksDataSource?
    var debugBackgroundCounter = 0
    let delegate = UIApplication.shared.delegate as? AppDelegate
    var reconnectTimer: Timer? {
        set {
            delegate?.reconnectTimer = newValue
        }
        get {
            return delegate?.reconnectTimer
        }
    }
    lazy var backgroundBlur: UIVisualEffectView = setupBackgroundBlur()
    lazy var backgroundBrightness: UIView = setupBackgroundBrightness()
    lazy var blurAnimator: UIViewPropertyAnimator = setupBlurAnimator()
    lazy var imageMenu: ImageMenu = createImageMenuFor(host: .mainScreen(.clear))
    lazy var dashboardMenu: Dashboard = createDashboardFor(host: .mainScreen(.clear))
    var imageMenuIsVisible = false {
        didSet { toggleImageMenu(visible: imageMenuIsVisible) }
    }
    weak var statusBarUpdater: StatusBarUpdater?
    
    var hostType: PickerHostType {
        if AppSettings.mainscreenBackgrounds.oneBackgroundForAllConditions {
            return PickerHostType.setup(weatherType: .all, from: .mainScreen(.all))
        } else {
            return PickerHostType.setup(weatherType: weatherDataModel.weatherType, from: .mainScreen(.all))
        }
    }
    
    override var parallaxImage: UIImageView? {
        get { return backgroundImage } set { }
    }
    
    var viewsToColor: [UIView] {
        return [conditionImage, tempLabel, maxTempLabel, minTempLabel, windIcon,
                windLabel, cityLabel, segmentedControl, changeCityButton,
                changeImageButton, humidityLabel
        ]
    }
    
    override func viewWillTransition(to size: CGSize, with coordinator: UIViewControllerTransitionCoordinator) {
        super.viewWillTransition(to: size, with: coordinator)
        recreateMenus()
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        assignDelegate()
        locationManager.desiredAccuracy = kCLLocationAccuracyHundredMeters
        locationManager.requestWhenInUseAuthorization()
        loadLastLocation()
        loadScale()
        
        // load saved data here
        updateLabelsNoAnimation()
        
        // updates location when app goes to foreground
        NotificationCenter.default.addObserver(forName: UIApplication.willEnterForegroundNotification, object: nil, queue: .main) {
            [unowned self] _ in
            self.assignDelegate()
            self.loadLastLocation()
        }
        setupStoryboard()
        
        ImageManager.preloadAllImages()
    }
    
    func setupStoryboard() {
        addAllShadows()
        ImageMenu.imageMenusArray.append(imageMenu)
        backgroundContainer.clipsToBounds = true
        CustomImageButton.buttonsArray.insert(changeImageButton)
        animateCameraButton()
    }
    
    override func viewDidAppear(_ animated: Bool) {
        // add check for last updated here
        let feelsLikeScale:CGFloat = 1.06
        let conditionScale:CGFloat = 1.03
        UIView.animate(withDuration: 0.2, delay: 0, options: .curveEaseInOut, animations: {
            [unowned self] in
            self.lastUpdated.alpha = 1
            self.conditionImage.transform = CGAffineTransform(scaleX: conditionScale, y: conditionScale)
            self.feelsLikeLabel.transform = CGAffineTransform(scaleX: feelsLikeScale, y: feelsLikeScale)
            }, completion: {
                [unowned self] boolean in
                UIView.animate(withDuration: 0.2, delay: 0, options: .curveEaseOut, animations: {
                    [unowned self] in
                    self.conditionImage.transform = CGAffineTransform(scaleX: 1, y: 1)
                    self.feelsLikeLabel.transform = CGAffineTransform(scaleX: 1, y: 1)
                    }, completion: nil)
        })
        super.viewDidAppear(animated)
        CustomImageButton.buttonsArray.forEach { $0.isHidden = AppSettings.hideCameras }
        recreateMenusIfNotVisible()
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        
        UIView.animate(withDuration: 0.4, delay: 0, options: .curveEaseInOut, animations: {
            [unowned self] in
            self.lastUpdated.alpha = 0
            }, completion: nil)
        super.viewWillDisappear(animated)
    }
        
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "changeCity" {
            if let destination = segue.destination as? ChangeCityViewController {
                destination.delegate = self
                recentPicksDataSource = destination
            }
        }
    }
    @IBAction func clickSegment(_ sender: Any) {
        evaluateSegment()
        if let defaults = UserDefaults(suiteName: "group.com.besher.InstaWeather") {
            defaults.set(segmentedControl.selectedSegmentIndex, forKey: "tempScale")
        }
    }
    
    func evaluateSegment(onStartup: Bool = false) {
        weatherDataModel.toggleScale(to: segmentedControl.selectedSegmentIndex)
        if !onStartup {
            updateLabel(tempLabel, toValue: weatherDataModel.temperature, forType: .mainTemperature)
            updateLabel(minTempLabel, toValue: weatherDataModel.minTemp, forType: .minTemp)
            updateLabel(maxTempLabel, toValue: weatherDataModel.maxTemp, forType: .maxTemp)
            updateYahooLabels()
        }
    }
    
    func assignDelegate() {
        locationManager.delegate = self
    }
    
    func loadScale() { // takes migration into account
        if let defaults = UserDefaults(suiteName: "group.com.besher.InstaWeather") {
            var scale: Int = 0
            if let loadOBject = UserDefaults.standard.object(forKey: "tempScale") as? Int {
                scale = loadOBject
                segmentedControl.selectedSegmentIndex = scale
                clickSegment(self)
                UserDefaults.standard.removeObject(forKey: "tempScale")
            }
            if let loadObject = defaults.object(forKey: "tempScale") as? Int {
                scale = loadObject
            }
            segmentedControl.selectedSegmentIndex = scale
            evaluateSegment(onStartup: true)
        }
    }
    
    func lastUpdateWasUpdated() {
        let date = Date()
        weatherDataModel.lastUpdated = date
        updateLastLabel(withDate: date)
    }
    
    func updateLastLabel(withDate date: Date) {
        let dateString = weatherDataModel.lastUpdatedFormatter.string(from: date)
        lastUpdated.text = "Last updated: \(dateString)"
    }
    
    func deactivateTimer() {
        delegate?.deactivateTimer()
    }
    
//    @IBAction func debugBackground(_ sender: Any) {
//
//        let names = ["bg3clear"]
//
//        // keep 1,2,4
//
//        backgroundImage.image = UIImage(named: names[debugBackgroundCounter])
//
//        if (debugBackgroundCounter + 1) == names.count {
//            debugBackgroundCounter = 0
//        } else {
//            debugBackgroundCounter += 1
//        }
//    }
    
    func backgroundWasResetInImageMenu() {
        dismissImageMenu()
    }
}

// MARK: - Image menu
extension WeatherViewController: DashboardDelegate {
    
    func resetBackgroundImage() {
        updateLabelsNoAnimation()
    }
    
    @IBAction func imageChangePressed(_ sender: Any) {
        showDashboard()
    }
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        handleTouch(by: touches)
    }
    
    func animateCameraButton(counter: Int = 0) {
        guard AppSettings.appLaunchCount < 3 else { return }
        guard counter < 10 else { return }
        let scale: CGFloat = 1.3
        
        UIView.animateKeyframes(withDuration: 1, delay: 0, options: [.calculationModeCubic, .allowUserInteraction], animations: {
            UIView.addKeyframe(withRelativeStartTime: 0, relativeDuration: 0.5, animations: { [ weak self] in
                guard let self = self else { return }
                self.changeImageButton.transform = CGAffineTransform(scaleX: scale, y: scale)
            })
            UIView.addKeyframe(withRelativeStartTime: 0.5, relativeDuration: 0.5, animations: { [ weak self] in
                guard let self = self else { return }
                self.changeImageButton.transform = .identity
            })
        }) { [weak self] (finish) in
            self?.animateCameraButton(counter: counter + 1)
        }
    }
    
    func pickedNewTextColor(_ color: UIColor) {
        viewsToColor.forEach { $0.tintColor = color }
        _ = viewsToColor.map { $0 as? UILabel }.compactMap { $0?.textColor = color }
        _ = viewsToColor.map { $0 as? UIButton }.compactMap { $0?.setTitleColor(color, for: .normal) }
    }
    
    func requestReview() {
        // skip if already presenting
        if self.presentedViewController != nil {
            return
        }
        if AppSettings.appLaunchCount > 1 && !AppSettings.alreadySubmittedReview {
            AppSettings.alreadySubmittedReview = true
            SKStoreReviewController.requestReview()
        }
    }
    
    func addAllShadows() {
        addShadow(segmentedControl, conditionImage, changeCityButton, cityLabel, tempLabel, maxTempLabel, minTempLabel, windLabel, humidityLabel, windIcon, lastUpdated)
        addShadow(opacity: 0.3, changeImageButton)
    }
    
    func removeAllShadows() {
        let shadowsToRemove = [segmentedControl, conditionImage, changeCityButton, cityLabel, tempLabel, maxTempLabel, minTempLabel, windLabel, humidityLabel, windIcon, lastUpdated, changeImageButton]
        
        shadowsToRemove.forEach {
            $0?.layer.shadowOpacity = 0
        }
    }
}
