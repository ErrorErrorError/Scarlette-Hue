//
//  DeviceNetwork.swift
//  WLED Remote
//
//  Created by Erik Bautista on 5/21/21.
//

import RxSwift

public final class DeviceNetwork {
    private let network: Network<Device>

    init(network: Network<Device>) {
        self.network = network
    }

    public func validateDevice(device: Device) -> Observable<Device> {
        return network.getItem(device, "")
    }
}
