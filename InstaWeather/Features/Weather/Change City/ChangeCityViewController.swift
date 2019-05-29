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

protocol ChangeCityDelegate: AnyObject {
    func getWeatherForCoordinates(latitude: String, longitude: String, location: CLLocation, city: String)
    var locationManager: LocationManager { get }
}

class ChangeCityViewController: ParallaxViewController, UITextFieldDelegate {
    
    // Properties
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
    weak var delegate: ChangeCityDelegate?
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
    
    override var preferredStatusBarStyle: UIStatusBarStyle {
        return .lightContent
    }
    override var parallaxImage: UIImageView? {
        get { return backgroundImage } set { }
    }
    
    // ViewController Lifecycle
    
    override func viewWillTransition(to size: CGSize, with coordinator: UIViewControllerTransitionCoordinator) {
        super.viewWillTransition(to: size, with: coordinator)
        recreateMenus()
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        initialSetup()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        setupPicksTable()
        setupAutoComplete()
        recreateMenusIfNotVisible()
    }
        
    override func viewWillDisappear(_ animated: Bool) {
        blurAnimator.stopAnimation(true)
        picksTable?.remove()
        autoCompleteTable?.remove()
        super.viewWillDisappear(animated)
    }
    
    func initialSetup() {
        self.cityField.delegate = self
        SVProgressHUD.setBackgroundColor(UIColor.white)
        SVProgressHUD.setDefaultMaskType(.gradient)
        loadBackgroundImage()
        backgroundContainer.clipsToBounds = true
    }
    
    func setupPicksTable() {
        guard let recentPicks = UserDefaults.standard.array(forKey: "recentPicks") as? [String],
            recentPicks.isEmpty == false else { return }
        self.recentPicks = recentPicks
        picksTable = storyboard?.instantiateViewController(withIdentifier: "picks") as? RecentPicksTable
        add(picksTable, parent: tableContainer)
        picksTable?.tableView.reloadData()
    }
    
    func setupAutoComplete() {
        autoCompleteTable = storyboard?.instantiateViewController(withIdentifier: "autocomplete") as? AutoCompleterTable
        autoCompleteTable?.changeCityVC = self
        add(autoCompleteTable, parent: autoCompleteContainer)
        autoCompleteConstraint.constant = 0
    }
   
    // MARK: - Actions
    @IBAction func checkWeatherButton(_ sender: Any) {
        searchFirstResult()
    }
    
    @IBAction func backButton(_ sender: Any) {
        dismiss(animated: true)
    }
    
    @IBAction func currentLocationButton(_ sender: Any) {
        delegate?.locationManager.startUpdatingLocation()
        UserDefaults.standard.removeObject(forKey: "cityChosen")
        SVProgressHUD.show()
        dismiss(animated: true) {
            SVProgressHUD.dismiss()
        }
    }
    
    func checkWeatherFromAutocomplete(for result: String) {
        AutocompleteHandler.checkWeather(for: result,
                                         delegate: delegate,
                                         picks: recentPicks) { (recentPicks) in
                                            self.recentPicks = recentPicks ?? self.recentPicks
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
        let hostType: PickerHostType = .changeCity(.all)
        if let savedBackground = ImageManager.getBackgroundImage(for: hostType) {
            if ImageManager.customBackgroundFor(host: hostType) {
                backgroundImage.image = savedBackground
                return
            }
        }
        resetBackgroundImage()
    }
    
    func resetBackgroundImage() {
        backgroundImage.image = ImageManager.loadImage(named: "bgselect3")
    }
    
    @IBAction func imageChangePressed(_ sender: Any) {
        imageMenu.isVisible = true
    }
    
    func pickedNewTextColor(_ color: UIColor) {
        viewsToColor.forEach { $0.tintColor = color }
        viewsToColor.compactMap { $0 as? UILabel }.forEach { $0.textColor = color }
        viewsToColor.compactMap { $0 as? UIButton }.forEach { $0.setTitleColor(color, for: .normal) }
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
        exportBy(sender, anchorSide: .top)
    }
}
