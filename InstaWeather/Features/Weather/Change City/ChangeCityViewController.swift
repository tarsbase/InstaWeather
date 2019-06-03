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

class ChangeCityViewController: ParallaxViewController {
    
    // MARK: - Properties
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
    weak var weatherDelegate: WeatherRequestor?
    private var picksTable: RecentPicksTable?
    private var autoCompleteTable: AutocompleteTable?
    var socialExport: SocialExport?
    
    lazy var backgroundBlur: UIVisualEffectView = setupBackgroundBlur()
    lazy var backgroundBrightness: UIView = setupBackgroundBrightness()
    lazy var blurAnimator: UIViewPropertyAnimator = setupBlurAnimator()
    lazy var imageMenu: ImageMenu = createImageMenuFor(host: .changeCity(.all))
    
    var recentPicks: [String] {
        get { return picksTable?.recentPicks ?? [String]() }
        set { picksTable?.recentPicks = newValue }
    }
    
    override var preferredStatusBarStyle: UIStatusBarStyle {
        return .lightContent
    }
    override var parallaxImage: UIImageView? {
        get { return backgroundImage } set { }
    }
    
    // MARK: - ViewController Lifecycle
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
    
    override func viewDidDisappear(_ animated: Bool) {
        super.viewDidDisappear(animated)
        SVProgressHUD.dismiss()
    }
    
    // MARK: - Setup methods
    private func initialSetup() {
        SVProgressHUD.setBackgroundColor(UIColor.white)
        SVProgressHUD.setDefaultMaskType(.gradient)
        loadBackgroundImage()
        backgroundContainer.clipsToBounds = true
    }
    
    private func setupPicksTable() {
        picksTable = storyboard?.instantiateViewController(withIdentifier: "picks") as? RecentPicksTable
        picksTable?.delegate = self
        add(picksTable, parent: tableContainer)
        picksTable?.tableView.reloadData()
    }
    
    private func setupAutoComplete() {
        autoCompleteTable = storyboard?.instantiateViewController(withIdentifier: "autocomplete") as? AutocompleteTable
        autoCompleteTable?.setup(delegate: self)
        cityField.delegate = autoCompleteTable?.handler
        add(autoCompleteTable, parent: autoCompleteContainer)
        autoCompleteConstraint.constant = 0
    }
   
    // MARK: - Actions
    @IBAction func checkWeatherButton(_ sender: Any) {
        autoCompleteTable?.searchFirstResult()
    }
    
    @IBAction func backButton(_ sender: Any) {
        dismiss(animated: true)
    }
    
    @IBAction func currentLocationButton(_ sender: Any) {
        weatherDelegate?.updateCurrentLocation()
        DataPersistor.removeSavedCity()
        SVProgressHUD.show()
        dismiss(animated: true)
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

extension ChangeCityViewController: AutocompleteDelegate, RecentPicksDelegate {
    
    // MARK: - Animations
    
    func toggleAutoComplete(visible: Bool) {
        visible ? showAutoComplete() : hideAutoComplete()
    }
    
    private func showAutoComplete() {
        UIView.animate(withDuration: 0.2, delay: 0, options: .curveEaseOut, animations: {
            [weak self] in
            self?.autoCompleteConstraint.constant = 180
            self?.tablePicksConstraint.constant = 20
            self?.checkBtn.alpha = 0
            self?.view.layoutIfNeeded()
        })
    }
    
    private func hideAutoComplete() {
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
