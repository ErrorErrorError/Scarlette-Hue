//
//  AppNavigator.swift
//  WLED Hue
//
//  Created by Erik Bautista on 2/15/22.
//

import UIKit

protocol AppNavigatorType {
    func toDevices()
}

struct AppNavigator: AppNavigatorType {
    unowned let assembler: Assembler
    unowned let window: UIWindow

    func toDevices() {
//        let devicesNavigationController = UINavigationController()
//        let deviceNavigator = DefaultDevicesNavigator(services: services,
//                                                      navigationController: devicesNavigationController)
//
//        let settingsNavigationController = UINavigationController()
//        let settingsNavigator = DefaultSettingsNavigator(services: services,
//                                                         navigationController: settingsNavigationController)
//
//        let tabBarViewController = UITabBarController()
//
//        devicesNavigationController.tabBarItem = UITabBarItem(title: "Devices",
//                                                          image: UIImage(systemName: "lightbulb.fill"),
//                                                          tag: 0)
//        settingsNavigationController.tabBarItem = UITabBarItem(title: "Settings",
//                                                          image: UIImage(systemName: "gearshape.fill"),
//                                                          tag: 1)
//
//        tabBarViewController.setViewControllers([devicesNavigationController, settingsNavigationController], animated: true)
//
//        tabBarViewController.tabBar.isHidden = true
//
//        window.rootViewController = tabBarViewController
//        window.backgroundColor = UIColor.mainSystemBackground
//        window.makeKeyAndVisible()
//
//        deviceNavigator.toDevices()
//        settingsNavigator.toSettings()
    }
}
