//
//  DiscoverDeviceUseCase.swift
//  WLED Hue
//
//  Created by Erik Bautista on 2/16/22.
//

import RxSwift

protocol DiscoverDeviceUseCaseType {
    func getDevices() -> Observable<[Device]>
}

struct DiscoverDeviceUseCase: DiscoverDeviceUseCaseType,
                              FetchingDevices {
    var deviceGatewayType: DeviceGatewayType
}

