//
//  DeviceItemViewModel.swift
//  WLED Remote
//
//  Created by Erik Bautista on 5/20/21.
//

import Foundation

final class DeviceItemViewModel {
    let name: String
    let ip: String
    let device: Device

    init(with device: Device) {
        self.device = device
        self.name = device.name
        self.ip = device.ip
    }
}
