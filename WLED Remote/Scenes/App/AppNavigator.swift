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
        let navigationController = UINavigationController()
        navigationController.navigationBar.prefersLargeTitles = true

        let devicesViewController: DevicesViewController = assembler.resolve(navigationController: navigationController)

        navigationController.pushViewController(devicesViewController, animated: false)

        window.rootViewController = navigationController
        window.backgroundColor = UIColor.mainSystemBackground
        window.makeKeyAndVisible()
    }
}
