//
//  StoreAPI.swift
//  WLED Remote
//
//  Created by Erik Bautista on 5/25/21.
//

import Foundation
import RxSwift

// This class is for retreiving all of the data that is in Device store, including info, eff, state, and pal

public final class StoreAPI {
    private let network: Network<Store>

    init(network: Network<Store>) {
        self.network = network
    }

    public func fetchStore(for device: Device) -> Observable<Store> {
        return network.getItem(device, "json")
    }

    public func updateState(device: Device, state: State) -> Observable<Bool> {
        return network.postItem(device, "json/si", (try? state.jsonData()) ?? Data())
            .map({ _ in true })
    }
}
