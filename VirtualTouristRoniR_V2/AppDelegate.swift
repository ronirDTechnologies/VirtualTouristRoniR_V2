//
//  AppDelegate.swift
//  VirtualTouristRoniR_V2
//
//  Created by Roni Rozenblat on 5/29/21.
//

//
//  AppDelegate.swift
//  VIrtualTourist_RoniR
//
//  Created by Roni Rozenblat on 1/10/20.
//  Copyright © 2020 dinatech. All rights reserved.
//

import UIKit
//import CoreData

@UIApplicationMain
    class AppDelegate: UIResponder, UIApplicationDelegate {

    var window: UIWindow?
    let dataController = DataController(modelName: "VirtualT")

    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?) -> Bool {
        // Override point for customization after application launch.
       
        
        
        dataController.load()
        
        let navigationController = window?.rootViewController as! UINavigationController
        let travelLocMapVC = navigationController.topViewController as! TravelLocationsMapViewController
        // Inject the dataController dependency
        travelLocMapVC.dataController = dataController
        
        return true
    }
    
    func applicationWillResignActive(_ application: UIApplication) {
        // Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
        // Use this method to pause ongoing tasks, disable timers, and invalidate graphics rendering callbacks. Games should use this method to pause the game.
    }

    func applicationDidEnterBackground(_ application: UIApplication) {
        // Use this method to release shared resources, save user data, invalidate timers, and store enough application state information to restore your application to its current state in case it is terminated later.
        // If your application supports background execution, this method is called instead of applicationWillTerminate: when the user quits.
        saveViewContext()
    }

    func applicationWillEnterForeground(_ application: UIApplication) {
        // Called as part of the transition from the background to the active state; here you can undo many of the changes made on entering the background.
    }

    func applicationDidBecomeActive(_ application: UIApplication) {
        // Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
    }

    func applicationWillTerminate(_ application: UIApplication) {
        // Called when the application is about to terminate. Save data if appropriate. See also applicationDidEnterBackground:.
        saveViewContext()
    }

    func saveViewContext() {
        try? dataController.viewContext.save()
    }
}
