//
//  ChangeCityViewController.swift
//  Rain Check
//
//  Created by Besher on 2018-01-27.
//  Copyright © 2018 Besher Al Maleh. All rights reserved.
//

import UIKit
import SVProgressHUD
import CoreLocation
import MapKit

protocol ChangeCityDelegate {
    func assignDelegate()
    func getWeatherForCoordinates(latitude: String, longitude: String, location: CLLocation, city: String)
    var locationManager: CLLocationManager { get }
}

protocol RecentPicksDataSource {
    func removeLastRecentPick()
}

class ChangeCityViewController: ParallaxViewController, RecentPicksDataSource, UITextFieldDelegate {
    
    @IBOutlet weak var hideCamerasButton: LargeTapAreaButton!
    @IBOutlet weak var changeImageButton: CustomImageButton!
    @IBOutlet weak var exportButton: CustomImageButton!
    @IBOutlet weak var backButton: UIButton!
    @IBOutlet weak var currentLocationButton: UIButton!
    @IBOutlet weak var autoCompleteContainer: UIView!
    @IBOutlet weak var poweredByLabel: UILabel!
    @IBOutlet weak var tableContainer: UIView!
    @IBOutlet weak var backgroundImage: UIImageView!
    @IBOutlet weak var cityField: UITextField!
    @IBOutlet weak var autoCompleteConstraint: NSLayoutConstraint!
    @IBOutlet weak var tablePicksConstraint: NSLayoutConstraint!
    @IBOutlet weak var checkBtn: UIButton!
    @IBOutlet weak var backgroundContainer: UIView!
    var delegate: ChangeCityDelegate?
    var picksTable: RecentPicksTable?
    var autoCompleteTable: AutoCompleterTable?
    var socialExport: SocialExport?
    var recentPicks = [String]() {
        didSet {
            UserDefaults.standard.set(recentPicks, forKey: "recentPicks")
        }
    }
    
    lazy var backgroundBlur: UIVisualEffectView = setupBackgroundBlur()
    lazy var backgroundBrightness: UIView = setupBackgroundBrightness()
    lazy var blurAnimator: UIViewPropertyAnimator = setupBlurAnimator()
    lazy var imageMenu: ImageMenu = createImageMenuFor(host: .changeCity(.all))
    var imageMenuIsVisible = false {
        didSet { toggleImageMenu(visible: imageMenuIsVisible) }
    }
    weak var statusBarUpdater: StatusBarUpdater?
    
    override var preferredStatusBarStyle: UIStatusBarStyle {
        return .lightContent
    }
    override var parallaxImage: UIImageView? {
        get { return backgroundImage } set { }
    }
    
    override func viewWillTransition(to size: CGSize, with coordinator: UIViewControllerTransitionCoordinator) {
        super.viewWillTransition(to: size, with: coordinator)
        recreateMenus()
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.cityField.delegate = self
        SVProgressHUD.setBackgroundColor(UIColor.white)
        SVProgressHUD.setDefaultMaskType(.gradient)
        loadBackgroundImage()
        ImageMenu.imageMenusArray.append(imageMenu)
        backgroundContainer.clipsToBounds = true
        CustomImageButton.buttonsArray.insert(changeImageButton)
        let title = AppSettings.hideCameras ? "Show Camera Buttons" : "Hide Camera Buttons"
        hideCamerasButton.setTitle(title, for: .normal)
        changeImageButton.isHidden = AppSettings.hideCameras
    }
    
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        if let loadObjet = UserDefaults.standard.array(forKey: "recentPicks") as? [String] {
            recentPicks = loadObjet
        }
        if !recentPicks.isEmpty {
            picksTable = storyboard?.instantiateViewController(withIdentifier: "picks") as? RecentPicksTable
            if let picksTable = picksTable {
                add(picksTable, frame: tableContainer.frame)
                picksTable.tableView.reloadData()
            }
        }
        
        autoCompleteTable = storyboard?.instantiateViewController(withIdentifier: "autocomplete") as? AutoCompleterTable
        autoCompleteTable?.changeCityVC = self
        if let autoCompleteTable = autoCompleteTable {
            add(autoCompleteTable, frame: tableContainer.frame)
        }
        autoCompleteConstraint.constant = 0
        recreateMenusIfNotVisible()
    }
    
    // necessary to line up the tableView properly
    override func viewDidLayoutSubviews() {
        picksTable?.view.frame = tableContainer.frame
        autoCompleteTable?.view.frame = autoCompleteContainer.frame
        super.viewDidLayoutSubviews()
    }
    
        
    override func viewWillDisappear(_ animated: Bool) {
        picksTable?.remove()
        autoCompleteTable?.remove()
        CustomImageButton.buttonsArray.remove(changeImageButton)
        super.viewWillDisappear(animated)
    }
   
    
    @IBAction func checkWeatherButton(_ sender: Any) {
        searchFirstResult()
    }
    
    
    @IBAction func backButton(_ sender: Any) {
        dismiss(animated: true)
    }
    
    func checkWeatherFromAutocomplete(for result: String) {
        SVProgressHUD.show()
        UserDefaults.standard.set(result, forKey: "cityChosen")
        let indexOfComma = result.index(of: ",")
        var city = result
        
        if let index = indexOfComma {
            city = String(result[result.startIndex..<index])
        }
        
        let request = MKLocalSearch.Request()
        request.naturalLanguageQuery = result
        let search = MKLocalSearch(request: request)
        search.start { [unowned self](response, error) in
            guard let response = response, result.count > 1 else {
                self.dismiss(animated: true) {
                    SVProgressHUD.dismiss()
                }
                return }
            if let coordinates = response.mapItems.first?.placemark.coordinate {
                let latitude = coordinates.latitude
                let longitude = coordinates.longitude
                self.delegate?.getWeatherForCoordinates(latitude: String(latitude), longitude: String(longitude), location: CLLocation(latitude: latitude, longitude: longitude), city: city)
                let name = result.lowercased().capitalized
                if !self.recentPicks.contains(name) {
                    self.recentPicks.insert(name, at: 0)
                } else {
                    if let index = self.recentPicks.index(of: name) {
                        self.recentPicks.insert(self.recentPicks.remove(at: index), at: 0)
                    }
                }
                self.dismiss(animated: true) {
                    SVProgressHUD.dismiss()
                }
            }
        }
    }
    
    @IBAction func currentLocationButton(_ sender: Any) {
        delegate?.assignDelegate()
        delegate?.locationManager.startUpdatingLocation()
        UserDefaults.standard.removeObject(forKey: "cityChosen")
        SVProgressHUD.show()
        dismiss(animated: true) {
            SVProgressHUD.dismiss()
        }
    }
    
    func deleteCity(_ city: String) {
        let cityToDelete = city.lowercased().capitalized
        if let index = recentPicks.index(of: cityToDelete) {
            recentPicks.remove(at: index)
        }
    }
    
    func removeLastRecentPick() {
        recentPicks.removeFirst()
        UserDefaults.standard.set(recentPicks, forKey: "recentPicks")
    }
    
    // MARK: - UITextField Delegate methods
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        textField.resignFirstResponder()
        searchFirstResult()
        return true
    }
    
    func searchFirstResult() {
        var cityName = cityField.text!
        if let searchResult = autoCompleteTable?.completionResults.first {
            cityName = searchResult
        }
        checkWeatherFromAutocomplete(for: cityName)
    }
    
    func textField(_ textField: UITextField, shouldChangeCharactersIn range: NSRange, replacementString string: String) -> Bool {
        autoCompleteTable?.startCompleter()
        return true
    }
    
    func showAutoComplete() {
        UIView.animate(withDuration: 0.2, delay: 0, options: .curveEaseOut, animations: {
            [weak self] in
            self?.autoCompleteConstraint.constant = 180
            self?.tablePicksConstraint.constant = 20
            self?.checkBtn.alpha = 0
            self?.view.layoutIfNeeded()
        })
        
    }
    
    func hideAutoComplete() {
        UIView.animate(withDuration: 0.3, delay: 0, options: .curveEaseOut, animations: {
            [weak self] in
            self?.autoCompleteConstraint.constant = 0
            self?.tablePicksConstraint.constant = 50
            self?.view.layoutIfNeeded()
            }, completion: {
                [weak self] _ in
                UIView.animate(withDuration: 0.2, animations: {
                    [weak self] in
                    self?.checkBtn.alpha = 1
                })
        })
    }
}

// MARK: - Image Manager
extension ChangeCityViewController: ImageMenuDelegate {
    var viewsToColor: [UIView] {
        return [changeImageButton, checkBtn, currentLocationButton, backButton, poweredByLabel, exportButton]
    }
    
    
    func loadBackgroundImage() {
        if let savedBackground = ImageManager.getBackgroundImage(for: .changeCity(.all)) {
            backgroundImage.image = savedBackground
        } else {
            resetBackgroundImage()
        }
    }
    
    func resetBackgroundImage() {
        backgroundImage.image = ImageManager.loadImage(named: "bgselect3")
    }
    
    @IBAction func imageChangePressed(_ sender: Any) {
        imageMenuIsVisible = true
    }
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
//        handleTouch(by: touches)
    }
    
    @IBAction func hideCameras(_ sender: UIButton) {
        if AppSettings.hideCameras {
            AppSettings.hideCameras = false
            sender.setTitle("Hide Camera Buttons", for: .normal)
        } else {
            AppSettings.hideCameras = true
            sender.setTitle("Show Camera Buttons", for: .normal)
        }
        CustomImageButton.buttonsArray.forEach { $0.isHidden = AppSettings.hideCameras }
    }
    
    func pickedNewTextColor(_ color: UIColor) {
        viewsToColor.forEach { $0.tintColor = color }
        _ = viewsToColor.map { $0 as? UILabel }.compactMap { $0?.textColor = color }
        _ = viewsToColor.map { $0 as? UIButton }.compactMap { $0?.setTitleColor(color, for: .normal) }
        picksTable?.changeCellsColorTo(color)
    }
    
    func addAllShadows() {
        viewsToColor.forEach { addShadow($0) }
    }
    
    func removeAllShadows() {
        viewsToColor.forEach { $0.layer.shadowOpacity = 0 }
    }
}

extension ChangeCityViewController: ExportHost {
    
    var viewsExcludedFromScreenshot: [UIView] {
        return [poweredByLabel, backButton, changeImageButton, exportButton]
    }
    
    @IBAction func exportButtonPressed(_ sender: UIButton) {
        exportBy(sender)
    }
}
