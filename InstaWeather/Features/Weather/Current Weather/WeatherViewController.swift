//
//  ViewController.swift
//  Rain Check
//
//  Created by Besher on 2018-01-27.
//  Copyright © 2018 Besher Al Maleh. All rights reserved.
//

import UIKit
import CoreLocation

class WeatherViewController: ParallaxViewController, AdHosting {

    // MARK - Properties
    
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
    @IBOutlet weak var lastUpdated: UpdateTimestamp!
    @IBOutlet weak var changeImageButton: CustomImageButton!
    @IBOutlet weak var backgroundContainer: UIView!
    @IBOutlet weak var exportButton: UIButton!
    @IBOutlet weak var memoriesButton: CustomImageButton!
    
    var socialExport: SocialExport? // holds reference to activity sheets
    var memoriesDemoImages = [MemoriesSnapshot]()
    
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
            return weatherDataModel.getHostType()
        }
    }
    
    override var parallaxImage: UIImageView? {
        get { return backgroundImage } set { }
    }
    
    // MARK: - View Life Cycle
    
    override func viewWillTransition(to size: CGSize, with coordinator: UIViewControllerTransitionCoordinator) {
        super.viewWillTransition(to: size, with: coordinator)
        recreateMenus()
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        loadLastLocation()
        
        // load last used scale unit
        ScaleManagement.loadScale(control: segmentedControl) { [weak self] in self?.evaluateSegment(onStartup: true) }
        
        // load saved data here
        updateWeatherLabelsInstantly()
        
        // updates location when app goes to foreground
        NotificationCenter.default.addObserver(forName: UIApplication.willEnterForegroundNotification, object: nil, queue: .main) {
            [weak self] _ in self?.loadLastLocation() }
        
        setupStoryboard()
        ImageManager.preloadAllImages()
    }
    
    override func viewDidAppear(_ animated: Bool) {
        animateLabels()
        super.viewDidAppear(animated)
        recreateMenusIfNotVisible()
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        lastUpdated.animate(.fadeOut(duration: 0.4))
        
        super.viewWillDisappear(animated)
    }
    
    
    // MARK - Setup Components
    
    func setupStoryboard() {
        addAllShadows()
        backgroundContainer.clipsToBounds = true
        changeImageButton.pulseAnimation()
    }
    
    func setupWeatherUpdaterWith(loadPages: (() -> Void)?) {
        // setup all pageViewController pages, executed once we receive weather data
        weatherDataFetcher.setup(loadPages: loadPages)
    }
    
    func evaluateSegment(onStartup: Bool = false) {
        let index = segmentedControl.selectedSegmentIndex
        weatherDataModel.toggleScale(to: index)
        if onStartup == false {
            updateWeatherLabels(with: weatherDataModel, dataType: .scaleChange)
            weatherDataModel.saveToDisk()
        }
        ScaleManagement.saveScale(index: index)
    }
    
    func animateLabels() {
        let duration: TimeInterval = 0.2
        let scale: CGFloat = 1.03
        
        animate(inParallel:
                lastUpdated.animate(.fadeIn(duration: duration)),
                conditionImage.animate(.scale(to: scale, duration: duration),
                                       .scale(to: 1.0, duration: duration))
        )
    }
    
    // MARK: - Actions
    
    @IBAction func changeCityTapped(_ sender: UIButton) {
        AnalyticsEvents.logEvent(.changeCity)
        if let changeCityController = storyboard?.instantiateViewController(withIdentifier: "Change") as? ChangeCityViewController {
            changeCityController.weatherDelegate = self
            present(changeCityController, animated: true)
        }
    }
    
    @IBAction func clickSegment(_ sender: Any) {
        evaluateSegment()
    }
    
    @IBAction func imageChangePressed(_ sender: Any) {
        AnalyticsEvents.logEvent(.dashboardTapped)
        showDashboard()
    }
    
    @IBAction func exportButtonPressed(_ sender: UIButton) {
        exportBy(sender, anchorSide: .top)
    }
}

// MARK: - Customization

extension WeatherViewController: DashboardDelegate {
    
    var viewsToColor: [UIView] {
        return [conditionImage, tempLabel, maxTempLabel, minTempLabel, windIcon, windLabel, cityLabel,
                segmentedControl, changeCityButton, humidityLabel, exportButton, memoriesButton, changeImageButton]
    }
    
    var viewsWithFullShadow: [UIView] {
        return viewsToColor + [lastUpdated]
    }
    
    var viewsWithFadedShadow: [UIView] {
        return [changeImageButton, exportButton, memoriesButton]
    }
    
    func resetBackgroundImage() {
        updateBackgroundWithForecastImage()
    }
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        handleTouch(by: touches)
    }
    
    func addAllShadows() {
        addShadow(opacity: 0.5, viewsWithFullShadow)
        addShadow(opacity: 0.3, viewsWithFadedShadow)
    }
    
    func removeAllShadows() {
        let shadowsToRemove = viewsWithFullShadow + viewsWithFadedShadow
        shadowsToRemove.forEach { $0.layer.shadowOpacity = 0 }
    }
}

// MARK: - Export

extension WeatherViewController: ExportHost {
    
    var viewsExcludedFromScreenshot: [UIView] {
        return [exportButton, memoriesButton, changeCityButton, segmentedControl, changeImageButton]
    }
}

// MARK: - Memories

extension WeatherViewController {
    
    @IBAction func memoriesPressed(_ sender: UIButton) {
        let background = view.imageRepresentation()
        MemoriesViewController.presentBy(self, background: background, demos: memoriesDemoImages)
    }
    
    func generateDemoSnapshots() {
        DemoGenerator.generateDemoSnapshots(
            demoImages: self.memoriesDemoImages,
            backgroundImage: self.backgroundImage,
            mainView: self.view,
            hideViews: { [weak self] in self?.hideViews(self?.viewsExcludedFromScreenshot) },
            unhideViews: { [weak self] in self?.unHideViews(self?.viewsExcludedFromScreenshot) })
        { demos in
            self.memoriesDemoImages = demos
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
