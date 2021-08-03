//
//  SettingsNavigation.swift
//  WLED Remote
//
//  Created by Erik Bautista on 5/26/21.
//

import UIKit

protocol SettingsNavigator {
    func toSettings()
    func toDevicesSettings()
}

class DefaultSettingsNavigator: SettingsNavigator {
    private let navigationController: UINavigationController
    private let services: UseCaseProvider

    init(services: UseCaseProvider,
         navigationController: UINavigationController) {
        self.services = services
        self.navigationController = navigationController
    }

    func toSettings() {
        let viewController = SettingsViewController()
        viewController.viewModel = SettingsViewModel(devicesRepository: services.makeDevicesRepository(),
                                                    navigator: self)
        navigationController.pushViewController(viewController, animated: true)
    }

    func toDevicesSettings() {

    }
}
