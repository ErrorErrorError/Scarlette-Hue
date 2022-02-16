//
//  DevicesUseCase.swift
//  WLED Hue
//
//  Created by Erik Bautista on 2/15/22.
//

import RxSwift

protocol DevicesUseCaseType {
    func getDevices() -> Observable<[Device]>
    func updateDevice(device: Device) -> Observable<Void>
    func deleteDevice(_ device: Device) -> Observable<Void>
    func getStore(for device: Device) -> Observable<Store>
}

struct DevicesUseCase: DevicesUseCaseType,
                       FetchingDevices,
                       UpdatingDevice,
                       DeletingDevice,
                       FetchingStore {
    var deviceGatewayType: DeviceGatewayType
    var storeGatewayType: StoreGatewayType
}
