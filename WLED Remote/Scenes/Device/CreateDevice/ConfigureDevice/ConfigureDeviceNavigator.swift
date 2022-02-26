//
//  ConfigureDeviceNavigator.swift
//  WLED Remote
//
//  Created by Erik Bautista on 5/21/21.
//

import Foundation
import UIKit

protocol ConfigureDeviceNavigatorType {
    func toDevices()
}

struct ConfigureDeviceNavigator: ConfigureDeviceNavigatorType {
    unowned let assembler: Assembler
    unowned let navigationController: UINavigationController

    func toDevices() {
        navigationController.dismiss(animated: true)
    }
}
