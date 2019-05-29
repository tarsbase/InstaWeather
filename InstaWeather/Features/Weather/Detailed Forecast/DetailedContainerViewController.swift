//
//  DetailedContainerViewController.swift
//  InstaWeather
//
//  Created by Besher on 2018-06-24.
//  Copyright © 2018 Besher Al Maleh. All rights reserved.
//

import UIKit

class DetailedContainerViewController: ParallaxViewController {

    @IBOutlet weak var tableContainer: UIView!
    @IBOutlet weak var backgroundContainer: UIView!
    @IBOutlet weak var backgroundImage: UIImageView!
    @IBOutlet weak var changeImageButton: CustomImageButton!
    @IBOutlet weak var exportButton: CustomImageButton!
    
    lazy var backgroundBlur: UIVisualEffectView = setupBackgroundBlur()
    lazy var backgroundBrightness: UIView = setupBackgroundBrightness()
    lazy var blurAnimator: UIViewPropertyAnimator = setupBlurAnimator()
    
    var imageMenu: ImageMenu = {
        let imageMenu = ImageMenu()
        imageMenu.hostType = .detailedForecast(.all)
        return imageMenu
        }() {
        didSet {
            assignImageMenuToTable()
        }
    }
    
    var socialExport: SocialExport?
    
    var detailedForecast: DetailedForecastTable?
    var gestureView = UIView()
    override var parallaxImage: UIImageView? {
        get { return backgroundImage } set { }
    }
    
    override func viewWillTransition(to size: CGSize, with coordinator: UIViewControllerTransitionCoordinator) {
        super.viewWillTransition(to: size, with: coordinator)
        recreateMenus()
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        loadBackgroundImage()
        backgroundContainer.clipsToBounds = true
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        recreateMenusIfNotVisible()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        if detailedForecast == nil {
            detailedForecast = storyboard?.instantiateViewController(withIdentifier: "detailed") as? DetailedForecastTable
            add(detailedForecast, parent: tableContainer)
        } 
        assignImageMenuToTable()
        view.bringSubviewToFront(gestureView)
        view.bringSubviewToFront(changeImageButton)
        view.bringSubviewToFront(exportButton)
        view.bringSubviewToFront(imageMenu)
        super.viewWillAppear(animated)
    }
}

extension DetailedContainerViewController: ImageMenuDelegate {
    
    
    var viewsToColor: [UIView] {
        return [changeImageButton]
    }
    
    func loadBackgroundImage() {
        let hostType: PickerHostType = .detailedForecast(.all)
        if let savedBackground = ImageManager.getBackgroundImage(for: hostType) {
            if ImageManager.customBackgroundFor(host: hostType) {
                backgroundImage.image = savedBackground
                return
            }
        }
        resetBackgroundImage()
    }
    
    func resetBackgroundImage() {
        backgroundImage.image = ImageManager.loadImage(named: "forecast")
    }
    
    @IBAction func imageChangePressed(_ sender: Any) {
        imageMenu.isVisible = true
//         gestureView.isHidden = false
    }
    
    @objc func dismissImageTap() {
        dismissImageMenu()
    }
    
    func assignImageMenuToTable() {
        detailedForecast?.setup(with: weatherDataModel, imageMenu: imageMenu)
    }
    
    func pickedNewTextColor(_ color: UIColor) {
        changeImageButton.tintColor = color
        exportButton.tintColor = color
        detailedForecast?.changeCellsColorTo(color)
    }
    
    func addAllShadows() {
        addShadow(opacity: 0.3, changeImageButton, exportButton)
        detailedForecast?.toggleShadows(to: true)
    }
    
    func removeAllShadows() {
        changeImageButton.layer.shadowOpacity = 0
        exportButton.layer.shadowOpacity = 0
        detailedForecast?.toggleShadows(to: false)
    }
}

extension DetailedContainerViewController: ExportHost {
    
    var viewsExcludedFromScreenshot: [UIView] {
        return [changeImageButton, exportButton]
    }
    
    @IBAction func exportButtonPressed(_ sender: UIButton) {
        exportBy(sender, anchorSide: .bottom)
    }
}
