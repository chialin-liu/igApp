//
//  AppDelegate.swift
//  instagram
//
//  Created by Chialin Liu on 2020/5/2.
//  Copyright © 2020 Chialin Liu. All rights reserved.
//

import UIKit
import Firebase
import FacebookCore
@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate {

    var window: UIWindow?

    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?) -> Bool {
        // Override point for customization after application launch.
        FirebaseApp.configure()
        window = UIWindow()
        window?.rootViewController = MainTabBarController()
        ApplicationDelegate.shared.application(application, didFinishLaunchingWithOptions: launchOptions)
        return true
    }

    func application(_ app: UIApplication, open url: URL, options: [UIApplication.OpenURLOptionsKey : Any] = [:]) -> Bool {
       ApplicationDelegate.shared.application(app,
          open: url,
          sourceApplication: options[UIApplication.OpenURLOptionsKey.sourceApplication] as? String,
          annotation:
        options[UIApplication.OpenURLOptionsKey.annotation])
    }
    // MARK: UISceneSession Lifecycle

    


}

