//
//  ViewController.swift
//  WLED Remote
//
//  Created by Erik Bautista on 5/8/21.
//

import UIKit


class MainViewController: UINavigationController {

    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .systemBackground

        let devicesViewController = DevicesViewController()

        pushViewController(devicesViewController, animated: false)
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

