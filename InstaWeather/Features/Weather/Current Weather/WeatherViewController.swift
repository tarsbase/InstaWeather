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
    
    lazy var captureSnapshotForMemories: Void = addMemory() // maybe move to Memories object?
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
        print(segmentedControl)
        ScaleManagement.loadScale(control: segmentedControl) { [weak self] in self?.evaluateSegment() }
        
        // load saved data here
        updateWeatherLabelsInstantly()
        
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
        changeImageButton.pulseAnimation()
    }
    
    // this closure will setup all pageViewController pages once we receive weather data
    func setupWeatherUpdaterWith(loadPages: (() -> Void)?) {
        weatherDataFetcher.setup(loadPages: loadPages)
    }
    
    override func viewDidAppear(_ animated: Bool) {
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
    }
    
    func evaluateSegment(onStartup: Bool = false) {
        let index = segmentedControl.selectedSegmentIndex
        weatherDataModel.toggleScale(to: index)
        if !onStartup {
            updateWeatherLabels(with: self.weatherDataModel)
        }
        ScaleManagement.saveScale(index: index)
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
        let conditionScale:CGFloat = 1.03
        UIView.animate(withDuration: 0.2, delay: 0, options: .curveEaseInOut, animations: {
            [weak self] in
            self?.lastUpdated.alpha = 1
            self?.conditionImage.transform = CGAffineTransform(scaleX: conditionScale, y: conditionScale)
            }, completion: { _ in
                UIView.animate(withDuration: 0.2, delay: 0, options: .curveEaseOut, animations: {
                    [weak self] in
                    self?.conditionImage.transform = CGAffineTransform(scaleX: 1, y: 1)
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
    
    func generateDemoSnapshots() {
        if memoriesDemoImages.isEmpty {
            let concurrentQueue = DispatchQueue(label: "demos-queue", qos: .userInteractive, attributes: .concurrent, autoreleaseFrequency: .workItem, target: nil)
            concurrentQueue.async { [weak self] in
                guard let self = self else { return }
                self.memoriesDemoImages = DemoGenerator.generateDemoSnapshots(concurrentQueue: concurrentQueue,
                                                                              backgroundImage: self.backgroundImage,
                                                                              mainView: self.view,
                                                                              hideViews: { [weak self] in self?.hideViews(self?.viewsExcludedFromScreenshot) },
                                                                              unhideViews: { [weak self] in self?.unHideViews(self?.viewsExcludedFromScreenshot) })
            }
        }
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
}
