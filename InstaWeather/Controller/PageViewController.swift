//
//  PageViewController.swift
//  InstaWeather
//
//  Created by Besher on 2018-01-29.
//  Copyright © 2018 Besher Al Maleh. All rights reserved.
//

import UIKit

class PageViewController: UIPageViewController, UIPageViewControllerDataSource {
    
    var deviceFrame: CGRect?
    
    private(set) var orderedViewControllers = [UIViewController]()

    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        for view in self.view.subviews {
            if view is UIScrollView {
                view.frame = UIScreen.main.bounds
            } else if view is UIPageControl {
                view.backgroundColor = UIColor.clear
            }
        }
    }
    
    override var preferredStatusBarStyle: UIStatusBarStyle {
            return .lightContent
    }
    
    override func viewDidLoad() {
        
        guard let first = storyboard?.instantiateViewController(withIdentifier: "first"), let second = storyboard?.instantiateViewController(withIdentifier: "second") as? WeatherViewController, let third = storyboard?.instantiateViewController(withIdentifier: "third") else { fatalError() }
        orderedViewControllers = [first, second, third]

        second.preloadForecastTable = preloadForecastTable
        
        super.viewDidLoad()
        dataSource = self
        
        
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
    }
    
}
