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
    let port: Int
    let data: (String, String, Int)

    init(with info: (String, String, Int)) {
        self.data = info
        self.name = info.0
        self.ip = info.1
        self.port = info.2
    }
}
