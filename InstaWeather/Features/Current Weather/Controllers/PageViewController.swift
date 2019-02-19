//
//  PageViewController.swift
//  InstaWeather
//
//  Created by Besher on 2018-01-29.
//  Copyright © 2018 Besher Al Maleh. All rights reserved.
//

import UIKit

protocol StatusBarUpdater: AnyObject {
    func changeStatusBarToLight(_ light: Bool)
    func pageViewDataSourceIsActive(_ active: Bool)
}

class PageViewController: UIPageViewController, UIPageViewControllerDataSource, UIPageViewControllerDelegate {
    
    var deviceFrame: CGRect?
    var lightStatusBar: Bool = true
    
    private(set) var orderedViewControllers = [UIViewController]()

    override public var supportedInterfaceOrientations: UIInterfaceOrientationMask {
        return Display.pad ? .all : .portrait //return the value as per the required orientation
    }
    
//    override public var shouldAutorotate: Bool {
//        return true
//    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        for view in self.view.subviews {
            if let scrollView = view as? UIScrollView {
                scrollView.frame = UIScreen.main.bounds
                scrollView.delaysContentTouches = false
            } else if view is UIPageControl {
                view.backgroundColor = UIColor.clear
                view.isUserInteractionEnabled = false
            }
        }
    }
    
    override var preferredStatusBarStyle: UIStatusBarStyle {
        return lightStatusBar ? .lightContent : .default
    }
    
    override func viewDidLoad() {
        
        guard let first = storyboard?.instantiateViewController(withIdentifier: "first") as? DetailedContainerViewController,
            let second = storyboard?.instantiateViewController(withIdentifier: "second") as? WeatherViewController,
            let third = storyboard?.instantiateViewController(withIdentifier: "third") as? ForecastViewController else { fatalError() }
        orderedViewControllers = [first, second, third]
        
        second.preloadForecastTable = preloadForecastTable
        first.statusBarUpdater = self
        second.statusBarUpdater = self
        third.statusBarUpdater = self
        super.viewDidLoad()
        
        
        if orderedViewControllers.count > 0 {
            let vcToLoad = orderedViewControllers[1]
            setViewControllers([vcToLoad], direction: .reverse, animated: false)
        }
    }

    func pageViewController(_ pageViewController: UIPageViewController, viewControllerBefore viewController: UIViewController) -> UIViewController? {
        
        guard let viewControllerIndex = orderedViewControllers.index(of: viewController) else { return nil }
        let previousIndex = viewControllerIndex - 1
        
        guard previousIndex >= 0 else { return nil }
        
        guard orderedViewControllers.count > previousIndex else { return nil }
        
        return orderedViewControllers[previousIndex]
    }
    
    func pageViewController(_ pageViewController: UIPageViewController, viewControllerAfter viewController: UIViewController) -> UIViewController? {
        
        guard let viewControllerIndex = orderedViewControllers.index(of: viewController) else { return nil }
        
        let nextIndex = viewControllerIndex + 1
        guard orderedViewControllers.count != nextIndex else { return nil }
        guard orderedViewControllers.count > nextIndex else { return nil }
        
        return orderedViewControllers[nextIndex]
    }
    
    func presentationCount(for pageViewController: UIPageViewController) -> Int {
        return orderedViewControllers.count
    }
    
    func presentationIndex(for pageViewController: UIPageViewController) -> Int {
        guard let firstViewController = viewControllers?.first, let firstViewControllerIndex = orderedViewControllers.index(of: firstViewController) else { return 0 }
        return firstViewControllerIndex
    }
    
    func preloadForecastTable() {
        var vcToLoad = self.orderedViewControllers[0]
        self.setViewControllers([vcToLoad], direction: .reverse, animated: false)
        vcToLoad = self.orderedViewControllers[2]
        self.setViewControllers([vcToLoad], direction: .reverse, animated: false)
        vcToLoad = self.orderedViewControllers[1]
        self.setViewControllers([vcToLoad], direction: .forward, animated: false)
        dataSource = self
        delegate = self
    }
    
    func pageViewController(_ pageViewController: UIPageViewController, didFinishAnimating finished: Bool, previousViewControllers: [UIViewController], transitionCompleted completed: Bool) {
        AnalyticsEvents.logEvent(.swipedPage)
    }
    
}

extension PageViewController: StatusBarUpdater {
    func changeStatusBarToLight(_ light: Bool) {
        lightStatusBar = light
        setNeedsStatusBarAppearanceUpdate()
    }
    
    func pageViewDataSourceIsActive(_ active: Bool) {
        togglePaging(enabled: active)
    }
    
    func togglePaging(enabled: Bool) {
        for case let view as UIScrollView in self.view.subviews {
            view.isScrollEnabled = enabled
        }
    }
}
