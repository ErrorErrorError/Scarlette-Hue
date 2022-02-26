//
//  DeviceStore.swift
//  WLED Hue
//
//  Created by Erik Bautista on 2/22/22.
//

import Foundation
import WLEDClient

public struct DeviceStore {
    var device: Device
    let wledDevice: WLEDDevice
}

extension DeviceStore: Equatable {
    public static func == (lhs: DeviceStore, rhs: DeviceStore) -> Bool {
        lhs.device == rhs.device
    }
}
