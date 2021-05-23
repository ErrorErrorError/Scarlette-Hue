//
//  DeviceNavigator.swift
//  WLED Remote
//
//  Created by Erik Bautista on 5/22/21.
//

import Foundation
import UIKit

protocol DeviceNavigator {
    func toDevices()
    func toDeviceInfo()
    func toDeviceSettings()
    func toDeviceEffects()
}

class DefaultDeviceNavigator: DeviceNavigator {
    private let navigationController: UINavigationController
    private let services: UseCaseProvider

    init(services: UseCaseProvider,
         navigationController: UINavigationController) {
        self.navigationController = navigationController
        self.services = services
    }

    func toDevices() {
        self.navigationController.popToRootViewController(animated: true)
    }

    func toDeviceInfo() {
    }

    func toDeviceSettings() {
    }

    func toDeviceEffects() {
    }
}
