//
//  DeviceStoreModel.swift
//  WLED Hue
//
//  Created by Erik Bautista on 2/16/22.
//

import Foundation

struct DeviceStoreModel: Hashable {
    let device: Device
    let connectionState: HeartbeatConnection.ConnectionState
    let store: Store?
}
