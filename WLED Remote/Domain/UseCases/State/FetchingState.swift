//
//  FetchingState.swift
//  WLED Hue
//
//  Created by Erik Bautista on 2/15/22.
//

import RxSwift

protocol FetchingState {
    var stateGatewayType: StateGatewayType { get }
}

extension FetchingState {
    func getStore(for device: Device) -> Observable<State> {
        stateGatewayType.getState(for: device)
    }
}
