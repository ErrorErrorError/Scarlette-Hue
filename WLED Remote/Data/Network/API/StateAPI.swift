//
//  StateNetwork.swift
//  WLED Remote
//
//  Created by Erik Bautista on 5/20/21.
//

import Foundation
import RxSwift

public final class StateAPI {
    private let network: Network<State>

    init(network: Network<State>) {
        self.network = network
    }

    public func fetchState(device: Device) -> Observable<State> {
        return network.getItem(device, "json/state")
    }

    public func validateNetwork(ip: String, port: Int) -> Observable<State> {
        return network.getItem("http://\(ip):\(port)", "json/state")
    }

    public func updateState(device: Device, state: State) -> Observable<Bool> {
        return network.postItem(device, "json/si", (try? state.jsonData()) ?? Data())
            .map({ _ in true })
    }
}
