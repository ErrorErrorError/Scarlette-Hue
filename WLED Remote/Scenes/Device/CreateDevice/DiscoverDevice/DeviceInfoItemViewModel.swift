//
//  DeviceInfoItemViewModel.swift
//  WLED Remote
//
//  Created by Erik Bautista on 5/21/21.
//

import Foundation

final class DeviceInfoItemViewModel {
    let name: String
    let ip: String
    let device: Device

    init(with device: Device) {
        self.device = device
        self.name = device.name
        self.ip = device.ip
    }
}
