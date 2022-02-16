//
//  UpdatingState.swift
//  WLED Hue
//
//  Created by Erik Bautista on 2/15/22.
//

import RxSwift

protocol UpdatingState {
    var stateGatewayType: StateGatewayType { get }
}

extension UpdatingState {
    func updateState(with state: State, for device: Device) -> Observable<Bool> {
        stateGatewayType.updateState(with: state, for: device)
    }
}
