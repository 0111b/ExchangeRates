//
//  AppCoordinator.swift
//  ExchangeRates
//
//  Created by Alexandr Goncharov on 09/04/2019.
//  Copyright © 2019 Revolut. All rights reserved.
//

import UIKit
import os.log

final class AppCoordinator {
    init(mainWindow: UIWindow) {
        window = mainWindow
    }

    func start() {
        os_log(.info, log: Log.general, "AppCoordinator start")
        window.rootViewController = mainNavigation
        listCoordinator.start()
        window.makeKeyAndVisible()
    }

    private unowned let window: UIWindow
    private let mainNavigation = UINavigationController()

    private lazy var preferences: UserPreferences = {
        return UserPreferences()
    }()
    private lazy var listCoordinator: ExchangeRateListCoordinator = {
        return ExchangeRateListCoordinator(navigationController: mainNavigation, preferences: preferences)
    }()
}
