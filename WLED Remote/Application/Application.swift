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

    func configureMainInterface(in window: UIWindow) {
        let devicesNavigationController = UINavigationController()

        let deviceNavigator = DefaultDevicesNavigator(services: services, navigationController: devicesNavigationController)
        window.rootViewController = devicesNavigationController
    
        deviceNavigator.toDevices()
    }
}
