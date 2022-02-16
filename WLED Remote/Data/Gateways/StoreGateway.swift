//
//  StoreGateway.swift
//  WLED Hue
//
//  Created by Erik Bautista on 2/15/22.
//

import RxSwift

protocol StoreGatewayType {
    func getStore(for device: Device) -> Observable<Store>
}

struct StoreGateway: StoreGatewayType {
    func getStore(for device: Device) -> Observable<Store> {
        let apiEndpoint = "http://%@:%d"
        let storeApi = StoreAPI(network: .init(apiEndpoint))

        return storeApi.fetchStore(for: device)
    }
}
