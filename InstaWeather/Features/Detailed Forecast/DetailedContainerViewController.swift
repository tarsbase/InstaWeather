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
    
    lazy var backgroundBlur: UIVisualEffectView = setupBackgroundBlur()
    lazy var backgroundBrightness: UIView = setupBackgroundBrightness()
    lazy var blurAnimator: UIViewPropertyAnimator = setupBlurAnimator()
    lazy var imageMenu: ImageMenu = createImageMenuFor(host: .detailedForecast(.clear))
    lazy var dashboardMenu: Dashboard = createDashboardFor(host: .detailedForecast(.clear))
    var imageMenuIsVisible = false {
        didSet { toggleImageMenu(visible: imageMenuIsVisible)
            gestureView.isHidden = !imageMenuIsVisible
        }
    }
    weak var statusBarUpdater: StatusBarUpdater?
    
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
        dashboardMenu.alpha = 0
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
        dashboardMenu.fadeOut()
    }

}

extension DetailedContainerViewController: DashboardDelegate {
    
    func loadBackgroundImage() {
        if AppSettings.changecityCustomImage {
            loadCustomImage()
        } else {
            resetBackgroundImage()
        }
    }
    
    func resetBackgroundImage() {
        backgroundImage.image = ImageManager.loadImage(named: "forecast")
    }
    
    @IBAction func imageChangePressed(_ sender: Any) {
        showDashboard()
    }
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        handleTouch(by: touches)
    }
    
    @objc func dismissImageTap() {
        dismissImageMenu()
    }
}
