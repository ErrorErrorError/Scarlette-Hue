//
//  UpdatingDevice.swift
//  WLED Hue
//
//  Created by Erik Bautista on 2/15/22.
//

import RxSwift

protocol UpdatingDevice {
    var deviceGatewayType: DeviceGatewayType { get }
}

extension UpdatingDevice {
    func updateDevice(device: Device) -> Observable<Void> {
        return deviceGatewayType.save(device: device)
    }
}
