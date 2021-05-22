//
//  StateNetwork.swift
//  WLED Remote
//
//  Created by Erik Bautista on 5/20/21.
//

import RxSwift

public final class StateNetwork {
    private let network: Network<State>

    init(network: Network<State>) {
        self.network = network
    }

    public func fetchState(device: Device) -> Observable<State> {
        return network.getItem(device, "state")
    }

    public func validateNetwork(ip: String, port: Int) -> Observable<State> {
        return network.getItem(ip, port, "state")
    }
}
