//
//  FetchingDevices.swift
//  WLED Hue
//
//  Created by Erik Bautista on 2/15/22.
//

import RxSwift

protocol FetchingDevices {
    var deviceGatewayType: DeviceGatewayType { get }
}

extension FetchingDevices {
    func getDevices() -> Observable<[Device]> {
        return deviceGatewayType.devices()
    }
}
