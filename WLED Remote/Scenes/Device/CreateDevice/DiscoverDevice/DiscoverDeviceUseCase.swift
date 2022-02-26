//
//  DiscoverDeviceUseCase.swift
//  WLED Hue
//
//  Created by Erik Bautista on 2/16/22.
//

import RxSwift
import WLEDClient

protocol DiscoverDeviceUseCaseType {
    func getDevices() -> Observable<[Device]>
    func startScan() -> Void
    func stopScan() -> Void
    func getScannedDevices() -> Observable<ScannedDevice>
}

struct DiscoverDeviceUseCase: DiscoverDeviceUseCaseType,
                              FetchingDevices,
                              StartScanningDevices,
                              StopScanningDevices,
                              FetchingScannedDevices {
    var deviceGatewayType: DeviceGatewayType
    var bonjourGatewayType: BonjourGatewayType
}

