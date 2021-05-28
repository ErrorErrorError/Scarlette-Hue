//
//  Application.swift
//  WLED Remote
//
//  Created by Erik Bautista on 5/20/21.
//

import Foundation
import UIKit

final class Application {
    static let shared = Application()
    private let services: UseCaseProvider

    private init() {
        self.services = UseCaseProvider()
    }

    // TODO: Create a tab bar controller for each element
    func configureMainInterface(in window: UIWindow) {
        let devicesNavigationController = UINavigationController()
        let deviceNavigator = DefaultDevicesNavigator(services: services,
                                                      navigationController: devicesNavigationController)

        let settingsNavigationController = UINavigationController()
        let settingsNavigator = DefaultSettingsNavigator(services: services,
                                                         navigationController: settingsNavigationController)

        let tabBarViewController = UITabBarController()

        devicesNavigationController.tabBarItem = UITabBarItem(title: "Devices",
                                                          image: UIImage(systemName: "lightbulb.fill"),
                                                          tag: 0)
        settingsNavigationController.tabBarItem = UITabBarItem(title: "Settings",
                                                          image: UIImage(systemName: "gearshape.fill"),
                                                          tag: 1)

        tabBarViewController.setViewControllers([devicesNavigationController, settingsNavigationController], animated: true)

        window.rootViewController = tabBarViewController
        window.backgroundColor = UIColor.mainSystemBackground
        window.makeKeyAndVisible()

        deviceNavigator.toDevices()
        settingsNavigator.toSettings()
    }
}
