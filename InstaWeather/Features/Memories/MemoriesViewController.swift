//
//  MemoriesViewController.swift
//  InstaWeather
//
//  Created by Besher on 2019-02-15.
//  Copyright © 2019 Besher Al Maleh. All rights reserved.
//

import UIKit

class MemoriesViewController: UIViewController, MemoriesHost {
    
    /// Constructor that accepts an array of backgrounds to show
    static func createBy(_ parentController: UIViewController, images: [UIImage], background: UIImage?) {
        let memories = MemoriesViewController(images: images, background: background)
        
        let navigationController = UINavigationController(rootViewController: memories)
        
        memories.navigationController?.isNavigationBarHidden = true
        
        parentController.present(navigationController, animated: false)
    }
    
    var images = [UIImage]()
    var background: UIImage?
    var backgroundView: UIImageView?
    var blurView: UIVisualEffectView?
    var swipeableView: ZLSwipeableView?
    var activeViewsCount: Int {
        return swipeableView?.activeViews().count ?? images.count
    }
    
    var cardsLongAnimationInProgress: Bool = false
    
    private init(images: [UIImage], background: UIImage?) {
        super.init(nibName: nil, bundle: nil)
        self.images = images
        self.background = background
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        view.backgroundColor = .white
        // Do any additional setup after loading the view.
        addBackground()
        setupToolbars()
        launchMemories()
        
        toggleControllerIsVisible(true)
        
        swipeableView?.didSwipe = { [weak self] view, direction, vector in
            self?.updateTitle()
        }
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        toggleToolbars(hidden: false)
    }
    
    private func addBackground() {
        let backgroundView = UIImageView(image: background)
        backgroundView.frame = view.frame
        view.addSubview(backgroundView)
        let blurView = UIVisualEffectView(frame: view.frame)
        blurView.effect = UIBlurEffect(style: .regular)
        blurView.alpha = 0
        view.addSubview(blurView)
        
        self.backgroundView = backgroundView
        self.blurView = blurView
    }
    
    private func setupToolbars() {
        navigationItem.leftBarButtonItem = UIBarButtonItem(title: "Done", style: .done, target: self, action: #selector(dismissSelf))
        
        let exportButton = UIButton(type: .custom)
        exportButton.frame = CGRect(x: 0, y: 0, width: 20, height: 20)
        exportButton.setImage(UIImage(named: "export"), for: .normal)
        exportButton.addTarget(self, action: #selector(export), for: .touchUpInside)
        
        let exportBarButton = UIBarButtonItem(customView: exportButton)
        
        if let customView = exportBarButton.customView {
            NSLayoutConstraint.activate([
                customView.widthAnchor.constraint(equalToConstant: 25),
                customView.heightAnchor.constraint(equalToConstant: 25)
                ])
        }
        
        navigationItem.rightBarButtonItem = exportBarButton
        
        let rewindButton = UIBarButtonItem(title: "Rewind", style: .plain, target: self, action: #selector(rewind))
        
        let oldestButton = UIBarButtonItem(title: "Oldest", style: .plain, target: self, action: #selector(oldest))
        
        let newestButton = UIBarButtonItem(title: "Newest", style: .plain, target: self, action: #selector(newest))
        
        let flexibleSpace = UIBarButtonItem(barButtonSystemItem: .flexibleSpace, target: self, action: nil)
        
        
        toolbarItems = [oldestButton, flexibleSpace, rewindButton, flexibleSpace, newestButton]
    }
    
}

// MARK: - Animations

extension MemoriesViewController {
    
    @objc private func export() {
        
    }
    
    @objc private func dismissSelf() {
        toggleToolbars(hidden: true)
        
        toggleControllerIsVisible(false) { [weak self] in
            self?.dismiss(animated: false)
        }
    }
    
    private func toggleControllerIsVisible(_ visible: Bool, completion: (() -> Void)? = nil) {
        let endAlpha: CGFloat = visible ? 1 : 0
        
        let anim = UIViewPropertyAnimator(duration: 0.3, curve: .linear) { [weak self] in
            guard let self = self else { return }
            self.swipeableView?.alpha = endAlpha
            self.blurView?.alpha = endAlpha
        }
        anim.addCompletion { (_) in
            completion?()
        }
        anim.startAnimation(afterDelay: 0.2)
    }
    
    func toggleToolbars(hidden: Bool) {
        self.navigationController?.setNavigationBarHidden(hidden, animated: true)
        self.navigationController?.setToolbarHidden(hidden, animated: true)
    }
}


// MARK: - Cards functionality

extension MemoriesViewController {
    
    
    @objc private func rewind() {
        swipeableView?.rewind()
        updateTitle()
    }
    
    @objc private func oldest() {
        // ensure no overlapping animations
        guard cardsLongAnimationInProgress == false else { return }
        cardsLongAnimationInProgress = true
        
        let active = activeViewsCount
        let duration: TimeInterval = 1.5
        let interval: TimeInterval = duration / Double(active)
        
        for i in 0..<active {
            DispatchQueue.main.asyncAfter(deadline: .now() + (interval * Double(i))) { [weak self] in
                guard let self = self else { return }
                let direction: Direction = Bool.random() ? .Left : .Right
                self.swipeableView?.swipeTopView(inDirection: direction)
                
                if i == (active - 1) {
                    self.cardsLongAnimationInProgress = false
                }
            }
        }
    }
    
    @objc private func newest() {
        // ensure no overlapping animations
        guard cardsLongAnimationInProgress == false else { return }
        cardsLongAnimationInProgress = true
        
        let duration: TimeInterval = 0.75
        let interval: TimeInterval = duration / Double(images.count)
        
        for i in 0..<images.count {
            DispatchQueue.main.asyncAfter(deadline: .now() + (interval * Double(i))) { [weak self] in
                guard let self = self else { return }
                self.swipeableView?.rewind()

                self.updateTitle()
                if i == (self.images.count - 1) {
                    self.cardsLongAnimationInProgress = false
                }
            }
        }
    }
    
    func updateTitle() {
        self.title = String(swipeableView?.activeViews().count ?? 0)
    }
}
