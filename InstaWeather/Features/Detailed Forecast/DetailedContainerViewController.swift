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
    lazy var imageMenu: ImageMenu = createImageMenuFor(host: .detailedForecast(.clear))
    var imageMenuIsVisible = false {
        didSet { toggleImageMenu(visible: imageMenuIsVisible)
            gestureView.isHidden = !imageMenuIsVisible
        }
    }
    weak var statusBarUpdater: StatusBarUpdater?
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
        ImageMenu.imageMenusArray.append(imageMenu)
        backgroundContainer.clipsToBounds = true
        CustomImageButton.buttonsArray.insert(changeImageButton)
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        recreateMenusIfNotVisible()
    }
    
    override func viewWillAppear(_ animated: Bool) {
     
        if detailedForecast == nil {
            detailedForecast = storyboard?.instantiateViewController(withIdentifier: "detailed") as? DetailedForecastTable
            if let detailed = detailedForecast {
                add(detailed, frame: tableContainer.frame)
            }
        } else {
            detailedForecast?.refreshModel()
        }
        view.bringSubviewToFront(gestureView)
        view.bringSubviewToFront(changeImageButton)
        view.bringSubviewToFront(exportButton)
        view.bringSubviewToFront(imageMenu)
        super.viewWillAppear(animated)
    }
    
    // necessary for iPad layout, otherwise it's too small
    override func viewDidLayoutSubviews() {
        detailedForecast?.view.frame = tableContainer.frame
        super.viewDidLayoutSubviews()
    }
    
    override func viewDidDisappear(_ animated: Bool) {
//        detailedForecast?.remove()
//        detailedForecast = nil
        super.viewDidDisappear(animated)
    }

}

extension DetailedContainerViewController: ImageMenuDelegate {
    
    
    var viewsToColor: [UIView] {
        return [changeImageButton]
    }
    
    func loadBackgroundImage() {
        if AppSettings.detailedForecastBackgrounds.allWeather.customBackground {
            loadCustomImage()
        } else {
            resetBackgroundImage()
        }
    }
    
    func resetBackgroundImage() {
        backgroundImage.image = ImageManager.loadImage(named: "forecast")
    }
    
    @IBAction func imageChangePressed(_ sender: Any) {
        imageMenuIsVisible = true
    }
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
//        handleTouch(by: touches)
    }
    
    @objc func dismissImageTap() {
        dismissImageMenu()
    }
    
    func pickedNewTextColor(_ color: UIColor) {
        changeImageButton.tintColor = color
        exportButton.tintColor = color
        detailedForecast?.changeCellsColorTo(color)
    }
    
    func addAllShadows() {
        addShadow(opacity: 0.3, changeImageButton, exportButton)
        if let cells = detailedForecast?.getCellsToShade() {
            cells.forEach { addShadow($0) }
        }
        detailedForecast?.cellsShadow = true
    }
    
    func removeAllShadows() {
        changeImageButton.layer.shadowOpacity = 0
        exportButton.layer.shadowOpacity = 0
        if let cells = detailedForecast?.getCellsToShade() {
            cells.forEach { $0.layer.shadowOpacity = 0 }
        }
        detailedForecast?.cellsShadow = false
    }
}

extension DetailedContainerViewController: ExportHost {
    
    var viewsExcludedFromScreenshot: [UIView] {
        return [changeImageButton, exportButton]
    }
    
    @IBAction func exportButtonPressed(_ sender: UIButton) {
        exportBy(sender)
    }
}
