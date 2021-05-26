//
//  DeviceDataNetwork.swift
//  WLED Remote
//
//  Created by Erik Bautista on 5/25/21.
//

import RxSwift

public final class DeviceDataNetwork {
    private let network: Network<DeviceData>

    init(network: Network<DeviceData>) {
        self.network = network
    }

    public func fetchDeviceData(device: Device) -> Observable<DeviceData> {
        return network.getItem(device, "")
    }

    public func updateState(device: Device, state: State) -> Observable<Bool> {
        return network.postItem(device, "si", (try? state.jsonData()) ?? Data())
    }
}
