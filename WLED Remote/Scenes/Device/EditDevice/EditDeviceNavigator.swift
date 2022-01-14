//
//  DeviceNavigator.swift
//  WLED Remote
//
//  Created by Erik Bautista on 5/22/21.
//

import Foundation
import UIKit

public protocol EditDeviceNavigator {
    func toDevices()
    func toDeviceInfo()
    func toDeviceSettings()
    func toDeviceEffects()
}

public class DefaultDeviceNavigator: EditDeviceNavigator {
    private let navigationController: UINavigationController
    private let services: UseCaseProvider

    public init(services: UseCaseProvider,
                navigationController: UINavigationController) {
        self.navigationController = navigationController
        self.services = services
    }

    public func toDevices() {
        self.navigationController.popToRootViewController(animated: true)
    }

    public func toDeviceInfo() {
    }

    public func toDeviceSettings() {
    }

    public func toDeviceEffects() {
    }
}
