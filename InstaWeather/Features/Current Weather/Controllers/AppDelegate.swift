//
//  AppDelegate.swift
//  Rain Check
//
//  Created by Besher on 2018-01-27.
//  Copyright © 2018 Besher Al Maleh. All rights reserved.
//

import UIKit
import Fabric
import Crashlytics
import TwitterKit
import FBSDKCoreKit


@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate {

    var window: UIWindow?
    var reconnectTimer: Timer?


    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?) -> Bool {
        // Override point for customization after application launch.
        let pageControl = UIPageControl.appearance()
        pageControl.backgroundColor = UIColor.clear
        Fabric.with([Crashlytics.self])
        incrementLaunchCount()
        TWTRTwitter.sharedInstance().start(withConsumerKey: TWTR_CONSUMER_KEY, consumerSecret: TWTR_API_SECRET)
        return true
    }

    func applicationWillResignActive(_ application: UIApplication) {
        // Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
        // Use this method to pause ongoing tasks, disable timers, and invalidate graphics rendering callbacks. Games should use this method to pause the game.
//        deactivateTimer()
    }

    func applicationDidEnterBackground(_ application: UIApplication) {
        // Use this method to release shared resources, save user data, invalidate timers, and store enough application state information to restore your application to its current state in case it is terminated later.
        // If your application supports background execution, this method is called instead of applicationWillTerminate: when the user quits.
        deactivateTimer()
    }

    func applicationWillEnterForeground(_ application: UIApplication) {
        // Called as part of the transition from the background to the active state; here you can undo many of the changes made on entering the background.
    }

    func applicationDidBecomeActive(_ application: UIApplication) {
        // Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
        updateLastLaunchDate()
        FBSDKAppEvents.activateApp()
    }

    func applicationWillTerminate(_ application: UIApplication) {
        // Called when the application is about to terminate. Save data if appropriate. See also applicationDidEnterBackground:.
        deactivateTimer()
    }
    
    func deactivateTimer() {
        reconnectTimer?.invalidate()
        reconnectTimer = nil
        print("Sunsetting the timer")
    }
    
    // Twitter
    
    func application(_ app: UIApplication, open url: URL, options: [UIApplication.OpenURLOptionsKey: Any] = [:]) -> Bool {
        return TWTRTwitter.sharedInstance().application(app, open: url, options: options)
    }

}

// MARK: - Update last launch date for reference in Today Widget

extension AppDelegate {
    func updateLastLaunchDate() {
        if let defaults = UserDefaults(suiteName: "group.com.besher.InstaWeather") {
            defaults.set(AppLaunch.encodeFrom(AppLaunch()), forKey: "appLaunched")
        }
    }
    
    func incrementLaunchCount() {
//        AppSettings.appLaunchCount
        AppSettings.appLaunchCount += 1
    }
}
