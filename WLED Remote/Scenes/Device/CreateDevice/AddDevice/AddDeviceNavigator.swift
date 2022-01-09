//
//  AddDeviceNavigator.swift
//  WLED Remote
//
//  Created by Erik Bautista on 5/21/21.
//

import Foundation
import UIKit

protocol AddDeviceNavigatorProtocol {
    func toDevices()
}

class AddDeviceNavigator: AddDeviceNavigatorProtocol {
    private let navigationController: UINavigationController

    init(navigationController: UINavigationController) {
        self.navigationController = navigationController
    }

    func toDevices() {
        navigationController.dismiss(animated: true)
    }
}
