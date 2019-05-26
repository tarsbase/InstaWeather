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
    static func presentBy(_ parentController: UIViewController, background: UIImage?, demos: [MemoriesSnapshot]) {
        
        let count = String(MemoriesCacheManager.loadAllMemories().count)
        AnalyticsEvents.logEvent(.memoriesTapped, parameters: ["memories" : count])
        
        var snapshots = MemoriesCacheManager.loadAllMemories()
        var isDemo = false
        
        if snapshots.count < 3 {
            isDemo = true
            snapshots.append(contentsOf: demos)
        }
        
        let memories = MemoriesViewController(snapshots: snapshots, background: background)
        
        
        
        let navigationController = UINavigationController(rootViewController: memories)
        
        memories.navigationController?.isNavigationBarHidden = true
        memories.demo = isDemo
        
        parentController.present(navigationController, animated: false)
    }
    
    var snapshots = [MemoriesSnapshot]()
    var scaledSnapshots = [MemoriesSnapshot]()
    var scalingTimer: Timer? 
    var background: UIImage?
    var backgroundView: UIImageView?
    var blurView: UIVisualEffectView?
    var swipeableView: ZLSwipeableView?
    var socialExport: SocialExport?
    var demoAlert: UIAlertController?
    var demo = false
    var activeViewsCount: Int {
        return swipeableView?.activeViews().count ?? snapshots.count
    }
    
    var cardsLongAnimationInProgress: Bool = false
    
    private init(snapshots: [MemoriesSnapshot], background: UIImage?) {
        super.init(nibName: nil, bundle: nil)
        self.snapshots = snapshots
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
            AnalyticsEvents.logEvent(.memoriesSwipe)
            self?.updateTitle()
        }
        
        showDemoAlertIfNeeded()
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        toggleToolbars(hidden: false)
        updateTitle()
    }
    
    private func addBackground() {
        let backgroundView = UIImageView(image: background)
        backgroundView.frame = view.frame
        view.addSubview(backgroundView)
        let blurView = UIVisualEffectView(frame: view.frame)
        blurView.effect = UIBlurEffect(style: .light)
        blurView.alpha = 0
        view.addSubview(blurView)
        
        self.backgroundView = backgroundView
        self.blurView = blurView
    }
    
    private func setupToolbars() {
        navigationController?.navigationBar.barStyle = .black
        navigationController?.toolbar.barStyle = .black
        
        let doneButton = UIBarButtonItem(title: "Done", style: .done, target: self, action: #selector(dismissSelf))
        
        doneButton.tintColor = .white
        
        let exportButton = UIButton(type: .custom)
        exportButton.frame = CGRect(x: 0, y: 0, width: 20, height: 20)
        exportButton.setImage(UIImage(named: "export"), for: .normal)
        exportButton.tintColor = .white
        exportButton.addTarget(self, action: #selector(exportButtonPressed(_:)), for: .touchUpInside)
        
        let exportBarButton = UIBarButtonItem(customView: exportButton)
        
        if let customView = exportBarButton.customView {
            NSLayoutConstraint.activate([
                customView.widthAnchor.constraint(equalToConstant: 25),
                customView.heightAnchor.constraint(equalToConstant: 25)
                ])
        }
        
        let rewindButton = UIBarButtonItem(title: "Rewind", style: .plain, target: self, action: #selector(rewind))
        
        rewindButton.tintColor = .white
        
        let oldestButton = UIBarButtonItem(title: "Oldest", style: .plain, target: self, action: #selector(oldest))
        
        oldestButton.tintColor = .white
        
        let newestButton = UIBarButtonItem(title: "Newest", style: .plain, target: self, action: #selector(newest))
        
        newestButton.tintColor = .white
        
        let flexibleSpace = UIBarButtonItem(barButtonSystemItem: .flexibleSpace, target: self, action: nil)
        
        navigationItem.leftBarButtonItem = doneButton
        
        navigationItem.rightBarButtonItem = exportBarButton
        
        toolbarItems = [oldestButton, flexibleSpace, rewindButton, flexibleSpace, newestButton]
    }
    
    override func viewWillTransition(to size: CGSize, with coordinator: UIViewControllerTransitionCoordinator) {
        super.viewWillTransition(to: size, with: coordinator)
        self.dismiss(animated: false)
    }
    
}

// MARK: - Animations

extension MemoriesViewController {
    
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
        AnalyticsEvents.logEvent(.memoriesRewind)
        let count = String(MemoriesCacheManager.loadAllMemories().count)
        AnalyticsEvents.logEvent(.memoriesRewind, parameters: ["memories" : count])
        swipeableView?.rewind()
        updateTitle()
    }
    
    @objc private func oldest() {
        // ensure no overlapping animations
        guard cardsLongAnimationInProgress == false else { return }
        cardsLongAnimationInProgress = true
        
        let count = String(MemoriesCacheManager.loadAllMemories().count)
        AnalyticsEvents.logEvent(.memoriesOldest, parameters: ["memories" : count])
        
        let active = activeViewsCount
        let duration: TimeInterval = 1.5
        let interval: TimeInterval = duration / Double(active)
        
        for i in 0..<active {
            DispatchQueue.main.asyncAfter(deadline: .now() + (interval * Double(i))) { [weak self] in
                guard let self = self else { return }
                guard self.activeViewsCount > 1 else {
                    self.cardsLongAnimationInProgress = false
                    return }
                
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
        
        let count = String(MemoriesCacheManager.loadAllMemories().count)
        AnalyticsEvents.logEvent(.memoriesNewest, parameters: ["memories" : count])
        
        let duration: TimeInterval = 0.75
        let interval: TimeInterval = duration / Double(snapshots.count)
        
        for i in 0..<snapshots.count {
            DispatchQueue.main.asyncAfter(deadline: .now() + (interval * Double(i))) { [weak self] in
                guard let self = self else { return }
                self.swipeableView?.rewind()

                self.updateTitle()
                if i == (self.snapshots.count - 1) {
                    self.cardsLongAnimationInProgress = false
                }
            }
        }
    }
    
    private func updateTitle() {
        
        let date = getCurrentCardDate()
        let dateFormatter = DateFormatter()
        
        dateFormatter.dateFormat = "MMM dd, yyyy h:mm a"
        
        self.title = dateFormatter.string(from: date)
    }
    
    func getCurrentCard() -> MemoriesSnapshot {
        let difference = scaledSnapshots.count - activeViewsCount
        // safety check
        if difference < scaledSnapshots.count {
            return scaledSnapshots[difference]
        } else {
            // must never pass here
            return MemoriesSnapshot(image: UIImage())
        }
    }
    
    private func getCurrentCardDate() -> Date {
        return getCurrentCard().date
    }
}

extension MemoriesViewController: MemoriesExport {
    @objc func exportButtonPressed(_ sender: UIButton) {
        if let superview = sender.superview {
            let fakeView = UIView(frame: superview.frame.insetBy(dx: -20, dy: -20))
            superview.addSubview(fakeView)
            fakeView.center = superview.center
            exportBy(fakeView)
        }
    }
}


// MARK: - Demo mode
extension MemoriesViewController {
    func showDemoAlertIfNeeded() {
        if demo {
            DispatchQueue.main.asyncAfter(deadline: .now() + 1) { [weak self] in
                guard let self = self else { return }
                let ac = UIAlertController(title: "Memories", message: "Every day you launch InstaWeather, a new entry is added to this screen", preferredStyle: .alert)
                
                self.present(ac, animated: true, completion: nil)
                let overlay = UIView(frame: CGRect(x: 0, y: 0, width: 5000, height: 5000))
                ac.view.addSubview(overlay)
                overlay.center = ac.view.center
                overlay.isUserInteractionEnabled = true
                
                let dismissTap = UITapGestureRecognizer(target: self, action: #selector(self.dismissAlert))
                overlay.addGestureRecognizer(dismissTap)
                
                self.demoAlert = ac
                DispatchQueue.main.asyncAfter(deadline: .now() + 3) { [weak ac] in
                    ac?.dismiss(animated: true, completion: nil)
                }
            }
        }
    }
    
    @objc func dismissAlert() {
        demoAlert?.dismiss(animated: true, completion: nil)
        demoAlert = nil
    }
}
