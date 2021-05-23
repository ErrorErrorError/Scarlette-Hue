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
        window.rootViewController = devicesNavigationController

        deviceNavigator.toDevices()

        //        let devicesViewController = UINavigationController(rootViewController: DevicesCollectionViewController())
        //        let settingsViewController = UINavigationController(rootViewController: SettingsViewController())
        //        devicesViewController.tabBarItem = UITabBarItem(title: "Devices",
        //                                                          image: UIImage(systemName: "lightbulb.fill"),
        //                                                          tag: 0)
        //        settingsViewController.tabBarItem = UITabBarItem(title: "Settings",
        //                                                          image: UIImage(systemName: "gearshape.fill"),
        //                                                          tag: 0)
        //
        //        setViewControllers([devicesViewController, settingsViewController], animated: true)

    }
}
