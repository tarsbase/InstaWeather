//
//  ViewController.swift
//  Rain Check
//
//  Created by Besher on 2018-01-27.
//  Copyright © 2018 Besher Al Maleh. All rights reserved.
//

import UIKit
import CoreLocation

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
    @IBOutlet weak var exportButton: UIButton!
    @IBOutlet weak var memoriesButton: CustomImageButton!
    
    var socialExport: SocialExport? // holds reference to activity sheets
    
    var memoriesDemoImages = [MemoriesSnapshot]() // maybe move to Memories object?
    
    lazy var captureSnapshotOnce: Void = addMemory() // maybe move to Memories object?
    lazy var locationManager = LocationManager(withDelegate: self)
    lazy var weatherDataFetcher = WeatherDataFetcher(manager: locationManager, alertPresenter: self, delegate: self)
    lazy var backgroundBlur: UIVisualEffectView = setupBackgroundBlur()
    lazy var backgroundBrightness: UIView = setupBackgroundBrightness()
    lazy var blurAnimator: UIViewPropertyAnimator = setupBlurAnimator()
    lazy var imageMenu: ImageMenu = createImageMenuFor(host: hostType)
    lazy var dashboardMenu: Dashboard = createDashboardFor(host: hostType)
    
    var hostType: PickerHostType {
        if AppSettings.mainscreenBackgrounds.singleBackground {
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
                changeImageButton, humidityLabel, exportButton, memoriesButton
        ]
    }
    
    override func viewWillTransition(to size: CGSize, with coordinator: UIViewControllerTransitionCoordinator) {
        super.viewWillTransition(to: size, with: coordinator)
        recreateMenus()
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        _ = locationManager
        
        loadLastLocation()
        loadScale()
        
        // load saved data here
        updateLabelsNoAnimation()
        
        // updates location when app goes to foreground
        NotificationCenter.default.addObserver(forName: UIApplication.willEnterForegroundNotification, object: nil, queue: .main) {
            [weak self] _ in
            self?.loadLastLocation()
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
    
    // closure will setup all pageViewController pages once we receive weather data
    func setupWeatherUpdaterWith(loadPages: (() -> Void)?) {
        weatherDataFetcher.setup(loadPages: loadPages)
    }
    
    override func viewDidAppear(_ animated: Bool) {
        // add check for last updated here
        animateLabels()
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
            AnalyticsEvents.logEvent(.changeCity)
            if let destination = segue.destination as? ChangeCityViewController {
                destination.delegate = self
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
        let formatter = DateFormatter()
        formatter.dateStyle = .medium
        formatter.timeStyle = .short
        let dateString = formatter.string(from: date)
        lastUpdated.text = "Last update: \(dateString)"
    }
    
    func deactivateTimer() {
        weatherDataFetcher.deactivateTimer()
    }
    
    func backgroundWasResetInImageMenu() {
        dismissImageMenu()
    }
    
    func animateLabels() {
        let feelsLikeScale:CGFloat = 1.06
        let conditionScale:CGFloat = 1.03
        UIView.animate(withDuration: 0.2, delay: 0, options: .curveEaseInOut, animations: {
            [weak self] in
            self?.lastUpdated.alpha = 1
            self?.conditionImage.transform = CGAffineTransform(scaleX: conditionScale, y: conditionScale)
            self?.feelsLikeLabel.transform = CGAffineTransform(scaleX: feelsLikeScale, y: feelsLikeScale)
            }, completion: { _ in
                UIView.animate(withDuration: 0.2, delay: 0, options: .curveEaseOut, animations: {
                    [weak self] in
                    self?.conditionImage.transform = CGAffineTransform(scaleX: 1, y: 1)
                    self?.feelsLikeLabel.transform = CGAffineTransform(scaleX: 1, y: 1)
                    }, completion: nil)
        })
    }
}

// MARK: - Image menu
extension WeatherViewController: DashboardDelegate {
    
    func resetBackgroundImage() {
        updateBackgroundWithForecastImage()
    }
    
    @IBAction func imageChangePressed(_ sender: Any) {
        AnalyticsEvents.logEvent(.dashboardTapped)
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
    
    func addAllShadows() {
        addShadow(segmentedControl, conditionImage, changeCityButton, cityLabel, tempLabel, maxTempLabel, minTempLabel, windLabel, humidityLabel, windIcon, lastUpdated)
        addShadow(opacity: 0.3, changeImageButton, exportButton, memoriesButton)
    }
    
    func removeAllShadows() {
        let shadowsToRemove = [segmentedControl, conditionImage, changeCityButton, cityLabel, tempLabel, maxTempLabel, minTempLabel, windLabel, humidityLabel, windIcon, lastUpdated, changeImageButton, exportButton, memoriesButton]
        
        shadowsToRemove.forEach {
            $0?.layer.shadowOpacity = 0
        }
    }
}

// MARK: - Export

extension WeatherViewController: ExportHost {
    
    var viewsExcludedFromScreenshot: [UIView] {
        return [exportButton, memoriesButton, changeCityButton, segmentedControl, changeImageButton]
    }
    
    @IBAction func exportButtonPressed(_ sender: UIButton) {
        exportBy(sender, anchorSide: .top)
    }
}

// MARK: - Memories

extension WeatherViewController {
    
    @IBAction func memoriesPressed(_ sender: UIButton) {
        
        let count = String(MemoriesCacheManager.loadAllMemories().count)
        AnalyticsEvents.logEvent(.memoriesTapped, parameters: ["memories" : count])
        
        var snapshots = MemoriesCacheManager.loadAllMemories()
        var demo = false
        if snapshots.count < 3 {
            demo = true
            snapshots.append(contentsOf: memoriesDemoImages)
        }
        
        let background = view.imageRepresentation()
        MemoriesViewController.createBy(self, snapshots: snapshots, background: background, demo: demo)
    }
    
    func addMemory() {
        if let image = getExportImage() {
            MemoriesSnapshot.addNewSnapshot(image)
        }
    }
    
    // TODO pre-generate demo sliders to avoid slowdown
    
    func generateDemoSnapshots() {
        guard memoriesDemoImages.isEmpty else { return }
        guard MemoriesCacheManager.loadAllMemories().count < 3 else { return }
        
        let totalDuration: TimeInterval = 0.07
        let numberOfDemos = ImageManager.potentialBackgrounds.count
        let interval = totalDuration / Double(numberOfDemos)
        
        for (index, background) in ImageManager.potentialBackgrounds.dropFirst(6).enumerated() {
            DispatchQueue.main.asyncAfter(deadline: .now() + (Double(index) * interval)) { [weak self] in
                guard let self = self else { return }
                NSLog("Generating Demo")
                
                let originalBackground = self.backgroundImage.image
                self.backgroundImage.image = background
                
                let demoLabel = self.generateDemoLabel()
                if let demoSnap = self.getDemoImage() {
                    let date = Calendar.current.date(byAdding: .day, value: -2, to: Date()) ?? Date()
                    let demo = MemoriesSnapshot(image: demoSnap, date: date)
                    self.memoriesDemoImages.append(demo)
                }
                
                demoLabel.removeFromSuperview()
                self.backgroundImage.image = originalBackground
            }
        }
        
        
    }
    
    func getDemoImage() -> UIImage? {
        hideViews(viewsExcludedFromScreenshot)
        let image = view.imageRepresentation()
        unHideViews(viewsExcludedFromScreenshot)
        return image
    }
    
    func generateDemoLabel() -> UILabel {
        let label = UILabel()
        label.textColor = .white
        label.text = "DEMO CARD"
        label.font = UIFont.systemFont(ofSize: 33, weight: .bold)
        label.sizeToFit()
        view.addSubview(label)
        label.center.x = view.center.x
        label.center.y = view.center.y - (view.bounds.height / 3)
        return label
    }
    
    // Memories helpers
    
    var viewsExludedNoDate: [UIView] {
        var views = viewsExcludedFromScreenshot
        views.append(lastUpdated)
        return views
    }
    
    func getExportImageNoDate() -> UIImage? {
        hideViews(viewsExludedNoDate)
        let image = view.imageRepresentation()
        unHideViews(viewsExludedNoDate)
        return image
    }
}

extension WeatherViewController: LocationManagerDelegate {
    func updateLabel(to string: String) {
        self.cityLabel.text = string
    }
    
    func didReceiveUpdatedLocation(latitude: String, longitude: String, location: CLLocation, withCity: Bool) {
        let city = withCity ? weatherDataModel.city : ""
        self.getWeatherForCoordinates(latitude: latitude, longitude: longitude, location: location, city: city)
    }
    
    func didReverseGeocode(to city: String) {
        self.weatherDataModel.city = city
        self.cityLabel.text = city
    }
    
    
}