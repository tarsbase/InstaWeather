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

class WeatherViewController: UIViewController, ChangeCityDelegate, AdHosting {

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
    var appStoreVC: SKStoreProductViewController?
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
    lazy var imageMenu: ImageMenu = createImageMenuFor(host: .mainScreen)
    var imageMenuIsVisible = false {
        didSet { menuIsVisibleChanged(to: imageMenuIsVisible) }
    }
    weak var statusBarUpdater: StatusBarUpdater?
    
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
    }
    
    func setupStoryboard() {
        addShadow(segmentedControl, conditionImage, changeCityButton, cityLabel, tempLabel, maxTempLabel, minTempLabel, windLabel, humidityLabel, windIcon, lastUpdated)
//        addShadow(opacity: 0.5, feelsLikeLabel)
        addShadow(opacity: 0.3, changeImageButton)
        _ = imageMenu
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
    
    func addShadow(opacity: Float = 0.5, _ views: UIView...) {
        for view in views {
            view.layer.shadowColor = UIColor.black.cgColor
            view.layer.shadowOffset = CGSize(width: 0, height: 2)
            view.layer.shadowOpacity = opacity
            view.layer.shadowRadius = 1.0
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
    
    @IBAction func debugBackground(_ sender: Any) {
        
        let names = ["bg3clear"]
        
        // keep 1,2,4
        
        backgroundImage.image = UIImage(named: names[debugBackgroundCounter])
        
        if (debugBackgroundCounter + 1) == names.count {
            debugBackgroundCounter = 0
        } else {
            debugBackgroundCounter += 1
        }
    }
    
}

extension WeatherViewController: SKStoreProductViewControllerDelegate {
    
    func launchAppStorePage(for app: AppStoreAppsKeys) {
        guard self.appStoreVC == nil else { return }
        let appStoreVC = SKStoreProductViewController()
        appStoreVC.delegate = self
        appStoreVC.loadProduct(withParameters: [SKStoreProductParameterITunesItemIdentifier: app.id]) { [weak self] (result, error) in
            if result {
                self?.present(appStoreVC, animated: true, completion: nil)
            } else {
                print(error?.localizedDescription ?? "ERROR loading app store" )
            }
        }
        self.appStoreVC = appStoreVC
    }
    
    func productViewControllerDidFinish(_ viewController: SKStoreProductViewController) {
        appStoreVC?.dismiss(animated: true, completion: nil)
        appStoreVC = nil
    }
    
    
}

// MARK: - Image menu
extension WeatherViewController: ImageMenuDelegate {
    
    func resetBackgroundImage() {
        updateLabelsNoAnimation()
    }
    
    @IBAction func imageChangePressed(_ sender: Any) {
        imageMenuIsVisible = true
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
}
