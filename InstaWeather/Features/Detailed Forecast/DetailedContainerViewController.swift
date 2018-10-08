//
//  DetailedContainerViewController.swift
//  InstaWeather
//
//  Created by Besher on 2018-06-24.
//  Copyright © 2018 Besher Al Maleh. All rights reserved.
//

import UIKit

class DetailedContainerViewController: UIViewController {

    @IBOutlet weak var tableContainer: UIView!
    @IBOutlet weak var backgroundContainer: UIView!
    @IBOutlet weak var backgroundImage: UIImageView!
    @IBOutlet weak var changeImageButton: CustomImageButton!
    
    lazy var backgroundBlur: UIVisualEffectView = setupBackgroundBlur()
    lazy var backgroundBrightness: UIView = setupBackgroundBrightness()
    lazy var blurAnimator: UIViewPropertyAnimator = setupBlurAnimator()
    lazy var imageMenu: ImageMenu = createImageMenuFor(host: .detailedForecast)
    var imageMenuIsVisible = false {
        didSet { menuIsVisibleChanged(to: imageMenuIsVisible)
            gestureView.isHidden = !imageMenuIsVisible
        }
    }
    weak var statusBarUpdater: StatusBarUpdater?
    
    var detailedForecast: DetailedForecastTable?
    var gestureView = UIView()
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        loadBackgroundImage()
        _ = imageMenu
        backgroundContainer.clipsToBounds = true
        createViewAndGesture()
        CustomImageButton.buttonsArray.insert(changeImageButton)
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
    }

}

extension DetailedContainerViewController: ImageMenuDelegate {
    func loadBackgroundImage() {
        if AppSettings.changecityCustomImage {
            loadCustomImage()
        } else {
            resetBackgroundImage()
        }
    }
    
    func resetBackgroundImage() {
        backgroundImage.image = UIImage(named: "forecast")
    }
    
    @IBAction func imageChangePressed(_ sender: Any) {
        imageMenuIsVisible = true
    }
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        handleTouch(by: touches)
    }
    
    @objc func dismissImageTap() {
        dismissImageMenu()
    }
    
    func createViewAndGesture() {
        let gestureView = UIView(frame: backgroundBlur.frame)
        gestureView.isUserInteractionEnabled = true
        view.addSubview(gestureView)
        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(dismissImageTap))
        gestureView.addGestureRecognizer(tapGesture)
        self.gestureView = gestureView
    }
}
