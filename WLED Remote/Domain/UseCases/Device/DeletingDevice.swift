//
//  DeletingDevice.swift
//  WLED Hue
//
//  Created by Erik Bautista on 2/15/22.
//

import RxSwift

protocol DeletingDevice {
    var deviceGatewayType: DeviceGatewayType { get }
}

extension DeletingDevice {
    func deleteDevice(_ device: Device) -> Observable<Void> {
        return deviceGatewayType.delete(device: device)
    }
}
