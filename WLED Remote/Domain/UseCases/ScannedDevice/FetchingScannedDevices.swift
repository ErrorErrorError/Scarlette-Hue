//
//  FetchingServices.swift
//  WLED Hue
//
//  Created by Erik Bautista on 2/16/22.
//

import Foundation
import RxSwift

protocol FetchingScannedDevices {
    var bonjourGatewayType: BonjourGatewayType { get }
}

extension FetchingScannedDevices {
    func getScannedDevices() -> Observable<ScannedDevice> {
        bonjourGatewayType.getScannedServices()
            .compactMap {
                $0.firstIPv4Address != nil ? .init(name: $0.name, ip: $0.firstIPv4Address!, port: $0.port) : nil
            }
    }
}
