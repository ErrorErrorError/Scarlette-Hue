//
//  StateGateway.swift
//  WLED Hue
//
//  Created by Erik Bautista on 2/15/22.
//

import RxSwift

protocol StateGatewayType {
    func getState(for device: Device) -> Observable<State>
    func updateState(with state: State, for device: Device) -> Observable<Bool>
}

struct StateGateway: StateGatewayType {
    func updateState(with state: State, for device: Device) -> Observable<Bool> {
        let apiEndpoint = "http://%@:%d"
        let stateApi = StateAPI(network: .init(apiEndpoint))
        return stateApi.updateState(device: device, state: state)
    }
    
    func getState(for device: Device) -> Observable<State> {
        let apiEndpoint = "http://%@:%d"
        let stateApi = StateAPI(network: .init(apiEndpoint))

        return stateApi.fetchState(device: device)
    }
}
