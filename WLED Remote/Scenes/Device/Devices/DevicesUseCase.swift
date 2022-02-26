//
//  DevicesUseCase.swift
//  WLED Hue
//
//  Created by Erik Bautista on 2/15/22.
//

import RxSwift
import WLEDClient

protocol DevicesUseCaseType {
    func getDevices() -> Observable<[Device]>
    func updateDevice(device: Device) -> Observable<Void>
    func deleteDevice(_ device: Device) -> Observable<Void>
}

struct DevicesUseCase: DevicesUseCaseType,
                       FetchingDevices,
                       UpdatingDevice,
                       DeletingDevice {
    var deviceGatewayType: DeviceGatewayType
}
