//
//  ConfigureDeviceUseCase.swift
//  WLED Hue
//
//  Created by Erik Bautista on 2/16/22.
//

import RxSwift

protocol ConfigureDeviceUseCaseType {
    func getDevices() -> Observable<[Device]>
    func updateDevice(device: Device) -> Observable<Void>
}

struct ConfigureDeviceUseCase: ConfigureDeviceUseCaseType,
                               FetchingDevices,
                               UpdatingDevice {
    var deviceGatewayType: DeviceGatewayType
}

