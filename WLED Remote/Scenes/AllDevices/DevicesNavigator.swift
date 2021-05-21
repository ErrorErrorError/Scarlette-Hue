//
//  DevicesNavigator.swift
//  WLED Remote
//
//  Created by Erik Bautista on 5/20/21.
//

import UIKit

protocol DevicesNavigator {
    func toCreateDevice()
    func toDevice(_ device: Device)
    func toDevices()
}

class DefaultDevicesNavigator: DevicesNavigator {
    func toCreateDevice() {

    }

    func toDevice(_ device: Device) {

    }

    func toDevices() {

    }
}
