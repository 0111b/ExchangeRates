//
//  AppDelegate.swift
//  ExchangeRates
//
//  Created by Alexandr Goncharov on 07/04/2019.
//  Copyright © 2019 Revolut. All rights reserved.
//

import UIKit
import os.signpost

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate {

    var window: UIWindow?

    private lazy var coordinator: AppCoordinator = {
        guard let window = self.window
            else { preconditionFailure("App window is not initialized") }
        return AppCoordinator(mainWindow: window)
    }()

    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?) -> Bool {
        self.window = UIWindow(frame: UIScreen.main.bounds)
        coordinator.start()
        return true
    }

    func applicationWillResignActive(_ application: UIApplication) {
        os_signpost(.event, log: Log.pointsOfInterest, name: #function)
    }

    func applicationDidBecomeActive(_ application: UIApplication) {
        os_signpost(.event, log: Log.pointsOfInterest, name: #function)
    }

}
